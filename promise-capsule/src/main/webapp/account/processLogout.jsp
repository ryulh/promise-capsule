<%-- 로그아웃 --%>
<%@ page pageEncoding="UTF-8" %>
<%
    // 세션을 끝내고 새 세션에 안내 문구를 담아 첫 화면으로
    session.invalidate();
    request.getSession(true).setAttribute("notice", "intro.loggedOut");
    response.sendRedirect(request.getContextPath() + "/index.jsp");
%>
