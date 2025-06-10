<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageTitle" value="캐치마인드" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>


 <canvas id="jsCanvas" class="canvas"></canvas>
    <div class="controls">
        <div class="controls__range">
            <input type="range" id="jsRange"
             min="0.1" max="5.0" value="2.5" step="0.1"/>
        </div>
        <div class="controls__btns">
            <button class ="btn_left" id="jsMode">채우기</button>
            <button class="btb_righr" id="jsSave">저장</button></div>
        <div class="controls__colors" id="jsColors">
            <div class="controls__color jsColor" 
                 style="background-color: black;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: white;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: red;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: orange;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: yellow;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: green;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: blue;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: navy;"></div>
            <div class="controls__color jsColor" 
                 style="background-color: purple;"></div>
        </div>
    </div>



		<script>
		const canvas = document.getElementById("jsCanvas");
		const ctx = canvas.getContext("2d");
		const colors = document.getElementsByClassName("jsColor");
		const range = document.getElementById("jsRange");
		const mode = document.getElementById("jsMode");
		const saveBtn = document.getElementById("jsSave");

		const INITIAL_COLOR = "#000000";
		const CANVAS_SIZE = 700;

		ctx.strokeStyle = "#2c2c2c";

		canvas.width = CANVAS_SIZE;
		canvas.height = CANVAS_SIZE;

		ctx.fillStyle = "white";
		ctx.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);

		ctx.strokeStyle = INITIAL_COLOR;
		ctx.fillStyle = INITIAL_COLOR;
		ctx.lineWidth = 2.5; /* 라인 굵기 */

		let painting = false;
		let filling = false;

		function stopPainting() {
		    painting = false;
		}

		function startPainting() {
		    painting = true;
		}

		function onMouseMove(event) {
		    const x = event.offsetX;
		    const y = event.offsetY;
		    if (!painting) {
		        ctx.beginPath();
		        ctx.moveTo(x, y);
		    } else{
		        ctx.lineTo(x, y);
		        ctx.stroke();
		    }
		}

		function handleColorClick(event) {
		  const color = event.target.style.backgroundColor;
		  ctx.strokeStyle = color;
		  ctx.fillStyle = color;
		}

		function handleRangeChange(event) {
		    const size = event.target.value;
		    ctx.lineWidth = size;
		  }

		function handleModeClick() {
		 if (filling === true) {
		   filling = false;
		   mode.innerText = "Fill";
		 } else {
		  filling = true;
		  mode.innerText = "Paint";  
		 }
		}

		function handleCanvasClick() {
		    if (filling) {
		      ctx.fillRect(0, 0, CANVAS_SIZE, CANVAS_SIZE);
		    }
		  }

		// 우클릭 방지
		/*
		function handleCM(event) {
		   event.preventDefault();
		 }
		 */

		function handleSaveClick() {
		  const image = canvas.toDataURL("image/png");
		  const link = document.createElement("a");
		  link.href = image;
		  link.download = "PaintJS[EXPORT]";
		  link.click();
		}

		if (canvas) {
		    canvas.addEventListener("mousemove", onMouseMove);
		    canvas.addEventListener("mousedown", startPainting);
		    canvas.addEventListener("mouseup", stopPainting);
		    canvas.addEventListener("mouseleave", stopPainting);
		    canvas.addEventListener("click", handleCanvasClick);

		}

		Array.from(colors).forEach(color => 
		    color.addEventListener("click", handleColorClick));

		    
		if (range) {
		    range.addEventListener("input", handleRangeChange);
		}
		  
		if (mode) {
		    mode.addEventListener("click", handleModeClick);
		}

		if (saveBtn){
		  saveBtn.addEventListener("click", handleSaveClick);
		}

		</script>






<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>