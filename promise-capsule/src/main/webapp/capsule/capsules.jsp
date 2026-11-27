<%-- 내 캡슐 목록: 새로 열림, 작성 중, 잠김, 열어 본 캡슐로 묶는다. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List, dto.Capsule, dao.CapsuleDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%!
    /** D-day 배지 문구: 0이면 D-DAY, 아니면 D-n */
    private String dDayLabel(long days) {
        return days <= 0 ? "D-DAY" : "D-" + days;
    }
%>
<%
    // 내 캡슐을 읽어 할 일이 있는 것부터 정렬
    List<Capsule> items = CapsuleDAO.getInstance().listByMember(userId);   // 여는 날 순
    items.sort((a, b) -> Boolean.compare(b.isTodoActive(), a.isTodoActive()));   // 할 일이 있는 캡슐 먼저
    request.setAttribute("items", items);
    // 묶음별 개수(0이면 그 묶음을 그리지 않는다)
    int draft = 0, locked = 0, opened = 0, fresh = 0;
    for (Capsule i : items) {
        if ("DRAFT".equals(i.getState()) || "OVERDUE".equals(i.getState())) draft++;
        else if ("LOCKED".equals(i.getState())) locked++;
        else if (i.isNewlyOpened()) fresh++;
        else opened++;
    }
    request.setAttribute("draftCount", draft);
    request.setAttribute("lockedCount", locked);
    request.setAttribute("openedCount", opened);
    request.setAttribute("freshCount", fresh);
