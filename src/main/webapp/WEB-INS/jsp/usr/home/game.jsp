<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<html>
<head>
    <title>캐치마인드 게임</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <style>
        body {
            background-image: url('/resources/images/bg.png');
            background-size: cover;
            background-repeat: no-repeat;
            background-position: center;
            font-family: Arial, sans-serif;
            padding: 20px;
        }
        #chat {
            border: 1px solid #aaa;
            height: 200px;
            overflow-y: scroll;
            background: rgba(255, 255, 255, 0.9);
            padding: 10px;
            margin-bottom: 10px;
        }
        canvas {
            border: 2px solid black;
            background: rgba(255, 255, 255, 0.7);
            display: block;
            margin-bottom: 10px;
        }
        #userList {
            background: #fff;
            padding: 10px;
            margin-top: 10px;
            border: 1px solid #ccc;
        }
    </style>
</head>

<body>
<h2>환영합니다, ${nickname}님!</h2>

<!-- 유저 목록 표시 -->
<div id="userList" style="background:#fff; padding:10px; margin-top:10px;">
  <strong>접속 유저 목록:</strong>
  <ul id="userListUl" style="list-style: none; padding-left: 0;"></ul>
</div>


<!-- 색상 선택 -->
<label for="colorPicker">선 색상:</label>
<select id="colorPicker">
    <option value="black" selected>검정</option>
    <option value="red">빨강</option>
    <option value="blue">파랑</option>
    <option value="green">초록</option>
    <option value="purple">보라</option>
    <option value="orange">주황</option>
</select>

<!-- 초기화 버튼 -->
<button onclick="clearCanvas()">🧹 전체 지우기</button>

<!-- 그림판 -->
<canvas id="drawCanvas" width="600" height="400"></canvas>
<c:if test="${!isDrawer}">
    <p>❌ 당신은 출제자가 아닙니다. 그림을 그릴 수 없습니다.</p>
</c:if>

<!-- 정답 입력 -->
<c:if test="${isDrawer}">
    <input type="text" id="answerInput" placeholder="정답 입력" />
    <button onclick="setAnswer()">정답 설정</button>
</c:if>

<!-- 타이머 -->
<div id="timer" style="font-size: 24px; font-weight: bold; margin-top: 10px;">남은 시간: 60초</div>

<!-- 채팅창 -->
<div id="chat"></div>
<input type="text" id="msgInput" placeholder="메시지 입력" onkeydown="if(event.key === 'Enter') sendMessage();" />
<button onclick="sendMessage()">보내기</button>

<script>
const nickname = "<c:out value='${nickname}' />";
const isDrawer = <c:out value='${isDrawer}' />;
const socket = new SockJS('/ws-game');
const stompClient = Stomp.over(socket);

// 연결 
stompClient.connect({}, () => {
    console.log("✅ WebSocket 연결됨");

    // 입장 메시지 전송 및 중복 닉네임 에러 감지 및 처리
    stompClient.send("/app/game/enter", {}, JSON.stringify({
        type: "ENTER",
        sender: nickname,
        content: "입장"
        
    }, (error) => {
        console.error("❌ 연결 실패:", error);
        alert("중복된 닉네임입니다. 다른 닉네임으로 시도해주세요."); 
    }));

    // 채팅 구독
    stompClient.subscribe('/topic/game', (msg) => {
        const body = JSON.parse(msg.body);
        const div = document.createElement("div");
        if (body.type === "SYSTEM") {
            div.style.fontWeight = "bold";
            div.style.color = "green";
        }
        div.innerText = `\${body.sender}: \${body.content}`;
        document.getElementById("chat").appendChild(div);

        // 출제자 변경 시 알림
        if (body.content.includes("출제자가")) {
            alert(body.content);
        }
    });

    // 그림 구독
    stompClient.subscribe('/topic/draw', (msg) => {
        const d = JSON.parse(msg.body);
        drawLine(d.x1, d.y1, d.x2, d.y2, d.color);
    });
    
    
 // 유저 목록 구독
    stompClient.subscribe('/topic/users', (msg) => {
        const nicknames = JSON.parse(msg.body); // 서버에서 보낸 닉네임 리스트
        const ul = document.getElementById("userListUl");
        ul.innerHTML = ""; // 기존 목록 초기화

        nicknames.forEach(nick => {
            const li = document.createElement("li");
            li.innerText = nick;
            ul.appendChild(li);
        });
    });


    // 유저 리스트 구독
    stompClient.subscribe('/topic/userlist', (msg) => {
        const body = JSON.parse(msg.body);
        const users = body.content.split(',');
        document.getElementById("userList").innerHTML =
            "<strong>👥 현재 접속자:</strong><br>" + users.map(name => `• ${name}`).join("<br>");
    });

    // 출제자 알림 구독
    stompClient.subscribe("/topic/drawer", (msg) => {
        const body = JSON.parse(msg.body);
        console.log("👤 현재 출제자:", body.content);
    });

    // 타이머 구독
    stompClient.subscribe('/topic/timer', (msg) => {
        const body = JSON.parse(msg.body);
        if (body.timeLeft >= 0) {
            document.getElementById("timer").innerText = `남은 시간: ${body.timeLeft}초`;
        } else {
            document.getElementById("timer").innerText = "시간 종료!";
            alert(`${body.drawer}의 턴이 종료되었습니다.`);
        }
    });
});

// 채팅 전송
function sendMessage() {
    const input = document.getElementById("msgInput");
    const value = input.value.trim();
    if (!value) return;
    const msg = {
        type: "CHAT",
        sender: nickname,
        content: value
    };
    stompClient.send("/app/game/send", {}, JSON.stringify(msg));
    input.value = '';
}

// 그리기
const canvas = document.getElementById("drawCanvas");
const ctx = canvas.getContext("2d");
const colorPicker = document.getElementById("colorPicker");

let drawing = false;
let prevX = 0;
let prevY = 0;

function drawLine(x1, y1, x2, y2, color) {
    requestAnimationFrame(() => {
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.stroke();
    });
}

function clearCanvas() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

if (isDrawer) {
    canvas.addEventListener("mousedown", (e) => {
        drawing = true;
        [prevX, prevY] = [e.offsetX, e.offsetY];
    });
    canvas.addEventListener("mouseup", () => drawing = false);
    canvas.addEventListener("mousemove", (e) => {
        if (!drawing) return;
        const currX = e.offsetX;
        const currY = e.offsetY;
        drawLine(prevX, prevY, currX, currY, colorPicker.value);
        stompClient.send("/app/game/send", {}, JSON.stringify({
            type: "DRAW",
            sender: nickname,
            x1: prevX,
            y1: prevY,
            x2: currX,
            y2: currY,
            color: colorPicker.value
        }));
        [prevX, prevY] = [currX, currY];
    });
} else {
    canvas.style.pointerEvents = "none";
    canvas.style.cursor = "not-allowed";
}

// 정답 설정
function setAnswer() {
    const answerInput = document.getElementById("answerInput").value.trim();
    if (!answerInput) return;
    stompClient.send("/app/game/setAnswer", {}, JSON.stringify({
        type: "ANSWER",
        sender: nickname,
        content: answerInput
    }));
    alert("✅ 정답이 설정되었습니다!");
}
</script>
</body>
</html>
