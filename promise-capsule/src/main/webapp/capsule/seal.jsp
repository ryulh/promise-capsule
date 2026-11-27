<%-- 봉인 확인. 미작성자가 있으면 확인란을 체크해야 버튼이 켜지고 서버도 다시 본다. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.ArrayList, java.util.List, dto.Member, dao.MemberDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만, 작성 중일 때만 봉인할 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    if (!state.equals("DRAFT")) {
        stateChanged(request, response, capsule);
        return;
    }
    // 아직 편지를 쓰지 않은 참여자 이름 목록
    List<String> missingNames = new ArrayList<>();
    for (Member m : MemberDAO.getInstance().listByCapsule(capsuleId)) {
        if (!m.getLetterStatus().equals("WRITTEN")) missingNames.add(m.getNickname());
    }
    request.setAttribute("missingNames", missingNames);
    request.setAttribute("sealTarget", capsule);   // 봉인할 캡슐: 아래 폼에서 jsp:getProperty로 번호를 꺼낸다
%>
<jsp:useBean id="sealTarget" class="dto.Capsule" scope="request"/>
<c:set var="titleKey" value="seal.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<fmt:message key="common.interval.${applicationScope.minIntervalUnit}" var="minInterval"><fmt:param value="${applicationScope.minIntervalAmount}"/></fmt:message>
<c:set var="missing" value="${fn:length(missingNames)}"/>
  <main class="page">
    <div class="wrap">
      <div class="confirm-page">
        <a class="small back" href="${ctx}/capsule/capsule.jsp?id=${capsule.id}"><svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-left"/></svg><span><fmt:message key="seal.back"/></span></a>
        <h1><fmt:message key="seal.h1"/></h1>

        <%-- 서버 거절 --%>
        <c:if test="${sealError == 'noLetter'}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body">
            <p><b><fmt:message key="seal.noLetter.title"/></b> <span><fmt:message key="seal.noLetter.body"/></span></p>
            <a class="btn small" href="${ctx}/letter/letter.jsp?id=${capsule.id}"><fmt:message key="seal.noLetter.button"/></a></div></div>
        </c:if>
        <c:if test="${sealError == 'tooSoon'}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body">
            <p><b><fmt:message key="seal.tooSoon.title"/></b> <span><fmt:message key="seal.tooSoon.body"><fmt:param value="${minInterval}"/></fmt:message></span></p>
            <a class="btn small" href="${ctx}/capsule/editCapsule.jsp?id=${capsule.id}"><fmt:message key="seal.tooSoon.button"/></a></div></div>
        </c:if>
        <c:if test="${sealError == 'confirm'}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body">
            <p><b><fmt:message key="seal.confirm.title"/></b> <span><fmt:message key="seal.confirm.body"/></span></p></div></div>
        </c:if>

        <%-- 참여 인원, 편지 수 요약 --%>
        <section class="box">
          <dl class="facts">
            <dt><fmt:message key="seal.capsule"/></dt><dd><c:out value="${capsule.title}"/></dd>
            <dt><fmt:message key="seal.opensOn"/></dt><dd><span><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></span></dd>
            <dt><fmt:message key="seal.letters"/></dt>
            <dd><c:choose>
              <c:when test="${capsule.letterCount == 0}"><fmt:message key="seal.writtenNone"/></c:when>
              <c:when test="${missing == 0}"><fmt:message key="seal.writtenAll"><fmt:param value="${capsule.memberCount}"/></fmt:message></c:when>
              <c:otherwise><fmt:message key="seal.writtenSome"><fmt:param value="${capsule.memberCount}"/><fmt:param value="${capsule.letterCount}"/></fmt:message></c:otherwise>
            </c:choose></dd>
          </dl>
        </section>

        <%-- 미작성자 이름 --%>
        <c:if test="${missing > 0 && capsule.letterCount > 0}">
          <section class="box">
            <h2><fmt:message key="seal.missing"><fmt:param value="${missing}"/></fmt:message></h2>
            <ul class="missing-list"><c:forEach var="name" items="${missingNames}"><li><c:out value="${name}"/></li></c:forEach></ul>
            <p class="small muted flush mt-3"><fmt:message key="seal.missingNote"/></p>
          </section>
        </c:if>

        <%-- 봉인하면 일어나는 일과 봉인 버튼 --%>
        <c:if test="${capsule.letterCount > 0}">
          <section class="box soft">
            <h2><fmt:message key="seal.after"/></h2>
            <ul class="consequences">
              <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-pencil"/></svg><span><fmt:message key="seal.after1"/></span></li>
              <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="seal.after2"/></span></li>
              <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-link"/></svg><span><fmt:message key="seal.after3"/></span></li>
              <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-calendar"/></svg><span><fmt:message key="seal.after4"/></span></li>
            </ul>
            <p class="flush mt-3"><b><fmt:message key="seal.afterFinal"/></b></p>
          </section>

          <form class="confirm-actions" method="post" action="${ctx}/capsule/processSeal.jsp">
            <input type="hidden" name="capsuleId" value="<jsp:getProperty name="sealTarget" property="id"/>">
            <c:if test="${missing > 0}">
              <label class="check ack">
                <input type="checkbox" id="ack" name="confirmMissing" value="true" aria-describedby="sealHint">
                <span><fmt:message key="seal.ack"><fmt:param value="${missing}"/></fmt:message></span>
              </label>
            </c:if>
            <div class="confirm-buttons">
              <button class="btn primary" type="submit" id="sealBtn"${missing > 0 ? ' disabled' : ''}><fmt:message key="seal.seal"/></button>
              <a class="btn" href="${ctx}/capsule/capsule.jsp?id=${capsule.id}"><fmt:message key="seal.notYet"/></a>
            </div>
            <c:if test="${missing > 0}"><span class="small muted hint" id="sealHint"><fmt:message key="seal.hint"/></span></c:if>
          </form>
        </c:if>
      </div>
    </div>
  </main>
<script>
  /* 확인란을 체크해야 봉인 버튼 활성 */
  (function () {
    var ack = document.getElementById("ack"), btn = document.getElementById("sealBtn"), hint = document.getElementById("sealHint");
    if (!ack) return;
    ack.addEventListener("change", function () {
      btn.disabled = !ack.checked;
      hint.style.visibility = ack.checked ? "hidden" : "visible";
    });
  })();
</script>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
