<%-- 공통 헤더: 언어 정하기(lang 쿠키 -> 브라우저 언어 -> ko), 번들 지정, 결과 안내 한 번 꺼내기, <header> 출력. --%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%
    // 저장해 둔 언어 쿠키(lang) 읽기
    String cookieLang = null;
    Cookie[] langCookies = request.getCookies();
    if (langCookies != null) {
        for (Cookie langCookie : langCookies) {
            if ("lang".equals(langCookie.getName())) {
                cookieLang = langCookie.getValue();
            }
        }
    }
    pageContext.setAttribute("cookieLang", cookieLang);
%>
<c:choose><c:when test="${cookieLang == 'en' || cookieLang == 'ko'}"><c:set var="lang" value="${cookieLang}" scope="request"/></c:when><c:when test="${pageContext.request.locale.language == 'en'}"><c:set var="lang" value="en" scope="request"/></c:when><c:otherwise><c:set var="lang" value="ko" scope="request"/></c:otherwise></c:choose><fmt:setLocale value="${lang}" scope="request"/>
<fmt:setBundle basename="bundle.message" scope="request"/>
<c:if test="${not empty sessionScope.notice}"><c:set var="notice" value="${sessionScope.notice}" scope="request"/>
<c:set var="noticeArg" value="${sessionScope.noticeArg}" scope="request"/>
<c:remove var="notice" scope="session"/>
<c:remove var="noticeArg" scope="session"/></c:if><c:set var="icons" value="${ctx}/assets/img/icons.svg"/>
<c:set var="loggedIn" value="${not empty sessionScope.userId}"/><!doctype html>
<html lang="${lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><c:choose><c:when test="${not empty pageTitle}"><c:out value="${pageTitle}"/> · </c:when><c:when test="${not empty titleKey}"><fmt:message key="${titleKey}"/> · </c:when></c:choose><fmt:message key="common.service"/></title>
<link rel="stylesheet" href="${ctx}/assets/css/common.css">
</head>
<body<c:if test="${not empty bodyState}"> data-state="${bodyState}"</c:if>>
<div class="frame">
  <header class="site">
    <div class="wrap bar">
      <a class="logo" href="${ctx}/${loggedIn ? 'capsule/capsules.jsp' : 'index.jsp'}"><span class="mark" aria-hidden="true"></span><span><fmt:message key="common.service"/></span></a>
      <c:url var="langKo" value="/lang.jsp"><c:param name="lang" value="ko"/></c:url>
      <c:url var="langEn" value="/lang.jsp"><c:param name="lang" value="en"/></c:url>
      <fmt:message key="common.lang.group" var="langGroup"/>
      <%-- 메뉴: 로그인했으면 내 캡슐, 내 정보, 로그아웃, 아니면 로그인, 가입 --%>
      <c:choose>
        <c:when test="${loggedIn}">
          <nav class="nav nav-full">
            <a href="${ctx}/capsule/capsules.jsp"><fmt:message key="common.nav.capsules"/></a>
            <a class="who" href="${ctx}/account/me.jsp" title="<fmt:message key='common.nav.me'/>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-user"/></svg><c:out value="${sessionScope.nickname}"/></a>
            <form class="nav-form" method="post" action="${ctx}/account/processLogout.jsp"><button type="submit" class="nav-link"><fmt:message key="common.nav.logout"/></button></form>
            <span class="lang" role="group" aria-label="${langGroup}"><a href="${langKo}" lang="ko" title="한국어" aria-current="${lang == 'ko'}">한국어</a><a href="${langEn}" lang="en" title="English" aria-current="${lang == 'en'}">English</a></span>
          </nav>
          <nav class="nav nav-compact">
            <span class="lang" role="group" aria-label="${langGroup}"><a href="${langKo}" lang="ko" title="한국어" aria-current="${lang == 'ko'}">KO</a><a href="${langEn}" lang="en" title="English" aria-current="${lang == 'en'}">EN</a></span>
            <details class="menu"><summary aria-label="<fmt:message key='common.nav.menu'/>"><svg class="ic" aria-hidden="true"><use href="${icons}#i-menu"/></svg></summary><div class="panel">
              <a href="${ctx}/capsule/capsules.jsp"><fmt:message key="common.nav.capsules"/></a>
              <a href="${ctx}/account/me.jsp"><fmt:message key="common.nav.me"/> · <c:out value="${sessionScope.nickname}"/></a>
              <form class="nav-form" method="post" action="${ctx}/account/processLogout.jsp"><button type="submit" class="nav-link"><fmt:message key="common.nav.logout"/></button></form>
            </div></details>
          </nav>
        </c:when>
        <c:otherwise>
          <nav class="nav nav-full">
            <span class="lang" role="group" aria-label="${langGroup}"><a href="${langKo}" lang="ko" title="한국어" aria-current="${lang == 'ko'}">한국어</a><a href="${langEn}" lang="en" title="English" aria-current="${lang == 'en'}">English</a></span>
            <a href="${ctx}/account/login.jsp"><fmt:message key="common.nav.login"/></a>
            <a class="btn small" href="${ctx}/account/signup.jsp"><fmt:message key="common.nav.signup"/></a>
          </nav>
          <nav class="nav nav-compact">
            <span class="lang" role="group" aria-label="${langGroup}"><a href="${langKo}" lang="ko" title="한국어" aria-current="${lang == 'ko'}">KO</a><a href="${langEn}" lang="en" title="English" aria-current="${lang == 'en'}">EN</a></span>
            <a href="${ctx}/account/login.jsp"><fmt:message key="common.nav.login"/></a>
          </nav>
        </c:otherwise>
      </c:choose>
    </div>
  </header>
