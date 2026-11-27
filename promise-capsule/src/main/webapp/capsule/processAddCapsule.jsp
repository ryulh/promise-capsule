<%-- 캡슐 만들기 처리: 만든 사람이 첫 참여자가 된다. 여는 날 범위가 틀리면 addCapsule.jsp로 forward. --%>
<%@ page pageEncoding="UTF-8" import="java.time.LocalDateTime, java.util.HashMap, java.util.Map, dao.CapsuleDAO, dao.MemberDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<jsp:useBean id="form" class="dto.CapsuleForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 입력 형식 확인
    if (!form.isValid()) {
        response.sendError(400);
        return;
    }
    // 여는 날: 지금부터 최소 간격(설정값) 뒤 ~ 5년 안
    int minMinutes = (Integer) application.getAttribute("minIntervalMinutes");
    LocalDateTime openAt = form.getOpenAt().toLocalDateTime();
    Map<String, String> errors = new HashMap<>();
    if (openAt.isBefore(LocalDateTime.now().plusMinutes(minMinutes))) errors.put("openAt", "capsuleForm.error.tooSoon");
    else if (openAt.isAfter(LocalDateTime.now().plusYears(5))) errors.put("openAt", "capsuleForm.error.tooLate");
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
%><jsp:forward page="/capsule/addCapsule.jsp"/><%
        return;
    }
    // 캡슐을 저장하고 만든 사람을 첫 참여자로 넣은 뒤 상세 화면으로
    int capsuleId = CapsuleDAO.getInstance().insert(userId, form.getTitle(), form.getDescription(), form.getOpenAt());
    MemberDAO.getInstance().insert(capsuleId, userId);
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
