<%-- 로그인 처리: 틀리면 login.jsp로 forward(아이디, 비밀번호 중 무엇이 틀렸는지 알리지 않음). 성공하면 가려던 주소로. --%>
<%@ page pageEncoding="UTF-8" import="java.util.HashMap, java.util.Map, dto.User, dao.UserDAO" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="form" class="dto.LoginForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 아이디로 회원을 찾고 비밀번호 해시를 비교한다. 틀리면 로그인 화면으로
    User user = UserDAO.getInstance().findByLoginId(form.getLoginId());
    if (user == null || form.getPassword() == null || !user.getPasswordHash().equals(UserDAO.hash(form.getPassword()))) {
        Map<String, String> errors = new HashMap<>();
        errors.put("form", "login.error.fail");
        request.setAttribute("errors", errors);
%><jsp:forward page="/account/login.jsp"/><%
        return;
    }
    // 로그인 성공: 세션에 회원 번호, 닉네임 저장
    request.changeSessionId(); // 세션 고정 방지
    session.setAttribute("userId", user.getId());
    session.setAttribute("nickname", user.getNickname());
    session.removeAttribute("loginReason");

    // 아이디 저장: 체크하면 30일 쿠키, 풀면 쿠키 삭제
    boolean saveId = "on".equals(form.getSaveId());
    Cookie saved = new Cookie("savedId", saveId ? user.getLoginId() : "");
    saved.setMaxAge(saveId ? 60 * 60 * 24 * 30 : 0);
    saved.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
    response.addCookie(saved);

    // 가려던 주소 -> 초대 참여 확인 -> 내 캡슐 순으로 이동
    String back = (String) session.getAttribute("returnTo");
    session.removeAttribute("returnTo");
    String code = (String) session.getAttribute("inviteCode");
    if (back != null && back.startsWith("/") && !back.startsWith("//")) {
        response.sendRedirect(request.getContextPath() + back);
    } else if (code != null) {
        response.sendRedirect(request.getContextPath() + "/capsule/join.jsp?code=" + code);
    } else {
        response.sendRedirect(request.getContextPath() + "/capsule/capsules.jsp");
    }
%>
