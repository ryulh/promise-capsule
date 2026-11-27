<%-- 내 정보 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dao.UserDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // 내 회원 정보를 읽어 화면에 넘긴다
    request.setAttribute("me", UserDAO.getInstance().findById(userId));
%>
<c:set var="titleKey" value="me.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%-- 규칙 실패로 돌아왔으면 입력값을, 아니면 저장된 값을 보여 준다 --%>
<c:set var="nickValue" value="${not empty errors ? param.nickname : me.nickname}"/>
<c:set var="emailValue" value="${not empty errors ? param.email : me.email}"/>
<c:set var="notifyOn" value="${not empty errors ? param.notifyOnOpen == 'on' : me.notifyOnOpen}"/>
  <main class="page">
    <div class="wrap">
      <form class="form-page" method="post" action="${ctx}/account/processMe.jsp" data-validate onsubmit="return checkForm(this)" novalidate>
        <h1><fmt:message key="me.h1"/></h1>
        <%@ include file="/WEB-INF/includes/notice.jsp" %>

        <fieldset class="fieldset">
          <%-- 아이디(바꿀 수 없음) --%>
          <legend><fmt:message key="me.group.account"/></legend>
          <div class="field">
            <span class="label"><fmt:message key="me.loginId"/></span>
            <span><c:out value="${me.loginId}"/> <span class="small muted"><fmt:message key="me.loginId.fixed"/></span></span>
          </div>
        </fieldset>

        <fieldset class="fieldset">
          <%-- 닉네임(이미 있으면 서버 오류 문구) --%>
          <legend><fmt:message key="me.group.name"/></legend>
          <div class="field${not empty errors.nickname ? ' invalid' : ''}">
            <label for="nickname"><fmt:message key="me.nickname"/></label>
            <input id="nickname" name="nickname" type="text" maxlength="12" value="${fn:escapeXml(nickValue)}" data-v="required min:2 max:12"<c:if test="${not empty errors.nickname}"> aria-invalid="true" aria-describedby="nickname-srv"</c:if>>
            <c:choose>
              <c:when test="${not empty errors.nickname}"><div class="err" id="nickname-srv" data-srv-err><fmt:message key="${errors.nickname}"/></div></c:when>
              <c:otherwise><div class="help"><fmt:message key="me.nickname.help"/></div></c:otherwise>
            </c:choose>
            <div class="err" data-err hidden><fmt:message key="signup.nickname.invalid"/></div>
          </div>
        </fieldset>

        <fieldset class="fieldset">
          <%-- 개봉 알림 메일 켜기, 끄기와 받을 주소 --%>
          <legend><fmt:message key="me.group.notify"/></legend>
          <label class="check">
            <input type="checkbox" id="notifyOnOpen" name="notifyOnOpen" value="on"${notifyOn ? ' checked' : ''}>
            <span><b><fmt:message key="me.notify"/></b><br><span class="small muted"><fmt:message key="me.notify.help"/></span></span>
          </label>
          <p class="small flush" id="notifyOff"${notifyOn ? ' hidden' : ''}><fmt:message key="me.notify.off"/></p>
          <div class="field">
            <label for="email"><fmt:message key="me.email"/></label>
            <input id="email" name="email" type="email" inputmode="email" maxlength="100" value="${fn:escapeXml(emailValue)}" data-v="required email max:100">
            <div class="help"><fmt:message key="me.email.help"/></div>
            <div class="err" data-err hidden><fmt:message key="me.email.invalid"/></div>
          </div>
        </fieldset>

        <div class="write-actions">
          <button class="btn primary" type="submit"><fmt:message key="me.save"/></button>
          <a class="btn" href="${ctx}/capsule/capsules.jsp"><fmt:message key="me.cancel"/></a>
        </div>
      </form>
    </div>
  </main>
<script>
  /* 알림 끄기를 풀면 결과 한 줄 표시 */
  (function () {
    var box = document.getElementById("notifyOnOpen"), off = document.getElementById("notifyOff");
    box.addEventListener("change", function () { off.hidden = box.checked; });
  })();
</script>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
