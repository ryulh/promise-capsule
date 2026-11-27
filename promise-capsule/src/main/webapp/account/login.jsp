<%-- 로그인. 맥락 줄: 초대에서 옴, 열림 메일에서 옴, 세션 만료 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dto.Capsule, dao.CapsuleDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    // 이미 로그인했으면 가려던 곳(없으면 내 캡슐)으로
    if (session.getAttribute("userId") != null) {
        String back = (String) session.getAttribute("returnTo");
        session.removeAttribute("returnTo");
        response.sendRedirect(request.getContextPath() + (back != null ? back : "/capsule/capsules.jsp"));
        return;
    }
    // 초대 링크로 들어왔으면 어느 캡슐인지 보여 준다(봉인 전 캡슐만)
    String code = (String) session.getAttribute("inviteCode");
    if (code != null) {
        Capsule invite = CapsuleDAO.getInstance().findByInviteCode(code, 0);
        if (invite != null && "DRAFT".equals(invite.getStatus())) request.setAttribute("invite", invite);
    }
    // 메일 링크에서 왔는지, 세션이 만료됐는지 맥락 줄에 쓴다
    String returnTo = (String) session.getAttribute("returnTo");
    request.setAttribute("fromMail", returnTo != null && returnTo.startsWith("/capsule/capsule.jsp?") && returnTo.contains("from=mail"));
    request.setAttribute("expired", "expired".equals(session.getAttribute("loginReason")));
%>
<c:set var="titleKey" value="login.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <form class="form-page" method="post" action="${ctx}/account/processLogin.jsp" data-validate onsubmit="return checkForm(this)" novalidate>
        <%-- 맥락 줄(초대, 메일, 만료 중 하나) --%>
        <c:choose>
          <c:when test="${not empty invite}">
            <div class="context-strip"><img class="art r1x1" alt="" src="${ctx}/assets/img/img-05.webp"><span><span><fmt:message key="login.invite"/></span> · <b><c:out value="${invite.title}"/></b></span></div>
          </c:when>
          <c:when test="${fromMail}">
            <div class="context-strip"><img class="art r1x1" alt="" src="${ctx}/assets/img/img-05.webp"><span><fmt:message key="login.mail"/></span></div>
          </c:when>
          <c:when test="${expired}">
            <div class="banner"><svg class="ic" aria-hidden="true"><use href="${icons}#i-timer"/></svg><div class="body"><p><fmt:message key="login.expired"/></p></div></div>
          </c:when>
        </c:choose>

        <h1><fmt:message key="login.title"/></h1>

        <%-- 로그인 실패 안내 --%>
        <c:if test="${not empty errors.form}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body"><p><fmt:message key="${errors.form}"/></p></div></div>
        </c:if>

<%
    // 아이디 저장 쿠키(savedId) 읽기
    String savedId = "";
    Cookie[] loginCookies = request.getCookies();
    if (loginCookies != null) {
        for (Cookie loginCookie : loginCookies) {
            if ("savedId".equals(loginCookie.getName())) {
                savedId = loginCookie.getValue();
            }
        }
    }
    pageContext.setAttribute("savedId", savedId);
%>
        <%-- 아이디 칸: 방금 입력한 값, 없으면 저장된 아이디 --%>
        <c:set var="idValue" value="${not empty param.loginId ? param.loginId : savedId}"/>
        <div class="fieldset">
          <div class="field">
            <label for="loginId"><fmt:message key="login.loginId"/></label>
            <input id="loginId" name="loginId" type="text" autocomplete="username" autocapitalize="none" maxlength="20" value="${fn:escapeXml(idValue)}" data-v="required"${empty idValue ? ' autofocus' : ''}>
            <div class="err" data-err hidden><fmt:message key="login.loginId.empty"/></div>
          </div>
          <div class="field">
            <label for="password"><fmt:message key="login.password"/></label>
            <input id="password" name="password" type="password" autocomplete="current-password" maxlength="64" data-v="required"${empty idValue ? '' : ' autofocus'}>
            <div class="err" data-err hidden><fmt:message key="login.password.empty"/></div>
          </div>
          <label class="check">
            <input type="checkbox" name="saveId" value="on"${not empty savedId ? ' checked' : ''}>
            <span><fmt:message key="login.saveId"/></span>
          </label>
        </div>

        <button class="btn primary block" type="submit"><fmt:message key="${not empty invite ? 'login.submit.invite' : fromMail ? 'login.submit.mail' : 'login.submit'}"/></button>
        <p class="form-foot"><span><fmt:message key="login.newHere"/></span> <a href="${ctx}/account/signup.jsp"><fmt:message key="login.signup"/></a></p>
      </form>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
