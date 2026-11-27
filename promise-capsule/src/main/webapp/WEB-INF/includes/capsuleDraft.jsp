<%-- 캡슐 상세(작성 중, 기한 경과). 버튼은 capsule.jsp가 정해 넣은 canX만 보고 그린다. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="icons" value="${ctx}/assets/img/icons.svg"/>
<c:set var="overdue" value="${capsule.state == 'OVERDUE'}"/>
<c:set var="inviteUrl" value="${applicationScope.baseUrl}/capsule/join.jsp?code=${capsule.inviteCode}"/>
<fmt:message key="draft.invite" var="inviteLabel"/>

      <%-- 캡슐 헤더 --%>
      <div class="cap-head">
        <div class="title-row">
          <h1><c:out value="${capsule.title}"/></h1>
          <c:choose>
            <c:when test="${overdue}"><span class="badge overdue"><svg class="ic" aria-hidden="true"><use href="${icons}#i-hourglass"/></svg><span><fmt:message key="common.badge.overdue"/></span></span></c:when>
            <c:otherwise><span class="badge draft"><svg class="ic" aria-hidden="true"><use href="${icons}#i-pencil"/></svg><span><fmt:message key="common.badge.draft"/></span></span></c:otherwise>
          </c:choose>
        </div>
        <c:if test="${not empty capsule.description}"><p class="muted flush"><c:out value="${capsule.description}"/></p></c:if>
        <div class="meta">
          <span><span><fmt:message key="draft.opensOn"/></span> <b><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></b></span>
          <span><span><fmt:message key="draft.members"/></span> <b><c:choose><c:when test="${solo}"><fmt:message key="common.peopleOne"/></c:when><c:when test="${capsule.full}"><fmt:message key="draft.peopleFull"><fmt:param value="${capsule.memberCount}"/></fmt:message></c:when><c:otherwise><fmt:message key="common.people"><fmt:param value="${capsule.memberCount}"/></fmt:message></c:otherwise></c:choose></b></span>
        </div>
      </div>

      <%-- 안내 띠: 방금 한 일의 결과 / 지금 상태 --%>
      <div class="stack mt-4">
        <%@ include file="/WEB-INF/includes/notice.jsp" %>
        <c:if test="${overdue}">
          <div class="banner warn"><svg class="ic" aria-hidden="true"><use href="${icons}#i-hourglass"/></svg><div class="body">
            <p><b><fmt:message key="draft.overdue.title"/></b> <span><fmt:message key="${canManage ? 'draft.overdue.owner' : 'draft.overdue.member'}"/></span></p>
            <c:if test="${canManage}"><a class="btn primary small" href="${ctx}/capsule/editCapsule.jsp?id=${capsule.id}"><fmt:message key="draft.overdue.ownerButton"/></a></c:if>
          </div></div>
        </c:if>
      </div>

      <%-- 방금 만든 캡슐(혼자): 초대가 첫 할 일 --%>
      <c:if test="${solo}">
        <section class="box invite mt-4">
          <div class="section-head"><h2><fmt:message key="draft.solo.title"/></h2></div>
          <p class="muted flush"><fmt:message key="draft.solo.body"/></p>
          <div class="link"><input readonly value="${fn:escapeXml(inviteUrl)}" aria-label="${inviteLabel}"><button type="button" class="btn primary" data-copy><fmt:message key="common.copy"/></button></div>
        </section>
      </c:if>

      <div class="cap-layout">
        <div class="main">
          <%-- 내 편지: 본인에게만 미리보기 --%>
          <section class="box my-letter">
            <div class="section-head"><h2><fmt:message key="draft.myLetter"/></h2>
              <span class="aside"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="draft.onlyMe"/></span></span></div>
            <c:choose>
              <c:when test="${hasMyLetter}">
                <div class="stack">
                  <p class="letter-preview"><c:out value="${myLetter.body}"/></p>
                  <c:if test="${not empty myPhotos}">
                    <div class="thumbs"><c:forEach var="p" items="${myPhotos}" varStatus="s"><img class="ph" src="${ctx}/letter/photo.jsp?id=${p.id}" alt="<fmt:message key='draft.photoAlt'><fmt:param value='${s.count}'/></fmt:message>" loading="lazy"></c:forEach></div>
                  </c:if>
                  <div class="row"><a class="btn" href="${ctx}/letter/letter.jsp?id=${capsule.id}"><fmt:message key="draft.editLetter"/></a><span class="small muted"><fmt:formatDate value="${myLetter.updatedAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul" var="savedText"/><fmt:message key="draft.lastSaved"><fmt:param value="${savedText}"/></fmt:message></span></div>
                </div>
              </c:when>
              <c:otherwise>
                <div class="empty">
                  <h3><fmt:message key="draft.empty.title"/></h3>
                  <p class="muted mb-2"><fmt:message key="draft.empty.hint"/></p>
                  <ul class="muted"><li><fmt:message key="draft.q1"/></li><li><fmt:message key="draft.q2"/></li></ul>
                  <a class="btn${solo ? '' : ' primary'}" href="${ctx}/letter/letter.jsp?id=${capsule.id}"><fmt:message key="draft.write"/></a>
                  <span class="small muted ml-2"><fmt:message key="draft.upTo3"/></span>
                </div>
              </c:otherwise>
            </c:choose>
          </section>

          <%-- 작성 현황판 --%>
          <section class="box">
            <div class="section-head">
              <h2><fmt:message key="draft.board"/></h2>
              <span class="aside"><c:choose><c:when test="${solo}"><fmt:message key="draft.board.solo"/></c:when><c:otherwise><fmt:message key="capsules.written"><fmt:param value="${capsule.memberCount}"/><fmt:param value="${capsule.letterCount}"/></fmt:message></c:otherwise></c:choose></span>
            </div>
            <fmt:formatNumber var="ratio" value="${capsule.letterCount * 100 / capsule.memberCount}" maxFractionDigits="0"/>
            <div class="progress" role="img" aria-label="<fmt:message key='draft.board.ratio'/> ${ratio}%"><i style="width:${ratio}%"></i></div>
            <ul class="members">
              <c:forEach var="m" items="${members}">
                <li class="member">
                  <span class="av" aria-hidden="true"><c:out value="${fn:substring(m.nickname, 0, 1)}"/></span>
                  <span class="name"><c:out value="${m.nickname}"/><c:if test="${m.userId == capsule.ownerId}"> <span class="badge plain"><svg class="ic" aria-hidden="true"><use href="${icons}#i-star"/></svg><span><fmt:message key="common.creator"/></span></span></c:if><c:if test="${m.userId == sessionScope.userId}"><span class="me-tag"><fmt:message key="common.me"/></span></c:if></span>
                  <span class="sub"><c:choose><c:when test="${m.letterStatus != 'WRITTEN'}">—</c:when><c:when test="${m.photoCount == 0}"><fmt:message key="common.photosNone"/></c:when><c:otherwise><fmt:message key="common.photos"><fmt:param value="${m.photoCount}"/></fmt:message></c:otherwise></c:choose></span>
                  <span class="state"><span class="badge plain"><svg class="ic env" aria-hidden="true"><use href="${icons}#i-${m.letterStatus == 'WRITTEN' ? 'env-sealed' : 'env-empty'}"/></svg><span><fmt:message key="${m.letterStatus == 'WRITTEN' ? 'draft.written' : 'draft.notYet'}"/></span></span></span>
                  <c:if test="${canManage && !(m.userId == capsule.ownerId)}">
                    <span class="row-action"><button type="button" class="link-quiet" data-dialog="dlg-remove-${m.userId}" aria-label="<fmt:message key='draft.removeName'><fmt:param><c:out value='${m.nickname}'/></fmt:param></fmt:message>"><fmt:message key="draft.remove"/></button></span>
                  </c:if>
                </li>
              </c:forEach>
            </ul>
            <c:if test="${!capsule.owner}"><p class="small muted flush mt-3"><fmt:message key="draft.memberNote"/></p></c:if>
            <p class="small muted flush mt-1"><fmt:message key="draft.secretNote"/></p>
          </section>
        </div>

        <%-- 오른쪽: 개설자 관리 버튼, 초대 링크, 참여 취소, 봉인 --%>
        <aside class="side">
          <c:if test="${capsule.owner}">
            <section class="box actions">
              <h3><fmt:message key="draft.manage"/></h3>
              <c:if test="${canManage}"><a class="btn block" href="${ctx}/capsule/editCapsule.jsp?id=${capsule.id}"><fmt:message key="draft.editInfo"/></a></c:if>
              <c:if test="${canManage}"><button type="button" class="btn block" data-dialog="dlg-reissue"><svg class="ic" aria-hidden="true"><use href="${icons}#i-refresh-cw"/></svg><span><fmt:message key="draft.reissue"/></span></button></c:if>
              <c:if test="${canManage}"><button type="button" class="link-quiet" data-dialog="dlg-delete"><fmt:message key="draft.delete"/></button></c:if>
            </section>
          </c:if>

          <c:if test="${!solo}">
            <section class="box invite">
              <b><fmt:message key="draft.invite"/></b>
              <div class="link"><input readonly value="${fn:escapeXml(inviteUrl)}" aria-label="${inviteLabel}"><button type="button" class="btn small" data-copy><fmt:message key="common.copy"/></button></div>
              <c:if test="${capsule.full}"><span class="small"><fmt:message key="draft.full"/></span></c:if>
            </section>
          </c:if>

          <c:if test="${canLeave}">
            <section class="box actions">
              <h3><fmt:message key="draft.membership"/></h3>
              <button type="button" class="btn block" data-dialog="dlg-leave"><fmt:message key="draft.leave"/></button>
            </section>
          </c:if>

          <%-- 봉인: 개설자, 작성 중만(기한 경과면 위 안내 띠에서 여는 날 다시 정하기) --%>
          <c:if test="${capsule.owner && capsule.state == 'DRAFT'}">
            <section class="box actions narrow-first">
              <h2><fmt:message key="draft.seal.title"/></h2>
              <p class="small muted flush"><fmt:message key="draft.seal.body"/></p>
              <c:choose>
                <c:when test="${capsule.letterCount == 0}">
                  <button class="btn primary block" type="button" disabled aria-describedby="sealNoLetter"><fmt:message key="draft.seal.button"/></button>
                  <span class="small" id="sealNoLetter"><fmt:message key="draft.seal.noLetter"/></span>
                </c:when>
                <c:otherwise>
                  <a class="btn${hasMyLetter ? ' primary' : ''} block" href="${ctx}/capsule/seal.jsp?id=${capsule.id}"><fmt:message key="draft.seal.button"/></a>
                  <c:if test="${capsule.notWrittenCount > 0}"><span class="small"><fmt:message key="draft.seal.missing"><fmt:param value="${capsule.notWrittenCount}"/></fmt:message></span></c:if>
                </c:otherwise>
              </c:choose>
            </section>
          </c:if>
        </aside>
      </div>

