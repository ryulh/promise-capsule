<%-- 오류 404 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setStatus(404);
%>
<c:set var="errCode" value="404"/>
<c:set var="titleKey" value="error.404.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%@ include file="/WEB-INF/views/error/errorBody.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
