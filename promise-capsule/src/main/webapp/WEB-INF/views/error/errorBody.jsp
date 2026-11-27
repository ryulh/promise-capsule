<%-- 공통 오류 본문. 스택 트레이스는 화면에 쓰지 않는다. --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
  <main class="page">
    <div class="wrap">
      <div class="error-page" role="alert">
        <img class="art r1x1" alt="" src="${ctx}/assets/img/${errLocked ? 'img-03' : 'img-06'}.webp">
        <c:set var="errKey" value="${errLocked ? 'error.403.locked' : 'error.'.concat(errCode)}"/>
        <span class="code"><fmt:message key="${errKey}.code"/></span>
        <h1><fmt:message key="${errKey}.title"/></h1>
        <p><fmt:message key="${errKey}.body"/></p>
        <c:if test="${errLocked}">
          <p class="until"><span><fmt:message key="error.403.locked.until"/></span> <b><fmt:message key="error.403.locked.remain"><fmt:param value="${errRemainDays}"/><fmt:param value="${errRemainHours}"/></fmt:message></b></p>
        </c:if>
        <div class="actions">
          <c:choose>
            <c:when test="${not loggedIn}">
              <a class="btn primary" href="${ctx}/index.jsp"><fmt:message key="error.home"/></a>
            </c:when>
            <c:when test="${errCode == '403' && errCapsuleId > 0}">
              <a class="btn primary" href="${ctx}/capsule/capsule.jsp?id=${errCapsuleId}"><fmt:message key="error.backToCapsule"/></a>
              <a class="btn" href="${ctx}/capsule/capsules.jsp"><fmt:message key="error.capsules"/></a>
            </c:when>
            <c:otherwise>
              <a class="btn primary" href="${ctx}/capsule/capsules.jsp"><fmt:message key="error.toCapsules"/></a>
              <c:if test="${errCode == '500'}"><button class="btn" type="button" onclick="location.reload()"><fmt:message key="error.retry"/></button></c:if>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </main>
