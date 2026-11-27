<%-- 언어 전환: lang 쿠키 저장 후 보던 화면으로(같은 사이트 Referer일 때만). --%>
<%@ page pageEncoding="UTF-8" %>
<%
    String lang = request.getParameter("lang");
    // 고른 언어를 1년 쿠키로 저장
    if ("ko".equals(lang) || "en".equals(lang)) {
        Cookie cookie = new Cookie("lang", lang);
        cookie.setMaxAge(60 * 60 * 24 * 365);
        cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
        response.addCookie(cookie);
    }
    // 보던 화면으로 돌아간다(같은 사이트에서 왔을 때만)
    String base = (String) application.getAttribute("baseUrl");
    String referer = request.getHeader("Referer");
    if (referer != null && referer.startsWith(base + "/")) {
        String back = referer.substring(base.length());
        // 규칙 실패 폼은 주소창에 처리 JSP가 남으므로 같은 폼 화면으로 돌린다
        String path = back.contains("?") ? back.substring(0, back.indexOf('?')) : back;
        if (path.contains("/process")) {
            if (path.endsWith("/processLogin.jsp")) back = "/account/login.jsp";
            else if (path.endsWith("/processSignup.jsp")) back = "/account/signup.jsp";
            else if (path.endsWith("/processMe.jsp")) back = "/account/me.jsp";
            else if (path.endsWith("/processAddCapsule.jsp")) back = "/capsule/addCapsule.jsp";
            else if (path.endsWith("/processJoin.jsp")) back = "/capsule/join.jsp";
            else back = "/capsule/capsules.jsp";
        }
        response.sendRedirect(request.getContextPath() + back);
    } else {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
%>
