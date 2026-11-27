<%-- 캡슐 상세(열림). 첫 열람이면 개봉 연출 층을 겹친다. 사용자 글은 c:out으로만 출력한다. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="icons" value="${ctx}/assets/img/icons.svg"/>
<fmt:message key="opened.writtenOn.pattern" var="writtenPattern"/>

      <div class="cap-head">
        <div class="title-row">
          <h1><c:out value="${capsule.title}"/></h1>
          <span class="badge opened"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock-open"/></svg><span><fmt:message key="common.badge.open"/></span></span>
        </div>
        <c:if test="${not empty capsule.description}"><p class="muted flush"><c:out value="${capsule.description}"/></p></c:if>
        <div class="meta">
          <span><span><fmt:message key="opened.openedOn"/></span> <b><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></span>
          <span><span><fmt:message key="locked.sealedOn"/></span> <b><fmt:formatDate value="${capsule.sealedAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></span>
          <span><span><fmt:message key="draft.members"/></span> <b><fmt:message key="common.people"><fmt:param value="${capsule.memberCount}"/></fmt:message></b></span>
        </div>
      </div>
      <div class="mt-4"><%@ include file="/WEB-INF/includes/notice.jsp" %></div>

      <%-- 요약: N일 전의 우리 --%>
      <section class="summary-hero">
        <div class="big"><fmt:message key="opened.daysAgo"><fmt:param value="${capsule.daysSealed}"/></fmt:message></div>
        <div class="span-line"><span><fmt:message key="opened.sealed"/></span> <fmt:formatDate value="${capsule.sealedAt}" pattern="yyyy-MM-dd" timeZone="Asia/Seoul"/> <svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-right"/></svg> <span><fmt:message key="opened.opened"/></span> <fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd" timeZone="Asia/Seoul"/></div>
        <div><b><fmt:message key="opened.summary"><fmt:param value="${capsule.letterCount}"/><fmt:param value="${capsule.photoCount}"/></fmt:message></b></div>
        <ul class="chips">
          <c:forEach var="m" items="${members}">
            <c:choose>
              <c:when test="${m.letterStatus == 'WRITTEN'}"><li><c:out value="${m.nickname}"/></li></c:when>
              <c:otherwise><li class="none"><c:out value="${m.nickname}"/> · <span><fmt:message key="${m.letterStatus == 'WITHDRAWN' ? 'opened.chip.erased' : 'opened.chip.noLetter'}"/></span></li></c:otherwise>
            </c:choose>
          </c:forEach>
        </ul>
      </section>

      <%-- 편지 카드: 편지 없는 참여자는 카드가 없다 --%>
      <section class="sec reading">
        <div class="section-head"><h2><fmt:message key="opened.letters"/></h2><span class="aside"><fmt:message key="opened.tapHint"/></span></div>
        <div class="letter-cards">
          <c:forEach var="card" items="${letters}">
            <c:choose>
              <c:when test="${not empty card.withdrawnAt}">
                <div class="env erased">
                  <span class="flap" aria-hidden="true"></span>
                  <span class="from"><fmt:message key="opened.from"><fmt:param><c:out value="${card.nickname}"/></fmt:param></fmt:message><c:if test="${card.userId == sessionScope.userId}"> <small class="me-tag"><fmt:message key="common.me"/></small></c:if></span>
                  <span><svg class="ic" aria-hidden="true"><use href="${icons}#i-ban"/></svg> <span><fmt:message key="opened.erasedCard"/></span></span>
                </div>
              </c:when>
              <c:otherwise>
                <details class="env">
                  <summary>
                    <span class="flap" aria-hidden="true"></span><span class="seal" aria-hidden="true"></span>
                    <span class="from"><fmt:message key="opened.from"><fmt:param><c:out value="${card.nickname}"/></fmt:param></fmt:message><c:if test="${card.userId == sessionScope.userId}"> <small class="me-tag"><fmt:message key="common.me"/></small></c:if><c:if test="${card.userId == capsule.ownerId}"> <small><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg> <span><fmt:message key="common.creator"/></span></small></c:if></span>
                    <span class="excerpt"><c:out value="${card.body}"/></span>
                    <span class="foot"><span><c:choose><c:when test="${empty card.photos}"><fmt:message key="opened.noPhotos"/></c:when><c:otherwise><fmt:message key="opened.enclosed"><fmt:param value="${fn:length(card.photos)}"/></fmt:message></c:otherwise></c:choose></span><span class="more"><span class="when-closed"><span><fmt:message key="opened.expand"/></span><svg class="ic" aria-hidden="true"><use href="${icons}#i-chevron-down"/></svg></span><span class="when-open"><span><fmt:message key="opened.collapse"/></span><svg class="ic" aria-hidden="true"><use href="${icons}#i-chevron-up"/></svg></span></span></span>
                  </summary>
                  <div class="sheet">
                    <p class="body-text"><c:out value="${card.body}"/></p>
                    <p class="sign"><span><fmt:formatDate value="${card.createdAt}" pattern="${writtenPattern}" timeZone="Asia/Seoul"/></span></p>
                  </div>
                  <c:if test="${not empty card.photos}">
                    <div class="prints">
                      <c:forEach var="p" items="${card.photos}">
                        <div class="print"><figure><img class="img" src="${ctx}/letter/photo.jsp?id=${p.id}" alt="" loading="lazy"></figure><span class="fn"><c:out value="${p.originalName}"/></span><a href="${ctx}/letter/photo.jsp?id=${p.id}&amp;download=1" class="with-ic" aria-label="<fmt:message key='opened.downloadName'><fmt:param><c:out value='${p.originalName}'/></fmt:param></fmt:message>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-download"/></svg><span><fmt:message key="opened.download"/></span></a></div>
                      </c:forEach>
                    </div>
                  </c:if>
                  <div class="actions"><c:if test="${(card.userId == sessionScope.userId) && canWithdraw}"><a class="link-quiet" href="${ctx}/letter/withdraw.jsp?id=${capsule.id}"><svg class="ic" aria-hidden="true"><use href="${icons}#i-trash-2"/></svg><span><fmt:message key="opened.withdraw"/></span></a></c:if><span class="spacer"></span><button class="btn small" type="button" data-collapse><span><fmt:message key="opened.collapse"/></span><svg class="ic" aria-hidden="true"><use href="${icons}#i-chevron-up"/></svg></button></div>
                </details>
              </c:otherwise>
            </c:choose>
          </c:forEach>
        </div>
      </section>

      <%-- 한마디 --%>
      <section class="sec reading" id="comments">
        <div class="section-head"><h2><fmt:message key="opened.notes"/></h2><c:if test="${not empty comments}"><span class="aside"><fmt:message key="opened.noteCount"><fmt:param value="${fn:length(comments)}"/></fmt:message></span></c:if></div>
        <div class="box">
          <fmt:message key="opened.notePlaceholder" var="notePlaceholder"/>
          <form class="comment-form" method="post" action="${ctx}/capsule/processAddComment.jsp" data-validate onsubmit="return checkForm(this)" novalidate>
            <input type="hidden" name="capsuleId" value="${capsule.id}">
            <div class="field">
              <label for="cm" class="small muted"><fmt:message key="opened.noteLabel"/></label>
              <textarea id="cm" name="body" placeholder="${fn:escapeXml(notePlaceholder)}" data-v="required max:300" data-counter="#cmCount" data-max="300"></textarea>
              <div class="err" data-err hidden><fmt:message key="opened.note.invalid"/></div>
              <div class="row"><span class="count push" id="cmCount"></span><button class="btn primary small" type="submit"><fmt:message key="opened.post"/></button></div>
            </div>
          </form>
          <c:choose>
            <c:when test="${empty comments}">
              <div class="empty mt-3 compact"><p class="muted flush"><fmt:message key="opened.noNotes"/></p></div>
            </c:when>
            <c:otherwise>
              <ul class="comments mt-3">
                <c:forEach var="cm" items="${comments}">
                  <c:choose>
                    <c:when test="${cm.id == editCommentId && cm.userId == sessionScope.userId}">
                      <li class="editing" id="c${cm.id}"><span class="meta"><b><c:out value="${cm.nickname}"/></b> <span class="me-tag"><fmt:message key="common.me"/></span> · <fmt:formatDate value="${cm.createdAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/></span><span></span>
                        <form class="comment-form cm-edit" method="post" action="${ctx}/capsule/processEditComment.jsp" data-validate onsubmit="return checkForm(this)" novalidate>
                          <input type="hidden" name="commentId" value="${cm.id}">
                          <div class="field">
                            <label for="cme" class="sr-only"><fmt:message key="opened.editLabel"/></label>
                            <textarea id="cme" name="body" data-v="required max:300" data-counter="#cmeCount" data-max="300" autofocus><c:out value="${cm.body}"/></textarea>
                            <div class="err" data-err hidden><fmt:message key="opened.note.invalid"/></div>
                            <div class="row"><span class="count push" id="cmeCount"></span><a href="${ctx}/capsule/capsule.jsp?id=${capsule.id}#c${cm.id}" class="btn small"><fmt:message key="opened.cancel"/></a><button class="btn primary small" type="submit"><fmt:message key="opened.save"/></button></div>
                          </div>
                        </form></li>
                    </c:when>
                    <c:otherwise>
                      <li id="c${cm.id}"><span class="meta"><b><c:out value="${cm.nickname}"/></b><c:if test="${cm.userId == sessionScope.userId}"> <span class="me-tag"><fmt:message key="common.me"/></span></c:if> · <fmt:formatDate value="${cm.createdAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/><c:if test="${not empty cm.editedAt}"> · <span class="edited"><fmt:message key="opened.edited"/></span></c:if></span><span></span><span class="text"><c:out value="${cm.body}"/></span>
                        <c:if test="${cm.userId == sessionScope.userId}"><span class="cm-actions"><a href="${ctx}/capsule/capsule.jsp?id=${capsule.id}&amp;editComment=${cm.id}#c${cm.id}" class="link-quiet"><fmt:message key="opened.edit"/></a><button type="button" class="link-quiet" data-dialog="dlg-note-${cm.id}"><fmt:message key="opened.deleteNote"/></button></span>
