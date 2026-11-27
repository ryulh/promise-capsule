<%-- 편지 쓰기/수정. 사진 입력칸 3개(photo1~3)는 숨기고 화면 칸을 JS로 그린다. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="dto.Letter, dao.LetterDAO, dao.PhotoDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 봉인 전에만 쓸 수 있다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 내 편지가 있으면 본문과 사진을 채운 수정 화면이 된다
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    request.setAttribute("myLetter", myLetter);
    request.setAttribute("hasLetter", myLetter != null);
    if (myLetter != null) request.setAttribute("photos", PhotoDAO.getInstance().listByLetter(myLetter.getId()));
%>
<c:set var="titleKey" value="${hasLetter ? 'letter.title.edit' : 'letter.title.new'}"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
<%-- 서버에서 돌려보냈으면 입력한 본문을 다시 채운다 --%>
<c:set var="returned" value="${not empty errors}"/>
<c:set var="bodyText" value="${returned ? bodyValue : myLetter.body}"/>
<c:set var="fileErrorCount" value="0"/>
<c:forEach var="e" items="${errors}"><c:if test="${fn:startsWith(e.key, 'photo') && e.key != 'photos'}"><c:set var="fileErrorCount" value="${fileErrorCount + 1}"/></c:if></c:forEach>
  <main class="page">
    <div class="wrap">
      <form class="write-page" id="letterForm" method="post" action="${ctx}/letter/processLetter.jsp" enctype="multipart/form-data" data-validate onsubmit="return checkForm(this)" novalidate>
        <input type="hidden" name="capsuleId" value="${capsule.id}">
        <a class="small back" href="${ctx}/capsule/capsule.jsp?id=${capsule.id}" data-clear-draft><svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-left"/></svg><span><c:out value="${capsule.title}"/></span></a>
        <h1><fmt:message key="${hasLetter ? 'letter.title.edit' : 'letter.title.new'}"/></h1>
        <p class="small muted with-ic flush"><svg class="ic" aria-hidden="true"><use href="${icons}#i-lock"/></svg><span><fmt:message key="letter.lockNote"/></span></p>

        <%-- 서버 사진 오류: 아무것도 저장하지 않음, 본문 유지 --%>
        <c:if test="${returned}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body">
            <p><b><c:choose><c:when test="${fileErrorCount > 0}"><fmt:message key="letter.server.title"><fmt:param value="${fileErrorCount}"/></fmt:message></c:when><c:otherwise><fmt:message key="${errors.photos}"/></c:otherwise></c:choose></b> <span><fmt:message key="letter.server.body"/></span></p>
            <c:if test="${fileErrorCount > 0}">
              <ul class="file-errors"><c:forEach var="e" items="${errors}"><c:if test="${e.key != 'photos'}"><li id="srvErr-${e.key}"><span><c:out value="${fileNames[e.key]}"/> — <span><fmt:message key="${e.value}"/></span></span></li></c:if></c:forEach></ul>
            </c:if>
          </div></div>
        </c:if>

        <%-- 편지 본문 --%>
        <section class="box stack">
          <div class="field letter-area">
            <label for="body"><fmt:message key="letter.letter"/></label>
            <div class="hint-text" id="bodyHint">
              <span><fmt:message key="letter.hint"/></span>
              <ul><li><fmt:message key="draft.q1"/></li><li><fmt:message key="draft.q2"/></li><li><fmt:message key="draft.q3"/></li></ul>
            </div>
            <fmt:message key="letter.placeholder" var="bodyPlaceholder"/>
            <textarea id="body" name="body" placeholder="${fn:escapeXml(bodyPlaceholder)}" aria-describedby="bodyHint" data-v="required max:2000" data-counter="#bodyCount" data-max="2000"><c:out value="${bodyText}"/></textarea>
            <div class="row"><span class="help push"><fmt:message key="letter.required"/></span><span class="count" id="bodyCount"></span></div>
            <div class="err" data-err hidden><fmt:message key="letter.body.invalid"/></div>
          </div>
        </section>

        <%-- 사진 칸(최대 3장) --%>
        <section class="box stack">
          <div class="section-head flush"><h2 class="h-sm"><fmt:message key="letter.photos"/></h2><span class="aside" id="photoCount"></span></div>
          <%-- 문구는 번들에서(JS가 칸을 그릴 때 씀) --%>
          <div class="slots" id="slots"
               data-t-saved="<fmt:message key='letter.saved'/>" data-t-removing="<fmt:message key='letter.removing'/>"
               data-t-undo="<fmt:message key='letter.undo'/>" data-t-another="<fmt:message key='letter.another'/>"
               data-t-new="<fmt:message key='letter.new'/>" data-t-too-big="<fmt:message key='letter.tooBig'/>"
               data-t-not-allowed="<fmt:message key='letter.notAllowed'/>" data-t-add="<fmt:message key='letter.add'/>"
               data-t-delete-name="<fmt:message key='letter.deleteName'/>" data-t-remove-name="<fmt:message key='letter.removeName'/>"
               data-t-undo-name="<fmt:message key='letter.undoName'/>"
               data-t-err-size="<fmt:message key='letter.error.size'/>" data-t-err-type="<fmt:message key='letter.error.type'/>"
               data-photo-base="${ctx}/letter/photo.jsp?id=" data-icons="${icons}"
               data-srv-errs="<c:forEach var='e' items='${errors}'><c:if test="${fn:startsWith(e.key, 'photo') && e.key != 'photos'}">${fn:substringAfter(e.key, 'photo')} </c:if></c:forEach>">
            <c:forEach var="p" items="${photos}"><span hidden data-existing data-id="${p.id}" data-name="${fn:escapeXml(p.originalName)}"></span></c:forEach>
          </div>
          <c:forEach var="k" begin="1" end="3"><input type="file" name="photo${k}" id="photo${k}" accept=".jpg,.jpeg,.png,image/jpeg,image/png" hidden></c:forEach>
          <div id="deletes"></div>
          <p class="help flush" id="photoHelp"><fmt:message key="letter.photoHelp"/></p>
          <p class="help flush" id="photoFull" hidden><fmt:message key="letter.full"/></p>
          <ul class="file-errors" id="fileErrors" role="alert" hidden></ul>
        </section>

        <%-- 지우기, 저장, 취소 --%>
        <div class="write-actions">
          <c:if test="${hasLetter}"><button type="button" class="link-quiet erase" data-dialog="dlg-erase"><svg class="ic" aria-hidden="true"><use href="${icons}#i-trash-2"/></svg><span><fmt:message key="letter.erase"/></span></button></c:if>
          <button class="btn primary" type="submit" id="saveBtn"><fmt:message key="letter.save"/></button>
          <a class="btn" href="${ctx}/capsule/capsule.jsp?id=${capsule.id}" data-clear-draft><fmt:message key="letter.back"/></a>
        </div>
      </form>
    </div>
  </main>
