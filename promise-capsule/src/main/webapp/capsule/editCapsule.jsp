<%-- 캡슐 정보 수정 / 여는 날 다시 정하기(기한 경과면 mode=overdue) --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만, 봉인 전에만 고칠 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 기한이 지났으면 여는 날 다시 정하기 화면으로 쓴다
    request.setAttribute("mode", state.equals("OVERDUE") ? "overdue" : "edit");
%>
<c:set var="titleKey" value="capsuleForm.title.${mode}"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <jsp:include page="/WEB-INF/includes/capsuleForm.jsp"><jsp:param name="mode" value="${mode}"/></jsp:include>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
