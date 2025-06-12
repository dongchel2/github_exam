<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<c:set var="pageTitle" value="캐치마인드" />
<%@ include file="/WEB-INS/jsp/common/header.jsp" %>

<div>캐치마인드</div>
  <div class="bg-white shadow-lg rounded-xl p-10 w-full max-w-md text-center">
        <h1 class="text-3xl font-bold text-purple-700 mb-4">🎨 캐치마인드</h1>
        <p class="text-gray-600 mb-6">그림 보고 단어 맞춰봐요</p>

        <form action="/usr/home/game" method="post" class="space-y-4">
            <input type="text" name="nickname" placeholder="닉네임 입력"
                   class="w-full px-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500" required />
           	<button  type="submit"
         			 class="btn btn-xs sm:btn-sm md:btn-md lg:btn-lg xl:btn-xl  margin-bottom: 30px;">PLAY</button>
        </form>
    </div>








<%@ include file="/WEB-INS/jsp/common/footer.jsp" %>