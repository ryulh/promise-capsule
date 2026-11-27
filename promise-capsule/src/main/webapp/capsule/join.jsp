<%-- 초대 안내 / 참여 확인. 비로그인이면 초대 코드를 세션에 두고 가입, 로그인 뒤 돌아온다. 무효, 봉인이면 캡슐 정보를 보여 주지 않는다. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dto.Capsule, dao.CapsuleDAO, dao.MemberDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    Integer userId = (Integer) session.getAttribute("userId");   // 로그인하지 않아도 볼 수 있다
    // 초대 코드로 캡슐을 찾는다(주소에 없으면 세션에 둔 코드)
    String code = request.getParameter("code");
    if (code == null) code = (String) session.getAttribute("inviteCode");
    Capsule invite = code == null ? null : CapsuleDAO.getInstance().findByInviteCode(code, userId == null ? 0 : userId);
    if (invite != null && userId != null && MemberDAO.getInstance().exists(invite.getId(), userId)) {
        session.removeAttribute("inviteCode");   // 이미 참여 중이면 캡슐로
        response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + invite.getId());
        return;
    }
    // 초대 상태: 무효, 봉인됨, 정원 참, 참여 가능
    String status;
    if (invite == null) status = "INVALID";
    else if (!"DRAFT".equals(invite.getStatus())) status = "SEALED";
    else status = invite.isFull() ? "FULL" : "VALID";
    if (request.getAttribute("joinStatus") != null) status = (String) request.getAttribute("joinStatus");   // 참여 처리 중 그사이 바뀐 경우
    if (userId == null && (status.equals("VALID") || status.equals("FULL"))) {
        session.setAttribute("inviteCode", code);   // 가입, 로그인 뒤 이 화면으로 돌아온다
        session.removeAttribute("returnTo");
    }
    // 화면에 넘긴다
    request.setAttribute("invite", invite);
    request.setAttribute("inviteStatus", status);
%>
<c:set var="titleKey" value="join.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<c:set var="st" value="${inviteStatus}"/>
  <main class="page">
    <div class="wrap">
      <%-- 참여 가능 또는 정원 참: 캡슐 정보를 보여 준다 --%>
      <c:choose>
        <c:when test="${st == 'VALID' || st == 'FULL'}">
          <div class="invite-card">
            <span class="eyebrow"><fmt:message key="join.eyebrow"/></span>
            <img class="art r1x1" alt="" src="${ctx}/assets/img/img-05.webp">
            <h1><span><fmt:message key="join.invitedBy"><fmt:param><c:out value="${invite.ownerNickname}"/></fmt:param></fmt:message></span></h1>
            <div class="cap-title"><c:out value="${invite.title}"/></div>
            <div class="facts-inline"><span><c:choose><c:when test="${st == 'FULL'}"><fmt:message key="join.fullLine"/></c:when><c:otherwise><fmt:message key="join.joined"><fmt:param value="${invite.memberCount}"/></fmt:message></c:otherwise></c:choose></span></div>
            <c:choose>
              <c:when test="${st == 'VALID'}">
                <div class="box soft what">
                  <ul class="consequences">
                    <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-mail"/></svg><span><fmt:message key="join.what1"/></span></li>
                    <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="join.what2"/></span></li>
                  </ul>
                </div>
                <%-- 로그인 전이면 가입, 로그인 버튼, 로그인했으면 참여 버튼 --%>
                <c:choose>
                  <c:when test="${not loggedIn}">
                    <div class="actions">
                      <a class="btn primary block" href="${ctx}/account/signup.jsp"><fmt:message key="join.signupJoin"/></a>
                      <a class="btn block" href="${ctx}/account/login.jsp"><fmt:message key="join.loginJoin"/></a>
                      <span class="small muted"><fmt:message key="join.comeBack"/></span>
                    </div>
                  </c:when>
                  <c:otherwise>
                    <form class="actions" method="post" action="${ctx}/capsule/processJoin.jsp">
                      <input type="hidden" name="code" value="${fn:escapeXml(invite.inviteCode)}">
                      <button class="btn primary block" type="submit"><fmt:message key="join.join"/></button>
                      <a class="btn ghost" href="${ctx}/capsule/capsules.jsp"><fmt:message key="join.notNow"/></a>
                    </form>
                  </c:otherwise>
                </c:choose>
              </c:when>
              <c:otherwise>
                <div class="banner warn"><svg class="ic" aria-hidden="true"><use href="${icons}#i-triangle-alert"/></svg><div class="body">
                  <p><b><fmt:message key="join.full.title"/></b> <span><fmt:message key="join.full.body"/></span></p></div></div>
                <c:choose>
                  <c:when test="${loggedIn}"><a class="btn block" href="${ctx}/capsule/capsules.jsp"><fmt:message key="join.toCapsules"/></a></c:when>
                  <c:otherwise><a class="btn block" href="${ctx}/index.jsp"><fmt:message key="join.about"/></a></c:otherwise>
                </c:choose>
              </c:otherwise>
            </c:choose>
          </div>
        </c:when>
        <c:otherwise>
          <%-- 거절: 캡슐 정보 없이 --%>
          <c:set var="rej" value="${st == 'SEALED' ? 'sealed' : 'invalid'}"/>
          <div class="invite-card">
            <img class="art r1x1" alt="" src="${ctx}/assets/img/${rej == 'sealed' ? 'img-03' : 'img-06'}.webp">
            <h1><fmt:message key="join.${rej}.title"/></h1>
            <p class="muted flush"><fmt:message key="join.${rej}.body"/></p>
            <div class="actions">
              <c:choose>
                <c:when test="${loggedIn}"><a class="btn primary block" href="${ctx}/capsule/capsules.jsp"><fmt:message key="join.toCapsules"/></a></c:when>
                <c:otherwise><a class="btn primary block" href="${ctx}/index.jsp"><fmt:message key="join.about"/></a></c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:otherwise>
      </c:choose>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
