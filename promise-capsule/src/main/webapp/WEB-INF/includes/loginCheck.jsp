<%-- 로그인 확인(로그인이 필요한 JSP 맨 위에 include). 안 했으면 가려던 주소를 기억해 두고 로그인 화면으로 보낸다. --%>
<%
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    // 로그인하지 않았으면
    if (userId == null) {
        // 세션이 만료된 경우 로그인 화면에 따로 알린다
        if (request.getRequestedSessionId() != null && !request.isRequestedSessionIdValid()) {
            session.setAttribute("loginReason", "expired");
        }
        // 화면을 열려다 막혔으면 그 주소를 기억해 둔다
        if ("GET".equals(request.getMethod())) {
            String query = request.getQueryString();
            session.setAttribute("returnTo", request.getServletPath() + (query == null ? "" : "?" + query));
        } else {
            // 폼을 보내다 막혔으면 그 폼이 있던 화면으로(같은 사이트 주소일 때만)
            String base = (String) application.getAttribute("baseUrl");
            String referer = request.getHeader("Referer");
            if (referer != null && referer.startsWith(base + "/")) {
                session.setAttribute("returnTo", referer.substring(base.length()));
            }
        }
        response.sendRedirect(request.getContextPath() + "/account/login.jsp");
        return;
    }
%>
