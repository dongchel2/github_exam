<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!-- c : if 인식 -->

<html>
<head>
    <title>게임 화면</title>
    <script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        #chat {
            border: 1px solid #aaa;
            height: 200px;
            overflow-y: scroll;
            background: #fff;
            padding: 10px;
            margin-bottom: 10px;
        }
        canvas {
            border: 2px solid black;
            background: #fff;
            display: block;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>

	<h2>환영합니다, ${nickname}님!</h2>

	<!-- 🎨 색상 선택 -->
	<label for="colorPicker">선 색상:</label>
	<select id="colorPicker">
	    <option value="black" selected>검정</option>
	    <option value="red">빨강</option>
	    <option value="blue">파랑</option>
	    <option value="green">초록</option>
	    <option value="purple">보라</option>
	    <option value="orange">주황</option>
	</select>

	<!-- 🧹 초기화 버튼 -->
	<button onclick="clearCanvas()">🧹 전체 지우기</button>

	<!-- 그림판 -->
	<canvas id="drawCanvas" width="600" height="400">
	</canvas>
	<c:if test="${!isDrawer}">
	  <p>❌ 당신은 출제자가 아닙니다. 그림을 그릴 수 없습니다.</p>
	</c:if>

	<!-- 정답 입력 버튼 -->
	<c:if test="${isDrawer}">
	    <input type="text" id="answerInput" placeholder="정답 입력" />
	    <button onclick="setAnswer()">정답 설정</button>
	</c:if>

	<!-- 채팅 -->
	<div id="chat"></div>
	<input type="text" id="msgInput" placeholder="메시지 입력" onkeydown="if(event.key === 'Enter') sendMessage();" />
	<button onclick="sendMessage()">보내기</button>


	<!-- 타이머 -->
	
	<div id="timer" style="font-size: 24px; font-weight: bold; margin-top: 10px;">남은 시간: 60초</div>

	<script>
// 닉네임 스크립트
	const nickname = "<c:out value='${nickname}' />";
	console.log("닉네임 확인:", nickname);
	const isDrawer = <c:out value='${isDrawer}' />;
	console.log("isDrawer:", isDrawer);

	// 웹소켓 스크립트
	const socket = new SockJS('/ws-game');
	const stompClient = Stomp.over(socket);
	
	stompClient.connect({}, () => {
	    console.log("✅ WebSocket 연결됨");
	// 웹소켓 연결 확인용 메시지
	    
    // 게임 시작 시 타이머 시작
    startTimer(); // ⚠️ 이걸 실제 게임 시작 조건에 맞게 호출해야 해요
	
	
	
	    
	    //  여기에 넣는다!
	    stompClient.subscribe('/topic/game', (msg) => {
	        const body = JSON.parse(msg.body);
	  // 
	        console.log("📥 수신 메시지:", body);
      // 웹소켓 수신 메시지
	        
	        const div = document.createElement("div");
	        if (body.type === "SYSTEM") {
	            div.style.fontWeight = "bold";
	            div.style.color = "green";
	        }
	
	        div.innerText = `\${body.sender}: \${body.content}`;
	      // 백틱을 안쓰면 영역이 모호해지기 때문에 $쓸때 \ 쓰는거 유의
	    
	        document.getElementById("chat").appendChild(div);
	    });
	
	    // 다른 구독도 여기 함께(그림 공유 구독)
	    stompClient.subscribe('/topic/draw', (msg) => {
	        const d = JSON.parse(msg.body);
	        drawLine(d.x1, d.y1, d.x2, d.y2, d.color);
	    });
	});
	
	
	
	// 실시간 채팅
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
	
	// 웹 그리기
	
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
	
	//  출제자만 그리기 이벤트
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
	
	        const drawMsg = {
	            type: "DRAW",
	            sender: nickname,
	            x1: prevX,
	            y1: prevY,
	            x2: currX,
	            y2: currY,
	            color: colorPicker.value
	        };
	        stompClient.send("/app/game/send", {}, JSON.stringify(drawMsg));
	
	        [prevX, prevY] = [currX, currY];
	    });
	} else {
	    // 참가자는 비활성화
	    canvas.style.pointerEvents = "none";
	    canvas.style.cursor = "not-allowed";
	}
	
	
	// 정답 주제 설정
	function setAnswer() {
	    const answerInput = document.getElementById("answerInput").value.trim();
	    if (!answerInput) return;
	
	    const msg = {
	        type: "ANSWER",
	        sender: nickname,
	        content: answerInput
	    };
	    stompClient.send("/app/game/setAnswer", {}, JSON.stringify(msg));
	    alert("✅ 정답이 설정되었습니다!");
	}
	
	
	// 타이머 기능
	let timeLeft = 60;
	let timerInterval;
	
	function startTimer() {
	    clearInterval(timerInterval); // 이전 타이머 제거
	    timeLeft = 60;
	
	    timerInterval = setInterval(() => {
	        document.getElementById("timer").innerText = `${timeLeft}초 남음`;
	        timeLeft--;
	
	        if (timeLeft < 0) {
	            clearInterval(timerInterval);
	            document.getElementById("timer").innerText = "시간 종료!";
	            
	            // 출제자 전환 요청
	            stompClient.send("/app/game/nextTurn", {}, JSON.stringify({
	                type: "SYSTEM",
	                sender: nickname,
	                content: "turn end"
	            }));
	        }
	    }, 1000);
	}


	</script>


    

</body>
</html>
