<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="pageTitle" value="캐치마인드 입장" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>

<div class="main-wrapper">
    <div class="main-box">
        <h1>🐱 캐치마인드</h1>
        <p>닉네임을 입력하고 게임에 참여하세요!</p>

        <form action="/usr/home/game" method="post">
            <input type="text" name="nickname" placeholder="닉네임 입력" required />
            <button type="submit" class="btn btn-lg btn-primary mt-4">게임 시작</button>
        </form>
    </div>
</div>

<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>
