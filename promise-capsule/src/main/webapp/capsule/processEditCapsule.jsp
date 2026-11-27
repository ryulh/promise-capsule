<%-- 정보, 여는 날 수정(개설자, 봉인 전). 기한 경과 캡슐도 여는 날을 미래로 고치면 다시 작성 중이 된다. --%>
<%@ page pageEncoding="UTF-8" import="java.time.LocalDateTime, java.util.HashMap, java.util.Map" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<jsp:useBean id="form" class="dto.CapsuleForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 입력 형식 확인
    if (!form.isValid()) {
        response.sendError(400);
        return;
    }
    // 개설자만 고칠 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    // 봉인한 캡슐은 고칠 수 없다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 여는 날: 지금부터 최소 간격 뒤 ~ 5년 안. 벗어나면 수정 화면으로
    int minMinutes = (Integer) application.getAttribute("minIntervalMinutes");
    LocalDateTime openAt = form.getOpenAt().toLocalDateTime();
    Map<String, String> errors = new HashMap<>();
    if (openAt.isBefore(LocalDateTime.now().plusMinutes(minMinutes))) errors.put("openAt", "capsuleForm.error.tooSoon");
    else if (openAt.isAfter(LocalDateTime.now().plusYears(5))) errors.put("openAt", "capsuleForm.error.tooLate");
    if (!errors.isEmpty()) {
        request.setAttribute("errors", errors);
%><jsp:forward page="/capsule/editCapsule.jsp"/><%
        return;
    }
    // 저장하고 상세 화면으로 이동
    CapsuleDAO.getInstance().update(capsuleId, form.getTitle(), form.getDescription(), form.getOpenAt());
    session.setAttribute("notice", "capsuleForm.notice.edited");
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