%>
<c:set var="titleKey" value="capsules.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <div class="list-head">
        <h1><fmt:message key="capsules.h1"/></h1>
        <c:if test="${not empty items}"><a class="btn" href="${ctx}/capsule/addCapsule.jsp"><svg class="ic" aria-hidden="true"><use href="${icons}#i-plus"/></svg><span><fmt:message key="capsules.new"/></span></a></c:if>
      </div>
      <div class="mt-4"><%@ include file="/WEB-INF/includes/notice.jsp" %></div>

      <c:if test="${empty items}">
        <%-- 빈 목록 --%>
        <div class="empty mt-5">
          <img class="art r1x1" alt="" src="${ctx}/assets/img/img-05.webp">
          <h2><fmt:message key="capsules.empty.title"/></h2>
          <p class="muted"><fmt:message key="capsules.empty.body"/></p>
          <a class="btn primary" href="${ctx}/capsule/addCapsule.jsp"><svg class="ic" aria-hidden="true"><use href="${icons}#i-plus"/></svg><span><fmt:message key="capsules.empty.button"/></span></a>
          <p class="small muted flush mt-4"><fmt:message key="capsules.empty.invite"/></p>
        </div>
      </c:if>

      <%-- 지금 열 수 있어요: 아직 안 열어 본 열린 캡슐 --%>
      <c:if test="${freshCount > 0}">
        <section class="new-strip">
          <c:forEach var="it" items="${items}">
            <c:if test="${it.state == 'OPENED' && it.newlyOpened}">
              <a class="cap-card new" href="${ctx}/capsule/capsule.jsp?id=${it.id}">
                <span class="t"><span class="badge new"><svg class="ic" aria-hidden="true"><use href="${icons}#i-alarm-clock"/></svg><span><fmt:message key="capsules.ready"/></span></span><b><c:out value="${it.title}"/></b></span>
                <span class="m"><span><fmt:formatDate value="${it.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul" var="openedText"/><fmt:message key="capsules.openedAt"><fmt:param value="${openedText}"/></fmt:message></span><span><fmt:message key="capsules.membersLetters"><fmt:param value="${it.memberCount}"/><fmt:param value="${it.letterCount}"/></fmt:message></span></span>
                <span class="btn primary small"><fmt:message key="capsules.openButton"/></span>
              </a>
            </c:if>
          </c:forEach>
        </section>
      </c:if>

      <%-- 작성 중(기한 경과 포함) --%>
      <c:if test="${draftCount > 0}">
        <section class="cap-group">
          <h2 class="grp-draft"><svg class="ic" aria-hidden="true"><use href="${icons}#i-pencil"/></svg><span><fmt:message key="capsules.group.draft"/></span><span class="n">${draftCount}</span></h2>
          <div class="cap-cards">
            <c:forEach var="it" items="${items}">
              <c:if test="${it.state == 'DRAFT' || it.state == 'OVERDUE'}">
                <a class="cap-card" href="${ctx}/capsule/capsule.jsp?id=${it.id}">
                  <span class="t"><b><c:out value="${it.title}"/></b><c:if test="${it.owner}"><span class="badge plain"><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg><span><fmt:message key="common.creator"/></span></span></c:if><c:if test="${it.state == 'OVERDUE'}"><span class="badge overdue"><svg class="ic" aria-hidden="true"><use href="${icons}#i-hourglass"/></svg><span><fmt:message key="common.badge.overdue"/></span></span></c:if></span>
                  <span class="m"><span><fmt:message key="capsules.written"><fmt:param value="${it.memberCount}"/><fmt:param value="${it.letterCount}"/></fmt:message></span></span>
                  <c:choose>
                    <c:when test="${it.todo == 'overdueMember'}"><span class="when"><fmt:message key="capsules.todo.overdueMember"/></span></c:when>
                    <c:otherwise>
                      <span class="todo${it.todoActive ? '' : ' done'}"><svg class="ic" aria-hidden="true"><use href="${icons}#i-${it.todo == 'overdueOwner' ? 'hourglass' : it.todo == 'noLetter' ? 'pencil' : it.todo == 'canSeal' ? 'lock' : 'check'}"/></svg><span><fmt:message key="capsules.todo.${it.todo}"/></span></span>
                      <c:if test="${it.state == 'DRAFT'}"><span class="when"><span><fmt:message key="capsules.opens"/></span> <fmt:formatDate value="${it.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></span></c:if>
                    </c:otherwise>
                  </c:choose>
                </a>
              </c:if>
            </c:forEach>
          </div>
        </section>
      </c:if>

      <%-- 잠김: D-day --%>
      <c:if test="${lockedCount > 0}">
        <section class="cap-group">
          <h2 class="grp-locked"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="capsules.group.locked"/></span><span class="n">${lockedCount}</span></h2>
          <div class="cap-cards">
            <c:forEach var="it" items="${items}">
              <c:if test="${it.state == 'LOCKED'}">
                <c:set var="dDay" value="${it.DDay}"/>
                <a class="cap-card" href="${ctx}/capsule/capsule.jsp?id=${it.id}">
                  <span class="t"><b><c:out value="${it.title}"/></b><c:if test="${it.owner}"><span class="badge plain"><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg><span><fmt:message key="common.creator"/></span></span></c:if><span class="badge dday"><%= dDayLabel((Long) pageContext.getAttribute("dDay")) %></span></span>
                  <span class="m"><span><fmt:message key="capsules.membersLetters"><fmt:param value="${it.memberCount}"/><fmt:param value="${it.letterCount}"/></fmt:message></span></span>
                  <span class="when"><span><fmt:message key="capsules.opens"/></span> <fmt:formatDate value="${it.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></span>
                </a>
              </c:if>
            </c:forEach>
          </div>
        </section>
      </c:if>

      <%-- 열어 본 캡슐 --%>
      <c:if test="${openedCount > 0 || freshCount > 0}">
        <section class="cap-group">
          <h2 class="grp-opened"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock-open"/></svg><span><fmt:message key="capsules.group.opened"/></span><span class="n">${openedCount}</span></h2>
          <div class="cap-cards">
            <c:forEach var="it" items="${items}">
              <c:if test="${it.state == 'OPENED' && !it.newlyOpened}">
                <a class="cap-card" href="${ctx}/capsule/capsule.jsp?id=${it.id}">
                  <span class="t"><b><c:out value="${it.title}"/></b><c:if test="${it.owner}"><span class="badge plain"><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg><span><fmt:message key="common.creator"/></span></span></c:if></span>
                  <span class="m"><span><fmt:message key="capsules.membersLetters"><fmt:param value="${it.memberCount}"/><fmt:param value="${it.letterCount}"/></fmt:message></span></span>
                  <span class="when"><span><fmt:message key="capsules.opened"/></span> <fmt:formatDate value="${it.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></span>
                </a>
              </c:if>
            </c:forEach>
          </div>
          <c:forEach var="it" items="${items}">
            <c:if test="${it.state == 'OPENED' && it.newlyOpened && empty staysShown}">
              <c:set var="staysShown" value="true"/>
              <p class="small muted flush mt-2"><fmt:message key="capsules.staysTop"><fmt:param><c:out value="${it.title}"/></fmt:param></fmt:message></p>
            </c:if>
          </c:forEach>
        </section>
      </c:if>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
