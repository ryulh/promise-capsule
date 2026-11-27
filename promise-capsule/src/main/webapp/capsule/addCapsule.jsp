<%-- 캡슐 만들기(폼은 capsuleForm.jsp 공용) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<c:set var="titleKey" value="capsuleForm.title.create"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <jsp:include page="/WEB-INF/includes/capsuleForm.jsp"><jsp:param name="mode" value="create"/></jsp:include>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