<dialog class="dlg" id="dlg-note-${cm.id}" aria-labelledby="dlg-note-${cm.id}-t">
  <form method="post" action="${ctx}/capsule/processEditComment.jsp"><input type="hidden" name="commentId" value="${cm.id}"><input type="hidden" name="action" value="delete">
  <div class="dlg-body"><h2 id="dlg-note-${cm.id}-t"><fmt:message key="opened.dlg.title"/></h2><p><fmt:message key="opened.dlg.body"/></p></div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="opened.cancel"/></button><button type="submit" class="btn primary danger"><fmt:message key="opened.dlg.ok"/></button></div>
  </form>
</dialog></c:if></li>
                    </c:otherwise>
                  </c:choose>
                </c:forEach>
              </ul>
            </c:otherwise>
          </c:choose>
        </div>
      </section>

<script>
  /* 카드 아래 [접기]: 펼친 카드를 접고 그 자리로 */
  document.addEventListener("click", function (e) {
    var b = e.target.closest("[data-collapse]"); if (!b) return;
    var card = b.closest("details"); card.open = false; card.scrollIntoView({ block: "nearest" });
  });
</script>

<c:if test="${firstOpen}">
  <%-- 개봉 연출: 끝나거나 건너뛰면 숨은 폼으로 첫 열람을 기록한다 --%>
  <fmt:message key="openScene.caption" var="openCaption"><fmt:param value="${capsule.daysSealed}"/></fmt:message>
  <%@ include file="/WEB-INF/includes/openScene.jsp" %>
  <form id="openForm" method="post" action="${ctx}/capsule/processOpen.jsp" hidden><input type="hidden" name="capsuleId" value="${capsule.id}"></form>
  <%@ include file="/WEB-INF/includes/sceneScript.jsp" %>
</c:if>
