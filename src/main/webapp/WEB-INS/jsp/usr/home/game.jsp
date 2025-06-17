<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="캐치마인드 게임" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>

	<div class="container mx-auto mt-6">
	    <h2 class="text-xl font-bold mb-4">🎨 환영합니다, <span class="text-purple-600">${nickname}</span>님!</h2>
	
	    <!-- 출제자 정보 -->
	    <div id="currentDrawer" class="mb-4 text-lg font-semibold text-blue-700">출제자: 확인 중...</div>
	
	    <!-- 유저 목록 -->
	    <div class="mb-4">
	        <strong>접속 유저:</strong>
	        <ul id="userListUl" class="list-disc pl-6 text-sm"></ul>
	    </div>
	
	    <!-- 색상 선택 & 지우기 -->
	    <div class="flex gap-2 items-center mb-2">
	        <label for="colorPicker" class="font-semibold">선 색상:</label>
	        <select id="colorPicker" class="border rounded px-2 py-1">
	            <option value="black" selected>검정</option>
	            <option value="red">빨강</option>
	            <option value="blue">파랑</option>
	            <option value="green">초록</option>
	            <option value="purple">보라</option>
	            <option value="orange">주황</option>
	        </select>
	        <button onclick="clearCanvas()" class="btn btn-sm btn-error ml-2">🧹 전체 지우기</button>
	    </div>
	
	    <!-- 그림판 -->
	    <canvas id="drawCanvas" width="600" height="400" class="border-2 border-black mb-4"></canvas>
	
	    <c:if test="${!isDrawer}">
	        <p class="text-red-600 font-bold">❌ 당신은 출제자가 아닙니다. 그림을 그릴 수 없습니다.</p>
	    </c:if>
	
	    <c:if test="${isDrawer}">
	        <div class="flex gap-2 mb-4">
	            <input type="text" id="answerInput" placeholder="정답 입력" class="border px-2 py-1 rounded" />
	            <button onclick="setAnswer()" class="btn btn-sm btn-primary">정답 설정</button>
	        </div>
	    </c:if>
	
	    <!-- 타이머 -->
	    <div id="timer" class="text-xl font-bold text-green-700 mb-4">남은 시간: 60초</div>
	
	    <!-- 채팅창 -->
	    <div id="chat" class="bg-white bg-opacity-80 border p-2 h-48 overflow-y-auto mb-2 text-sm"></div>
	    <div class="flex gap-2">
	        <input type="text" id="msgInput" placeholder="메시지 입력" class="flex-1 border px-2 py-1 rounded" />
	        <button onclick="sendMessage()" class="btn btn-sm btn-secondary">보내기</button>
	    </div>
	</div>



	<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
	<script src="https://cdn.jsdelivr.net/npm/stompjs@2.3.3/lib/stomp.min.js"></script>
	
	<script>
	const nickname = "<c:out value='${nickname}' />";
	const isDrawer = <c:out value='${isDrawer}' />;
	const socket = new SockJS('/ws-game');
	const stompClient = Stomp.over(socket);
	
	stompClient.connect({}, () => {
	    console.log(" WebSocket 연결됨");
	
	    // 유저 입장 메시지 전송
	    stompClient.send("/app/game/enter", {}, JSON.stringify({
	        type: "ENTER",
	        sender: nickname,
	        content: "입장"
	    }));
	
	    // 시스템 메시지 수신
	    stompClient.subscribe("/topic/game", (msg) => {
	        const body = JSON.parse(msg.body);
	        const div = document.createElement("div");
	
	        if (body.type === "SYSTEM") {
	            div.style.fontWeight = "bold";
	            div.style.color = "green";
	        }
		    <!-- 백틱 주의 -->
	        div.innerText = `\${body.sender}: \${body.content}`;
	        document.getElementById("chat").appendChild(div);
	        document.getElementById("chat").scrollTop = document.getElementById("chat").scrollHeight;
	
	        if (body.content.includes("출제자")) {
	            alert(body.content);
	        }
	    });
	
	    // 그림 그리기 메시지 수신
	    stompClient.subscribe("/topic/draw", (msg) => {
	        const d = JSON.parse(msg.body);
	        drawLine(d.x1, d.y1, d.x2, d.y2, d.color);
	    });
	
	    // 유저 목록 동기화
	    stompClient.subscribe("/topic/userlist", (msg) => {
	        const nicknames = msg.body.split(",");
	        const ul = document.getElementById("userListUl");
	        ul.innerHTML = "";
	        nicknames.forEach(nick => {
	            const li = document.createElement("li");
	            li.innerText = nick;
	            ul.appendChild(li);
	        });
	    });
	
	    // 현재 출제자 표시
	    stompClient.subscribe("/topic/drawer", (msg) => {
	        const body = JSON.parse(msg.body);
	        document.getElementById("currentDrawer").innerText = `출제자: ${body.content}`;
	    });
	
	    // 타이머 수신
	    stompClient.subscribe("/topic/timer", (msg) => {
	        const body = JSON.parse(msg.body);
	        const timer = document.getElementById("timer");
	        if (body.timeLeft >= 0) {
	            timer.innerText = `남은 시간: ${body.timeLeft}초`;
	        } else {
	            timer.innerText = "시간 종료!";
	        }
	    });
	});
	</script>

	
	
	<script>
	const canvas = document.getElementById("drawCanvas");
	const ctx = canvas.getContext("2d");
	const colorPicker = document.getElementById("colorPicker");
	
	let drawing = false;
	let prevX = 0, prevY = 0;
	
	// 라인 그리기
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
	
	// 전체 지우기
	function clearCanvas() {
	    ctx.clearRect(0, 0, canvas.width, canvas.height);
	}
	
	// 메시지 전송 (채팅)
	function sendMessage() {
	    const input = document.getElementById("msgInput");
	    const value = input.value.trim();
	    if (!value) return;
	
	    stompClient.send("/app/game/send", {}, JSON.stringify({
	        type: "CHAT",
	        sender: nickname,
	        content: value
	    }));
	
	    input.value = "";
	}
	
	// 정답 설정 (출제자 전용)
	function setAnswer() {
	    const input = document.getElementById("answerInput");
	    const value = input.value.trim();
	    if (!value) return;
	
	    stompClient.send("/app/game/setAnswer", {}, JSON.stringify({
	        type: "ANSWER",
	        sender: nickname,
	        content: value
	    }));
	
	    alert("✅ 정답이 설정되었습니다!");
	    input.value = "";
	}
	
	// 출제자만 그리기 활성화
	if (isDrawer) {
	    canvas.addEventListener("mousedown", e => {
	        drawing = true;
	        [prevX, prevY] = [e.offsetX, e.offsetY];
	    });
	
	    canvas.addEventListener("mouseup", () => drawing = false);
	
	    canvas.addEventListener("mousemove", e => {
	        if (!drawing) return;
	
	        const currX = e.offsetX;
	        const currY = e.offsetY;
	
	        drawLine(prevX, prevY, currX, currY, colorPicker.value);
	
	        stompClient.send("/app/game/send", {}, JSON.stringify({
	            type: "DRAW",
	            sender: nickname,
	            x1: prevX, y1: prevY,
	            x2: currX, y2: currY,
	            color: colorPicker.value
	        }));
	
	        [prevX, prevY] = [currX, currY];
	    });
	} else {
	    canvas.style.pointerEvents = "none";
	    canvas.style.cursor = "not-allowed";
	}
</script>

<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>
	