<c:if test="${hasLetter}">
<%-- 편지 지우기 확인 창 --%>
<dialog class="dlg" id="dlg-erase" aria-labelledby="dlg-erase-t">
  <form method="post" action="${ctx}/letter/processDeleteLetter.jsp" data-clear-draft-on-submit><input type="hidden" name="capsuleId" value="${capsule.id}">
  <div class="dlg-body">
    <h2 id="dlg-erase-t"><fmt:message key="letter.dlg.title"/></h2>
    <p><fmt:message key="letter.dlg.body"/></p>
    <p class="keep"><fmt:message key="letter.dlg.keep"/></p>
  </div>
  <div class="dlg-actions"><button type="button" class="btn" data-close><fmt:message key="letter.dlg.cancel"/></button><button type="submit" class="btn primary danger"><fmt:message key="letter.dlg.ok"/></button></div>
  </form>
</dialog>
</c:if>
<script>
  /* 편지 본문 임시 보관: 세션이 끊겨도 글을 잃지 않게 sessionStorage에 둔다. 사진은 보관하지 않는다. */
  (function () {
    var KEY = "pc-letter-${sessionScope.userId}-${capsule.id}", body = document.getElementById("body");
    try {
      var kept = sessionStorage.getItem(KEY);
      if (kept && kept !== body.value) { body.value = kept; body.dispatchEvent(new Event("input")); }
      body.addEventListener("input", function () { try { sessionStorage.setItem(KEY, body.value); } catch (e) {} });
      document.querySelectorAll("[data-clear-draft]").forEach(function (a) { a.addEventListener("click", function () { sessionStorage.removeItem(KEY); }); });
      var erase = document.querySelector("[data-clear-draft-on-submit]");
      if (erase) erase.addEventListener("submit", function () { sessionStorage.removeItem(KEY); });
    } catch (e) { /* 저장소를 못 쓰면 보관만 건너뛴다 */ }
  })();

  /* 사진 칸 3개: 화면 k번째 칸 = 숨은 입력칸 photoK. 저장된 사진은 삭제 표시만 하고 저장할 때 지운다. */
  (function () {
    var slots = document.getElementById("slots"), T = slots.dataset, icons = T.icons;
    var existing = Array.prototype.map.call(slots.querySelectorAll("[data-existing]"), function (el) {
      return { id: el.dataset.id, name: el.dataset.name, removed: false };
    });
    var inputs = {}, files = {}, previews = {}, srvErr = {};
    // 서버가 거절한 칸: 다시 고를 때까지 칸 버튼이 서버 이유를 가리킨다
    (T.srvErrs || "").split(" ").forEach(function (k) { if (k) srvErr[k] = true; });
    [1, 2, 3].forEach(function (k) {
      inputs[k] = document.getElementById("photo" + k);
      inputs[k].addEventListener("change", function () {
        files[k] = inputs[k].files[0] || null;
        delete srvErr[k];
        if (previews[k]) { URL.revokeObjectURL(previews[k]); previews[k] = null; }
        render("[data-slot='" + k + "'] .x");
      });
    });
    var MAX = 5 * 1024 * 1024;
    function problem(f) {
      if (!/\.(jpe?g|png)$/i.test(f.name)) return "type";
      if (f.size > MAX) return "size";
      return null;
    }
    function fill(t, name) { return t.replace("{0}", name); }
    function icon(id) { return '<svg class="ic" aria-hidden="true"><use href="' + icons + '#i-' + id + '"/></svg>'; }
    function esc(s) { return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;"); }
    function el(html) { var t = document.createElement("template"); t.innerHTML = html.trim(); return t.content.firstChild; }
    // 칸 k의 오류 이유 id
    function errRef(k, why) { return why ? ' aria-describedby="photoErr' + k + '"' : srvErr[k] ? ' aria-describedby="srvErr-photo' + k + '"' : ''; }
    // [사진 추가]는 아직 다시 고르지 않은 거절 칸을 모두 가리킨다
    function addRef() { var ids = Object.keys(srvErr).filter(function (k) { return !files[k]; }).map(function (k) { return "srvErr-photo" + k; }); return ids.length ? ' aria-describedby="' + ids.join(" ") + '"' : ''; }

    function render(focusSel) {
      slots.querySelectorAll(".slot").forEach(function (s) { s.remove(); });
      var E = existing.length, total = 0, bad = [], removingCount = 0;
      for (var k = 1; k <= 3; k++) {
        var ex = k <= E ? existing[k - 1] : null, f = files[k], node = null;
        if (f) {
          var why = problem(f);
          if (!previews[k] && !why) previews[k] = URL.createObjectURL(f);
          node = el('<div class="slot new' + (why ? ' bad' : '') + '" data-slot="' + k + '">' +
            (why ? '' : '<img class="ph" alt="" src="' + previews[k] + '">') +
            '<span class="tag">' + esc(why === "size" ? T.tTooBig : why === "type" ? T.tNotAllowed : T.tNew) + '</span>' +
            '<button type="button" class="x" aria-label="' + esc(fill(T.tRemoveName, f.name)) + '"' + errRef(k, why) + '>' + icon("x") + '</button>' +
            '<span class="fname">' + esc(f.name) + '</span></div>');
          node.querySelector(".x").addEventListener("click", (function (k) { return function () {
            files[k] = null; inputs[k].value = ""; render(k <= existing.length ? "[data-slot='" + k + "'] .undo" : "[data-add]");
          }; })(k));
          if (why) bad.push({ k: k, name: f.name, why: why });
          total++;
        } else if (ex && ex.removed) {
          removingCount++;
          node = el('<div class="slot removing" data-slot="' + k + '"><span>' + esc(T.tRemoving) + '</span>' +
            '<button type="button" class="undo" aria-label="' + esc(fill(T.tUndoName, ex.name)) + '">' + icon("undo-2") + '<span class="lbl">' + esc(T.tUndo) + '</span></button>' +
            '<button type="button" class="swap"' + errRef(k) + '>' + icon("plus") + '<span class="lbl">' + esc(T.tAnother) + '</span></button></div>');
          node.querySelector(".undo").addEventListener("click", (function (ex, k) { return function () {
            ex.removed = false; render("[data-slot='" + k + "'] .x");
          }; })(ex, k));
          node.querySelector(".swap").addEventListener("click", (function (k) { return function () { inputs[k].click(); }; })(k));
        } else if (ex) {
          node = el('<div class="slot filled" data-slot="' + k + '"><img class="ph" alt="" loading="lazy" src="' + T.photoBase + ex.id + '">' +
            '<span class="tag">' + esc(T.tSaved) + '</span>' +
            '<button type="button" class="x" aria-label="' + esc(fill(T.tDeleteName, ex.name)) + '"' + errRef(k) + '>' + icon("x") + '</button>' +
            '<span class="fname">' + esc(ex.name) + '</span></div>');
          node.querySelector(".x").addEventListener("click", (function (ex, k) { return function () {
            ex.removed = true; render("[data-slot='" + k + "'] .undo");
          }; })(ex, k));
          total++;
        }
        if (node) slots.appendChild(node);
      }
      // 추가 칸: 저장된 사진 뒤의 빈 입력칸 중 첫 번째(3장을 넘지 않게)
      var next = 0;
      for (var j = E + 1; j <= 3; j++) if (!files[j]) { next = j; break; }
      if (next && total + removingCount < 3) {
        var add = el('<button type="button" class="slot add" data-add' + addRef() + '>'+ icon("plus").replace('class="ic"', 'class="ic plus"') + '<span>' + esc(T.tAdd) + '</span></button>');
        add.addEventListener("click", function () { inputs[next].click(); });
        slots.appendChild(add);
      }
      // 지울 사진 번호(저장할 때 함께 보냄)
      var deletes = document.getElementById("deletes");
      deletes.innerHTML = "";
      existing.forEach(function (ex) {
        if (ex.removed) deletes.appendChild(el('<input type="hidden" name="deletePhotoId" value="' + ex.id + '">'));
      });
      document.getElementById("photoCount").textContent = total + "/3";
      var full = total === 3 && removingCount === 0;
      document.getElementById("photoHelp").hidden = full;
      document.getElementById("photoFull").hidden = !full;
      var list = document.getElementById("fileErrors");
      list.innerHTML = bad.map(function (b) { return '<li id="photoErr' + b.k + '"><span>' + esc(b.name) + " — " + esc(b.why === "size" ? T.tErrSize : T.tErrType) + "</span></li>"; }).join("");
      list.hidden = bad.length === 0;
      document.getElementById("saveBtn").disabled = bad.length > 0;
      if (focusSel) { var target = slots.querySelector(focusSel) || slots.querySelector("[data-add]"); if (target) target.focus(); }
    }
    render();
  })();
</script>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
