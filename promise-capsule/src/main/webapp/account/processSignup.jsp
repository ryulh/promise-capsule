<%-- 가입 처리: 아이디, 닉네임이 이미 있으면 signup.jsp로 forward, 성공하면 로그인 상태로 내 캡슐(초대에서 왔으면 참여 확인)로. --%>
<%@ page pageEncoding="UTF-8" import="java.util.HashMap, java.util.Map, dto.User, dao.UserDAO" %>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="form" class="dto.SignupForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 브라우저(validate.js)와 같은 규칙으로 한 번 더 확인한다
    String loginId = form.getLoginId() == null ? "" : form.getLoginId();
    String password = form.getPassword() == null ? "" : form.getPassword();
    String nickname = form.getNickname() == null ? "" : form.getNickname().strip();
    String email = form.getEmail() == null ? "" : form.getEmail().strip();
    int nickLength = nickname.codePointCount(0, nickname.length());
    if (!loginId.matches("[a-z0-9_]{4,20}") || !password.matches("(?=.*[A-Za-z])(?=.*[0-9]).{8,64}")
            || !password.equals(form.getPasswordConfirm()) || nickLength < 2 || nickLength > 12
            || email.length() > 100 || !email.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) {
        response.sendError(400);
        return;
    }

    UserDAO userDAO = UserDAO.getInstance();
    // 아이디, 닉네임이 이미 있으면 가입 화면으로 돌려보낸다
    Map<String, String> errors = new HashMap<>();
    if (userDAO.findByLoginId(loginId) != null) errors.put("loginId", "signup.error.loginIdTaken");
    if (userDAO.existsNickname(nickname, 0)) errors.put("nickname", "signup.error.nicknameTaken");
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
%><jsp:forward page="/account/signup.jsp"/><%
        return;
    }

    // 비밀번호는 해시로 바꿔 저장
    User user = new User();
    user.setLoginId(loginId);
    user.setPasswordHash(UserDAO.hash(password));
    user.setNickname(nickname);
    user.setEmail(email);
    int userId = userDAO.insert(user);

    // 가입하면 바로 로그인 상태로 만들고 내 캡슐(초대에서 왔으면 참여 확인)로 이동
    request.changeSessionId(); // 세션 고정 방지
    session.setAttribute("userId", userId);
    session.setAttribute("nickname", nickname);
    session.removeAttribute("loginReason");
    session.removeAttribute("returnTo");
    String code = (String) session.getAttribute("inviteCode");
    response.sendRedirect(request.getContextPath() + (code != null ? "/capsule/join.jsp?code=" + code : "/capsule/capsules.jsp"));
%>
