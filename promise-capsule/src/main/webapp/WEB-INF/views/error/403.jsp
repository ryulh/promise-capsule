<%-- 오류 403, 403 잠김(잠김이면 남은 기간을 보여 준다) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setStatus(403);   // 잠김이면 errLocked, 남은 기간을, 캡슐 화면이 있으면 errCapsuleId를 요청 속성으로 받는다
%>
<c:set var="errCode" value="403"/>
<c:set var="titleKey" value="${errLocked ? 'error.403.locked.title' : 'error.403.title'}"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%@ include file="/WEB-INF/views/error/errorBody.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
