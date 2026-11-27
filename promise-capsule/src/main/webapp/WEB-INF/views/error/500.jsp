<%-- 오류 500. 예외는 로그에만 남기고 화면에는 일반 문구만. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setStatus(500);
%>
<c:set var="errCode" value="500"/>
<c:set var="titleKey" value="error.500.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%@ include file="/WEB-INF/views/error/errorBody.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
