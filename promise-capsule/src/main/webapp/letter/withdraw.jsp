<%-- 내 편지 지우기(철회) 확인 --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dto.Letter, dao.LetterDAO, dao.PhotoDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 내 편지가 있고 봉인 뒤일 때만
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    if (myLetter == null) {   // 편지를 쓰지 않은 사람
        forbidden(request, response, capsule);
        return;
    }
    if (draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 화면에 넘길 값: 편지, 사진 수
    request.setAttribute("myLetter", myLetter);
    request.setAttribute("photoCount", PhotoDAO.getInstance().listByLetter(myLetter.getId()).size());
    // 열린 캡슐이면 지울 편지의 첫 줄을 보여 준다(잠김이면 내용을 보여 주지 않음)
    if (state.equals("OPENED") && myLetter.getBody() != null) {
        request.setAttribute("firstLine", myLetter.getBody().split("\n")[0]);
    }
%>
<c:set var="titleKey" value="withdraw.title"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<c:set var="opened" value="${capsule.state == 'OPENED'}"/>
<c:set var="back" value="${ctx}/capsule/capsule.jsp?id=${capsule.id}"/>
  <main class="page">
    <div class="wrap">
      <div class="confirm-page">
        <a class="small back" href="${back}"><svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-left"/></svg><span><c:out value="${capsule.title}"/></span></a>
        <%-- 이미 지운 편지면 안내만 --%>
        <c:choose>
          <c:when test="${not empty myLetter.withdrawnAt}">
            <div class="stack">
              <h1><fmt:message key="withdraw.already.title"/></h1>
              <p class="muted flush"><fmt:message key="withdraw.already.body"/></p>
              <a class="btn" href="${back}"><fmt:message key="withdraw.already.back"/></a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="stack">
              <h1><fmt:message key="withdraw.h1"/></h1>
              <div class="grid-2">
                <section class="box emph">
                  <h2 class="with-ic h-sm"><svg class="ic" aria-hidden="true"><use href="${icons}#i-trash-2"/></svg><span><fmt:message key="withdraw.erased"/></span></h2>
                  <p class="flush"><b><fmt:message key="withdraw.erasedWhat"><fmt:param value="${photoCount}"/></fmt:message></b></p>
                  <c:choose>
                    <c:when test="${opened}"><p class="letter-preview small flush mt-2 text-2">“<c:out value="${firstLine}"/>…”</p></c:when>
                    <c:otherwise><p class="small muted flush mt-2"><fmt:message key="withdraw.lockedNote"/></p></c:otherwise>
                  </c:choose>
                </section>
                <section class="box soft">
                  <h2 class="with-ic h-sm"><svg class="ic" aria-hidden="true"><use href="${icons}#i-check"/></svg><span><fmt:message key="withdraw.stays"/></span></h2>
                  <ul class="consequences">
                    <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-pill"/></svg><span><fmt:message key="withdraw.stays.capsule"/></span></li>
                    <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-mail"/></svg><span><fmt:message key="withdraw.stays.others"/></span></li>
                    <c:if test="${opened}"><li><svg class="ic" aria-hidden="true"><use href="${icons}#i-message-circle"/></svg><span><fmt:message key="withdraw.stays.notes"/></span></li></c:if>
                    <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-user"/></svg><span><fmt:message key="withdraw.stays.member"/></span></li>
                  </ul>
                </section>
              </div>
              <section class="box soft">
                <ul class="consequences">
                  <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-dot"/></svg><span><fmt:message key="withdraw.know1"/></span></li>
                  <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-dot"/></svg><span><fmt:message key="withdraw.know2"/></span></li>
                  <c:if test="${opened}"><li><svg class="ic" aria-hidden="true"><use href="${icons}#i-dot"/></svg><span><fmt:message key="withdraw.know3"/></span></li></c:if>
                  <li><svg class="ic" aria-hidden="true"><use href="${icons}#i-dot"/></svg><span><fmt:message key="withdraw.know4"/></span></li>
                </ul>
                <p class="flush mt-3"><b><fmt:message key="withdraw.final"/></b></p>
              </section>
              <%-- 지우기 버튼 --%>
              <form class="confirm-actions" method="post" action="${ctx}/letter/processWithdraw.jsp">
                <input type="hidden" name="capsuleId" value="${capsule.id}">
                <div class="confirm-buttons">
                  <button class="btn primary danger" type="submit"><fmt:message key="withdraw.ok"/></button>
                  <a class="btn" href="${back}"><fmt:message key="withdraw.keep"/></a>
                </div>
              </form>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
