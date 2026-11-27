<%-- 캡슐 폼 조각(만들기, 수정 공용, mode: create, edit, overdue). 최소 간격 안내는 설정값으로 그린다. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="icons" value="${ctx}/assets/img/icons.svg"/>
<c:set var="mode" value="${param.mode}"/>
<fmt:message key="common.interval.${applicationScope.minIntervalUnit}" var="minInterval"><fmt:param value="${applicationScope.minIntervalAmount}"/></fmt:message>
<c:set var="returned" value="${not empty errors}"/>
<c:set var="titleValue" value="${returned ? param.title : capsule.title}"/>
<c:set var="descValue" value="${returned ? param.description : capsule.description}"/>
<c:choose>
  <c:when test="${returned}"><c:set var="dateValue" value="${param.openDate}"/><c:set var="timeValue" value="${param.openTime}"/></c:when>
  <c:when test="${mode == 'edit'}"><fmt:formatDate var="dateValue" value="${capsule.openAt}" pattern="yyyy-MM-dd" timeZone="Asia/Seoul"/><fmt:formatDate var="timeValue" value="${capsule.openAt}" pattern="HH:mm" timeZone="Asia/Seoul"/></c:when>
  <c:when test="${mode == 'overdue'}"><c:set var="dateValue" value=""/><fmt:formatDate var="timeValue" value="${capsule.openAt}" pattern="HH:mm" timeZone="Asia/Seoul"/></c:when>
  <c:otherwise><c:set var="dateValue" value=""/><c:set var="timeValue" value="18:00"/></c:otherwise>
