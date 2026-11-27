<%-- 결과 안내 띠. 사용자 글이 들어갈 수 있어 값은 c:out으로만. --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:if test="${not empty notice}">
  <c:set var="noticeWarn" value="${fn:startsWith(notice, 'notice.state.')}"/>
  <div class="banner ${noticeWarn ? 'warn' : 'success'} mb-4" role="status"><svg class="ic" aria-hidden="true"><use href="${icons}#i-${noticeWarn ? 'circle-alert' : 'check'}"/></svg><div class="body"><p><c:choose><c:when test="${empty noticeArg}"><fmt:message key="${notice}"/></c:when><c:otherwise><fmt:message key="${notice}"><fmt:param><c:out value="${noticeArg}"/></fmt:param></fmt:message></c:otherwise></c:choose></p></div></div>
</c:if>
