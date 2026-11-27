<%-- 내 정보 저장: 닉네임이 이미 있으면 me.jsp로 forward. 성공하면 세션의 닉네임도 바꾼다. --%>
<%@ page pageEncoding="UTF-8" import="java.util.HashMap, java.util.Map, dao.UserDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<jsp:useBean id="form" class="dto.MeForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 입력 형식 확인(닉네임 2~12자, 이메일 형식)
    String nickname = form.getNickname() == null ? "" : form.getNickname().strip();
    String email = form.getEmail() == null ? "" : form.getEmail().strip();
    boolean notify = "on".equals(form.getNotifyOnOpen());
    int nickLength = nickname.codePointCount(0, nickname.length());
    if (nickLength < 2 || nickLength > 12 || email.length() > 100 || !email.matches("[^\\s@]+@[^\\s@]+\\.[^\\s@]+")) {
        response.sendError(400);
        return;
    }
    // 다른 사람이 쓰는 닉네임이면 내 정보 화면으로 돌려보낸다
    if (UserDAO.getInstance().existsNickname(nickname, userId)) {
        Map<String, String> errors = new HashMap<>();
        errors.put("nickname", "me.error.nicknameTaken");
        request.setAttribute("errors", errors);
%><jsp:forward page="/account/me.jsp"/><%
        return;
    }
    // 저장하고 내 정보 화면으로 이동
    UserDAO.getInstance().update(userId, nickname, email, notify);
    session.setAttribute("nickname", nickname);
    // 알림을 껐으면 보낼 주소 대신 끈 상태를 알린다
    session.setAttribute("notice", notify ? "me.notice.saved" : "me.notice.savedOff");
    session.setAttribute("noticeArg", email);
    response.sendRedirect(request.getContextPath() + "/account/me.jsp");
%>
