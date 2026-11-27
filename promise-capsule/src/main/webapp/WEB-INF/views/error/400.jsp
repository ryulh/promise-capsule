<%-- 오류 400 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    response.setStatus(400);
%>
<c:set var="errCode" value="400"/>
<c:set var="titleKey" value="error.400.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%@ include file="/WEB-INF/views/error/errorBody.jsp" %>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