<%-- 확인 알림창: 확인 버튼은 POST 폼 제출 --%>
<c:if test="${canManage}">
<dialog class="dlg" id="dlg-reissue" aria-labelledby="dlg-reissue-t">
  <form method="post" action="${ctx}/capsule/processReissueInvite.jsp"><input type="hidden" name="capsuleId" value="${capsule.id}">
  <div class="dlg-body">
    <h2 id="dlg-reissue-t"><fmt:message key="draft.dlg.reissue.title"/></h2>
    <p><fmt:message key="draft.dlg.reissue.body"/></p>
    <p class="keep"><fmt:message key="draft.dlg.reissue.keep"/></p>
  </div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="common.cancel"/></button><button type="submit" class="btn primary"><fmt:message key="draft.dlg.reissue.ok"/></button></div>
  </form>
</dialog>
</c:if>
<c:if test="${canManage}">
<dialog class="dlg" id="dlg-delete" aria-labelledby="dlg-delete-t">
  <form method="post" action="${ctx}/capsule/processDeleteCapsule.jsp"><input type="hidden" name="capsuleId" value="${capsule.id}">
  <div class="dlg-body">
    <h2 id="dlg-delete-t"><fmt:message key="draft.dlg.delete.title"/></h2>
    <p><fmt:message key="draft.dlg.delete.body"/></p>
  </div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="common.cancel"/></button><button type="submit" class="btn primary danger"><fmt:message key="draft.dlg.delete.ok"/></button></div>
  </form>
