<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageTitle" value="캐치마인드" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>




		<div class="main_btn">
		<button class="btn btn-active btn-primary">캐치마인드</button>
		</div>


<canvas id="canvas" class ="board" width="700px" height="700px">
</canvas>


		<div class="controls">
			<div class="controls_range">
				<input type="range" id="jsRange" min="0.1" max="5.0" value="2.5" step="0.1" />
			</div>
			<div class="controls_btns">
				<button id="jsfill">Fill</button>
				<button id="jssave">Save</button>
			</div>
			<div class="colors" id="Jcolor">
				<div class="colors jsColor" style="background-color:black;"></div>
				<div class="colors jsColor" style="background-color: white;"></div>
				<div class="colors jsColor" style="background-color: red;"></div>
				<div class="colors jsColor" style="background-color: orange;"></div>
				<div class="colors jsColor" style="background-color: yellow;"></div>
				<div class="colors jsColor" style="background-color: green;"></div>
				<div class="colors jsColor" style="background-color: blue;"></div>			
				<div class="colors jsColor" style="background-color: navy"></div>
				<div class="colors jsColor" style="background-color: purple;"></div>
			</div>
		</div >



		<script>
			const canvas = document.getElementById("canvas");
			const ctx = canvas.getContext("2d");
			const colors = document.getElementById("jsColor");
			const range = document.getElementById("jsRange");
			
			
			  let painting = false;
			    
			    function stopPainting(){
			        painting=false;
			    }
			    
			    
			    
			    function startPainting(){
			    	painting = true;
			    }
			    
			    
			    
			    function onMouseMove(event){
			        
			        const x = event.offsetX;
			        const y = event.offsetY;
			        
			        if(!painting){
			            ctx.beginPath();
			            ctx.moveTo(x,y);
			        }else{
			            ctx.lineTo(x,y);
			            ctx.stroke();
			        }
			    }
			        
			        

			    
			    function handleColorClick(event){
			        const color = event.target.style.backgroundColor;
			        ctx.strokeStyle = color;
			    }
				
			
			    
			    function handleRangeChange(event){
			        const size = event.target.value;
			        ctx.lineWidth = size;
			    }
				
			    
			    
			if (canvas) {
			  canvas.addEventListener("mousemove", onMouseMove);
			  canvas.addEventListener("mousedown", startPainting);
			  canvas.addEventListener("mouseup", stopPainting);
			  canvas.addEventListener("mouseleave", stopPainting);

			}
			
			Array.from(colors => 
			color.forEach(color.addEventListener("click", handleColorClick));
			
			

		</script>






<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>