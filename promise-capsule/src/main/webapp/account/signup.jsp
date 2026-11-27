<%-- 회원가입 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dto.Capsule, dao.CapsuleDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // 이미 로그인했으면 내 캡슐로
    if (session.getAttribute("userId") != null) {
        response.sendRedirect(request.getContextPath() + "/capsule/capsules.jsp");
        return;
    }
    // 초대 링크로 들어왔으면 어느 캡슐인지 보여 준다(봉인 전 캡슐만)
    String code = (String) session.getAttribute("inviteCode");
    if (code != null) {
        Capsule invite = CapsuleDAO.getInstance().findByInviteCode(code, 0);
        if (invite != null && "DRAFT".equals(invite.getStatus())) request.setAttribute("invite", invite);
    }
%>
<c:set var="titleKey" value="signup.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <form class="form-page" method="post" action="${ctx}/account/processSignup.jsp" data-validate onsubmit="return checkForm(this)" novalidate>
        <c:if test="${not empty invite}">
          <div class="context-strip"><img class="art r1x1" alt="" src="${ctx}/assets/img/img-05.webp">
            <span><span><fmt:message key="signup.invite"/></span> · <b><c:out value="${invite.title}"/></b> <span class="muted"><fmt:message key="signup.inviteFrom"><fmt:param><c:out value="${invite.ownerNickname}"/></fmt:param></fmt:message></span></span></div>
        </c:if>

        <h1><fmt:message key="signup.h1"/></h1>
        <p class="muted flush"><fmt:message key="signup.lead"/></p>

        <fmt:message key="signup.summary" var="summaryTemplate"/>
        <div class="banner error" data-summary data-template="${fn:escapeXml(summaryTemplate)}" role="alert" hidden><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body"><p></p></div></div>
        <%-- 서버에서 돌려보낸 경우(아이디, 닉네임 중복) 안내 --%>
        <c:if test="${not empty errors}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body"><p><fmt:message key="${not empty errors.loginId and not empty errors.nickname ? 'signup.dup' : not empty errors.loginId ? 'signup.dupLoginId' : 'signup.dupNickname'}"/></p></div></div>
        </c:if>

        <fieldset class="fieldset">
          <%-- 아이디, 비밀번호 --%>
          <legend><fmt:message key="signup.group.login"/></legend>
          <div class="field${not empty errors.loginId ? ' invalid' : ''}">
            <label for="loginId"><fmt:message key="signup.loginId"/></label>
            <input id="loginId" name="loginId" type="text" autocomplete="username" autocapitalize="none" maxlength="20" value="${fn:escapeXml(param.loginId)}" data-notrim data-v="required min:4 max:20 pattern:^[a-z0-9_]+$"<c:if test="${not empty errors.loginId}"> aria-invalid="true" aria-describedby="loginId-srv"</c:if>>
            <div class="help"><fmt:message key="signup.loginId.help"/></div>
            <div class="err" data-err hidden><fmt:message key="signup.loginId.invalid"/></div>
            <c:if test="${not empty errors.loginId}"><div class="err" id="loginId-srv" data-srv-err><fmt:message key="${errors.loginId}"/></div></c:if>
          </div>
          <div class="field">
            <label for="password"><fmt:message key="signup.password"/></label>
            <input id="password" name="password" type="password" autocomplete="new-password" maxlength="64" data-v="required min:8 max:64 pattern:^(?=.*[A-Za-z])(?=.*[0-9])">
            <ul class="rules" id="pwRules" aria-live="polite">
              <li data-rule="length"><fmt:message key="signup.rule.length"/></li><li data-rule="letter"><fmt:message key="signup.rule.letter"/></li><li data-rule="number"><fmt:message key="signup.rule.number"/></li>
            </ul>
            <c:if test="${not empty errors}"><div class="help"><fmt:message key="signup.password.again"/></div></c:if>
            <div class="err" data-err hidden><fmt:message key="signup.password.invalid"/></div>
          </div>
          <div class="field">
            <label for="passwordConfirm"><fmt:message key="signup.confirm"/></label>
            <input id="passwordConfirm" name="passwordConfirm" type="password" autocomplete="new-password" maxlength="64" data-v="required same:#password">
            <div class="help ok" id="pwMatch" hidden><svg class="ic" aria-hidden="true"><use href="${icons}#i-check"/></svg><span><fmt:message key="signup.confirm.ok"/></span></div>
            <div class="err" data-err hidden><fmt:message key="signup.confirm.invalid"/></div>
          </div>
        </fieldset>

        <fieldset class="fieldset">
          <legend><fmt:message key="signup.group.name"/></legend>
          <div class="field${not empty errors.nickname ? ' invalid' : ''}">
            <label for="nickname"><fmt:message key="signup.nickname"/></label>
            <input id="nickname" name="nickname" type="text" autocomplete="nickname" maxlength="12" value="${fn:escapeXml(param.nickname)}" data-v="required min:2 max:12"<c:if test="${not empty errors.nickname}"> aria-invalid="true" aria-describedby="nickname-srv"</c:if>>
            <c:choose>
              <c:when test="${not empty errors.nickname}">
                <div class="err" id="nickname-srv" data-srv-err><fmt:message key="${errors.nickname}"/></div>
                <div class="help"><fmt:message key="signup.nickname.tip"/></div>
              </c:when>
              <c:otherwise><div class="help"><fmt:message key="signup.nickname.help"/></div></c:otherwise>
            </c:choose>
            <div class="err" data-err hidden><fmt:message key="signup.nickname.invalid"/></div>
          </div>
        </fieldset>

        <fieldset class="fieldset">
          <legend><fmt:message key="signup.group.email"/></legend>
          <div class="field">
            <label for="email"><fmt:message key="signup.email"/></label>
            <input id="email" name="email" type="email" autocomplete="email" inputmode="email" maxlength="100" value="${fn:escapeXml(param.email)}" data-v="required email max:100">
            <div class="help"><fmt:message key="signup.email.help"/></div>
            <div class="err" data-err hidden><fmt:message key="signup.email.invalid"/></div>
          </div>
        </fieldset>

        <button class="btn primary block" type="submit"><fmt:message key="${not empty invite ? 'signup.submit.invite' : 'signup.submit'}"/></button>
        <p class="form-foot"><span><fmt:message key="signup.haveAccount"/></span> <a href="${ctx}/account/login.jsp"><fmt:message key="signup.login"/></a></p>
      </form>
    </div>
  </main>
<script>
  /* 비밀번호 규칙 3개 실시간 표시 + 확인 칸 일치 표시 */
  (function () {
    var pw = document.getElementById("password"), cf = document.getElementById("passwordConfirm");
    var rules = { length: function (v) { return v.length >= 8; }, letter: function (v) { return /[A-Za-z]/.test(v); }, number: function (v) { return /[0-9]/.test(v); } };
    var match = document.getElementById("pwMatch");
    function update() {
      document.querySelectorAll("#pwRules li").forEach(function (li) { li.classList.toggle("ok", rules[li.dataset.rule](pw.value)); });
      match.hidden = !(cf.value && cf.value === pw.value);
    }
    pw.addEventListener("input", update);
    cf.addEventListener("input", update);
  })();
</script>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