</dialog>
</c:if>
<c:if test="${canManage}">
  <c:forEach var="m" items="${members}">
    <c:if test="${!(m.userId == capsule.ownerId)}">
<dialog class="dlg" id="dlg-remove-${m.userId}" aria-labelledby="dlg-remove-${m.userId}-t">
  <form method="post" action="${ctx}/capsule/processKick.jsp"><input type="hidden" name="capsuleId" value="${capsule.id}"><input type="hidden" name="memberUserId" value="${m.userId}">
  <div class="dlg-body">
    <h2 id="dlg-remove-${m.userId}-t"><fmt:message key="draft.dlg.remove.title"><fmt:param><c:out value="${m.nickname}"/></fmt:param></fmt:message></h2>
    <p><fmt:message key="draft.dlg.remove.body"><fmt:param><c:out value="${m.nickname}"/></fmt:param></fmt:message></p>
    <label class="check"><input type="checkbox" name="reissue" value="true" checked><span><fmt:message key="draft.dlg.remove.reissue"/></span></label>
  </div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="common.cancel"/></button><button type="submit" class="btn primary danger"><fmt:message key="draft.dlg.remove.ok"/></button></div>
  </form>
</dialog>
    </c:if>
  </c:forEach>
</c:if>
<c:if test="${canLeave}">
<dialog class="dlg" id="dlg-leave" aria-labelledby="dlg-leave-t">
  <form method="post" action="${ctx}/capsule/processLeave.jsp"><input type="hidden" name="capsuleId" value="${capsule.id}">
  <div class="dlg-body">
    <h2 id="dlg-leave-t"><fmt:message key="draft.dlg.leave.title"/></h2>
    <p><fmt:message key="draft.dlg.leave.body"/></p>
    <p class="keep"><fmt:message key="draft.dlg.leave.keep"/></p>
  </div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="draft.dlg.leave.stay"/></button><button type="submit" class="btn primary danger"><fmt:message key="draft.dlg.leave.ok"/></button></div>
  </form>
</dialog>
</c:if>
<c:if test="${sessionScope.clearDraft == capsule.id}">
<c:remove var="clearDraft" scope="session"/>
<script>
  /* 저장, 지우기가 끝났으면 편지 임시 보관본을 지운다 */
  try { sessionStorage.removeItem("pc-letter-${sessionScope.userId}-${capsule.id}"); } catch (e) {}
</script>
</c:if>
<script>
  /* 초대 링크 복사: 2초 동안 "복사됨" */
  (function () {
    var copied = "<fmt:message key='common.copied'/>";
    document.querySelectorAll("[data-copy]").forEach(function (btn) {
      var label = btn.textContent;
      btn.addEventListener("click", function () {
        var input = btn.parentElement.querySelector("input");
        function done() { btn.textContent = copied; btn.setAttribute("aria-live", "polite"); setTimeout(function () { btn.textContent = label; }, 2000); }
        function fallback() { input.select(); if (document.execCommand("copy")) done(); }
        if (navigator.clipboard) navigator.clipboard.writeText(input.value).then(done, fallback);
        else fallback();
      });
    });
  })();
</script>
