<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageTitle" value="캐치마인드" />

<%@ include file="/WEB-INS/jsp/common/header.jsp" %>







<div>캐치마인드 메인페이지</div>


<canvas id="canvas">

</canvas>

	    <div id="palette">
		  <button class="red">red</button>
  	      <button class="orange">orange</button>
	      <span class="orange">orange</span>
	      <span class="yellow">yellow</span>
	      <span class="green">green</span>
	      <span class="blue">blue</span>
	      <span class="navy">navy</span>
	      <span class="purple">purple</span>
	      <span class="black">black</span>
	      <span class="white">white</span>
	      <span class="clear">clear</span>
	      <span class="fill">fill</span>
	    </div>


<script>
const canvas = document.querySelector("#canvas");
const ctx = canvas.getContext("2d");
canvas.width = innerWidth;
canvas.height = innerHeight;

const width = innerWidth - 90;
const height = innerHeight - 260;

canvas.width = width;
canvas.height = height;
canvas.style.margin = "20px";
canvas.style.border = "3px double";
canvas.style.cursor = 'pointer';

let painting = false;

function stopPainting(event) {
  painting = false;
}

function startPainting() {
  painting = true;
}

ctx.lineWidth = 3;
function onMouseMove(event) {
  const x = event.offsetX;
  const y = event.offsetY;
  if (!painting) {
    ctx.beginPath();
    ctx.moveTo(x, y);
  } else {
    ctx.lineTo(x, y);
    ctx.stroke();
  }
}

if (canvas) {
  canvas.addEventListener("mousemove", onMouseMove);
  canvas.addEventListener("mousedown", startPainting);
  canvas.addEventListener("mouseup", stopPainting);
  canvas.addEventListener("mouseleave", stopPainting);
}

document.querySelector("#palette").style.marginLeft = "20px";
const buttons = [
  "red",
  "orange",
  "yellow",
  "green",
  "blue",
  "navy",
  "purple",
  "black",
  "white",
  "clear",
  "fill"
];
let lineColor = "black";

buttons.forEach((content) => {
  let button = document.querySelector(`.${content}`);
  
button.style.cursor = 'pointer';
  
  if (content === "clear" || content === "fill") {
    
    button.style.background = "rgba(100,100,100,0.2)";
  } else {
    button.style.background = content;
  }
  button.style.color = "white";
  button.style.display = "inline-block";
  button.style.textShadow =
    "1px 0 black, 0 1px black, 1px 0 black, 0 -1px gray";
  button.style.lineHeight = "40px";
  button.style.textAlign = "center";
  button.style.width = "50px";
  button.style.height = "50px";
  button.style.borderRadius = "25px";
  button.style.border = "4px solid rgba(129, 101, 101, 0.151)";
  button.style.boxShadow = "1px 2px 2px gray";
  button.style.marginBottom = "10px";

  button.onclick = () => {
    ctx.strokeStyle = content;
    lineColor = content;
  };
});

document.querySelector(".clear").onclick = () => {
  ctx.clearRect(0, 0, width, height);
};

document.querySelector(".fill").onclick = () => {
  ctx.fillStyle = lineColor;
  ctx.fillRect(0, 0, width, height);
};

<!-- 요거 그림판은 되는데 색깔은 안되는 이유-->
<!-- 자바스크립트에서 생성된 변수는 jsp에서 사용이 제한됨 why? 시점의 차이-->

</script>




<div class="main_btn">
<button class="btn btn-active btn-primary">PLAY</button>
</div>











<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>