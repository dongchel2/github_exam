<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="캐치마인드" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>

<!--  외부 CSS 연결 -->
<link rel="stylesheet" type="text/css" href="/resources/catch.css" />

<!-- 중앙 정렬 래퍼 -->
<div class="main-wrapper">
    <div class="main-box">
        <h1>🐱 캐치마인드</h1>
        <p>테스트 페이지</p>

        <!-- 닉네임 입력 폼 -->
        <form action="/usr/home/game" method="post">
            <input type="text" name="nickname" placeholder="닉네임 입력" required />
   			<button  type="submit"
            class="btn btn-xs sm:btn-sm md:btn-md lg:btn-lg xl:btn-xl  margin-bottom: 30px;">PLAY</button>
        </form>
    </div>
</div>

<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>