</c:choose>
      <form class="form-page wide" method="post" action="${ctx}/capsule/${mode == 'create' ? 'processAddCapsule.jsp' : 'processEditCapsule.jsp'}" data-validate onsubmit="return checkForm(this)" novalidate>
        <c:choose>
          <c:when test="${mode == 'create'}"><a class="small back" href="${ctx}/capsule/capsules.jsp"><svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-left"/></svg><span><fmt:message key="capsuleForm.back"/></span></a></c:when>
          <c:otherwise>
            <input type="hidden" name="capsuleId" value="${capsule.id}">
            <a class="small back" href="${ctx}/capsule/capsule.jsp?id=${capsule.id}"><svg class="ic" aria-hidden="true"><use href="${icons}#i-arrow-left"/></svg><span><c:out value="${capsule.title}"/></span></a>
          </c:otherwise>
        </c:choose>

        <h1><fmt:message key="capsuleForm.title.${mode}"/></h1>

        <c:if test="${mode == 'overdue'}">
          <div class="banner warn"><svg class="ic" aria-hidden="true"><use href="${icons}#i-hourglass"/></svg><div class="body"><p><fmt:message key="capsuleForm.overdue"/></p></div></div>
        </c:if>
        <fmt:message key="capsuleForm.summary" var="summaryTemplate"/>
        <div class="banner error" data-summary data-template="${fn:escapeXml(summaryTemplate)}" role="alert" hidden><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body"><p></p></div></div>
        <c:if test="${not empty errors.openAt}">
          <div class="banner error" role="alert"><svg class="ic" aria-hidden="true"><use href="${icons}#i-circle-alert"/></svg><div class="body"><p><fmt:message key="${errors.openAt == 'capsuleForm.error.tooLate' ? 'capsuleForm.timeerrLate' : 'capsuleForm.timeerr'}"><fmt:param value="${minInterval}"/></fmt:message></p></div></div>
        </c:if>

        <section class="box stack">
          <div class="field">
            <label for="title"><span><fmt:message key="capsuleForm.field.title"/></span><span class="req"><fmt:message key="capsuleForm.field.title.req"/></span></label>
            <fmt:message key="capsuleForm.field.title.placeholder" var="titlePlaceholder"/>
            <input id="title" name="title" type="text" maxlength="40" value="${fn:escapeXml(titleValue)}" placeholder="${fn:escapeXml(titlePlaceholder)}" data-v="required max:40" data-counter="#titleCount" data-max="40">
            <div class="count" id="titleCount"></div>
            <div class="err" data-err hidden><fmt:message key="capsuleForm.field.title.invalid"/></div>
          </div>
          <div class="field">
            <label for="description"><span><fmt:message key="capsuleForm.field.description"/></span><span class="req"><fmt:message key="capsuleForm.field.description.req"/></span></label>
            <fmt:message key="capsuleForm.field.description.placeholder" var="descPlaceholder"/>
            <textarea class="short" id="description" name="description" placeholder="${fn:escapeXml(descPlaceholder)}" data-v="max:200" data-counter="#descCount" data-max="200"><c:out value="${descValue}"/></textarea>
            <div class="row"><span class="err push" data-err hidden><fmt:message key="capsuleForm.field.description.invalid"/></span><span class="count" id="descCount"></span></div>
          </div>
        </section>

        <section class="box stack">
          <div class="field${not empty errors.openAt ? ' invalid' : ''}">
            <span class="label" id="whenLabel"><fmt:message key="capsuleForm.when"/></span>
            <div class="quick-dates" role="group" aria-label="<fmt:message key='capsuleForm.quick'/>">
              <button type="button" data-days="100"><fmt:message key="capsuleForm.quick.100d"/></button>
              <button type="button" data-years="1"><fmt:message key="capsuleForm.quick.1y"/></button>
              <button type="button" data-years="3"><fmt:message key="capsuleForm.quick.3y"/></button>
            </div>
            <div class="inline-2">
              <input type="date" id="openDate" name="openDate" value="${fn:escapeXml(dateValue)}" aria-label="<fmt:message key='capsuleForm.openDate'/>" data-v="required"<c:if test="${not empty errors.openAt}"> aria-invalid="true" aria-describedby="openAt-srv"</c:if>>
              <input type="time" id="openTime" name="openTime" value="${fn:escapeXml(timeValue)}" aria-label="<fmt:message key='capsuleForm.openTime'/>" data-v="required">
            </div>
            <c:if test="${not empty errors.openAt}"><div class="err" id="openAt-srv" data-srv-err><fmt:message key="${errors.openAt}"><fmt:param value="${minInterval}"/></fmt:message></div></c:if>
            <div class="err" data-err hidden><fmt:message key="capsuleForm.openAt.invalid"/></div>
            <div class="help"><fmt:message key="capsuleForm.range"><fmt:param value="${minInterval}"/></fmt:message></div>
            <ol class="how-steps" aria-label="<fmt:message key='capsuleForm.howSteps'/>">
              <li><b><fmt:message key="capsuleForm.how1.title"/></b><span><fmt:message key="capsuleForm.how1.body"/></span></li>
              <li><b><fmt:message key="capsuleForm.how2.title"/></b><span><fmt:message key="capsuleForm.how2.body"/></span></li>
              <li><b><fmt:message key="capsuleForm.how3.title"/></b><span><fmt:message key="capsuleForm.how3.body"/></span></li>
            </ol>
            <p class="small flush"><fmt:message key="capsuleForm.noSealNote"/></p>
            <c:if test="${mode == 'overdue'}">
              <div class="help"><span><fmt:message key="capsuleForm.previous"/></span> <span class="was"><fmt:formatDate value="${capsule.openAt}" pattern="yyyy-MM-dd HH:mm" timeZone="Asia/Seoul"/> <fmt:message key="common.kst"/></span></div>
            </c:if>
          </div>
        </section>

        <div class="write-actions">
          <button class="btn primary" type="submit"><fmt:message key="capsuleForm.submit.${mode}"/></button>
          <a class="btn" href="${ctx}/capsule/${mode == 'create' ? 'capsules.jsp' : 'capsule.jsp?id='.concat(capsule.id)}"><fmt:message key="capsuleForm.cancel"/></a>
        </div>
      </form>
<script>
  /* 빠른 선택: 100일, 1년, 3년 뒤 날짜를 채운다(범위 판단은 서버). */
  (function () {
    var date = document.getElementById("openDate");
    function pad(n) { return (n < 10 ? "0" : "") + n; }
    function fill(btn) {
      var d = new Date();
      if (btn.dataset.days) d.setDate(d.getDate() + Number(btn.dataset.days));
      if (btn.dataset.years) d.setFullYear(d.getFullYear() + Number(btn.dataset.years));
      date.value = d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate());
      document.querySelectorAll(".quick-dates button").forEach(function (b) { b.setAttribute("aria-pressed", b === btn); });
      date.dispatchEvent(new Event("input"));
    }
    document.querySelectorAll(".quick-dates button").forEach(function (b) { b.addEventListener("click", function () { fill(b); }); });
    if (!date.value && "${mode}" === "create") fill(document.querySelector(".quick-dates [data-years='1']"));
  })();
</script>
