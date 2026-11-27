<%-- 캡슐 상세(잠김). 남은 시간은 서버가 준 초에서 줄이기만 하고, 0초가 되면 같은 주소를 다시 불러온다. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%!
    /** 잠김 배지 문구: 0 이하면 D-DAY, 아니면 D-n */
    private String dDayLabel(long days) {
        return days <= 0 ? "D-DAY" : "D-" + days;
    }
%>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="icons" value="${ctx}/assets/img/icons.svg"/>
<fmt:message key="common.date.longTime" var="longPattern"/>
<fmt:formatDate var="openLong" value="${capsule.openAt}" pattern="${longPattern}" timeZone="Asia/Seoul"/>
<c:set var="dDay" value="${capsule.DDay}"/>

      <div class="cap-head">
        <div class="title-row">
          <h1><c:out value="${capsule.title}"/></h1>
          <span class="badge locked"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="common.badge.locked"/></span></span>
          <span class="badge dday"><%= dDayLabel((Long) pageContext.getAttribute("dDay")) %></span>
        </div>
        <c:if test="${not empty capsule.description}"><p class="muted flush"><c:out value="${capsule.description}"/></p></c:if>
        <div class="meta">
          <span><span><fmt:message key="draft.opensOn"/></span> <b><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></span>
          <span><span><fmt:message key="locked.sealedOn"/></span> <b><fmt:formatDate value="${capsule.sealedAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></span>
          <span><span><fmt:message key="draft.members"/></span> <b><fmt:message key="common.people"><fmt:param value="${capsule.memberCount}"/></fmt:message></b></span>
        </div>
      </div>

      <div class="stack mt-4">
        <%-- 안내 띠: 방금 봉인함 / 지금 상태 --%>
        <c:choose>
          <c:when test="${notice == 'locked.notice.sealed'}">
            <div class="banner success" role="status"><svg class="ic" aria-hidden="true"><use href="${icons}#i-check"/></svg><div class="body"><p><fmt:message key="locked.notice.sealed"><fmt:param value="${openLong}"/></fmt:message></p></div></div>
          </c:when>
          <c:otherwise><%@ include file="/WEB-INF/includes/notice.jsp" %></c:otherwise>
        </c:choose>
      </div>

      <%-- 자물쇠 + 남은 시간 --%>
      <section class="lock-hero" aria-label="<fmt:message key='locked.remaining'/>">
        <img class="art r1x1" alt="" src="${ctx}/assets/img/img-03.webp">
        <div id="countBlock">
          <p class="muted flush mb-2"><fmt:message key="locked.opensIn"/></p>
          <div class="countdown" id="countdown" data-seconds="${capsule.remainingSeconds}" aria-hidden="true">
            <span class="u" data-unit="d"><span class="n" data-v="d"></span><span class="l"><fmt:message key="locked.days"/></span></span>
            <span class="u"><span class="n" data-v="h"></span><span class="l"><fmt:message key="locked.hours"/></span></span>
            <span class="u"><span class="n" data-v="m"></span><span class="l"><fmt:message key="locked.minutes"/></span></span>
            <span class="u"><span class="n" data-v="s"></span><span class="l"><fmt:message key="locked.seconds"/></span></span>
          </div>
        </div>
        <p class="small" id="recount" hidden><fmt:message key="locked.recount"/></p>
        <div class="opening" id="opening" role="status" hidden>
          <span class="spin" aria-hidden="true"></span>
          <b><fmt:message key="locked.opening"/></b>
        </div>
        <p class="opens-line flush"><span><fmt:message key="locked.opensTogether"/></span> <b><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></p>
        <p class="small muted with-ic flush"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="locked.lockNote"/></span></p>
      </section>

      <%-- 참여자: 이름, 작성 여부만 --%>
      <section class="sec">
        <div class="section-head"><h2><fmt:message key="locked.membersTitle"/></h2><span class="aside"><fmt:message key="common.letters"><fmt:param value="${capsule.letterCount}"/></fmt:message></span></div>
        <div class="box">
          <ul class="status-list">
            <c:forEach var="m" items="${members}">
              <li${(m.userId == sessionScope.userId) ? ' class="mine-row"' : ''}><span class="nm"><c:out value="${m.nickname}"/><c:if test="${m.userId == capsule.ownerId}"> <span class="badge plain"><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg><span><fmt:message key="common.creator"/></span></span></c:if><c:if test="${m.userId == sessionScope.userId}"> <span class="me-tag"><fmt:message key="common.me"/></span><c:if test="${canWithdraw}"> <a class="link-quiet" data-hide-when-opening href="${ctx}/letter/withdraw.jsp?id=${capsule.id}"><fmt:message key="locked.withdraw"/></a></c:if></c:if></span>
                <c:choose>
                  <c:when test="${m.letterStatus == 'WRITTEN'}"><span class="badge plain"><svg class="ic env" aria-hidden="true"><use href="${icons}#i-env-sealed"/></svg><span><fmt:message key="locked.sealedBadge"/></span></span></c:when>
                  <c:when test="${m.letterStatus == 'WITHDRAWN'}"><span class="badge withdrawn"><svg class="ic env" aria-hidden="true"><use href="${icons}#i-env-open"/></svg><span><fmt:message key="locked.erased"/></span></span></c:when>
                  <c:otherwise><span class="badge plain"><svg class="ic env" aria-hidden="true"><use href="${icons}#i-env-empty"/></svg><span><fmt:message key="locked.noLetter"/></span></span></c:otherwise>
                </c:choose>
              </li>
            </c:forEach>
          </ul>
        </div>
      </section>

<c:if test="${sealAnim}">
  <fmt:message key="seal.anim" var="sealCaption"><fmt:param value="${openLong}"/></fmt:message>
  <%@ include file="/WEB-INF/includes/sealScene.jsp" %>
  <%@ include file="/WEB-INF/includes/sceneScript.jsp" %>
</c:if>
<script>
  /* 카운트다운: 사용자 PC 시계 대신 서버가 준 남은 초와 performance.now()로 줄인다. 0초 -> "캡슐 여는 중..." -> 다시 불러오기. */
  (function () {
    var box = document.getElementById("countdown"), start = Number(box.dataset.seconds), t0 = performance.now(), timer;
    var KEY = "pc-recount-${capsule.id}";
    try { if (sessionStorage.getItem(KEY)) { sessionStorage.removeItem(KEY); document.getElementById("recount").hidden = false; } } catch (e) {}
    function pad(n) { return (n < 10 ? "0" : "") + n; }
    function draw(left) {
      var d = Math.floor(left / 86400), h = Math.floor(left % 86400 / 3600), m = Math.floor(left % 3600 / 60), s = left % 60;
      box.querySelector('[data-unit="d"]').hidden = d === 0;
      box.querySelector('[data-v="d"]').textContent = d;
      box.querySelector('[data-v="h"]').textContent = pad(h);
      box.querySelector('[data-v="m"]').textContent = pad(m);
      box.querySelector('[data-v="s"]').textContent = pad(s);
    }
    function tick() {
      var left = Math.max(0, start - Math.floor((performance.now() - t0) / 1000));
      if (left <= 0) {
        clearInterval(timer);
        document.getElementById("countBlock").hidden = true;
        document.getElementById("recount").hidden = true;
        document.getElementById("opening").hidden = false;
        document.querySelectorAll("[data-hide-when-opening]").forEach(function (el) { el.hidden = true; });
        try { sessionStorage.setItem(KEY, "1"); } catch (e) {}
        setTimeout(function () { location.reload(); }, 800);
        return;
      }
      draw(left);
    }
    tick();
    timer = setInterval(tick, 250);
  })();
</script>
