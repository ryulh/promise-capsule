<%-- 처음 열어 봤다고 기록(개봉 연출이 끝나거나 건너뛸 때) --%>
<%@ page pageEncoding="UTF-8" import="dao.MemberDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 열린 캡슐만 기록한다
    if (!state.equals("OPENED")) {
        stateChanged(request, response, capsule);
        return;
    }
    // 처음 본 시각을 남기고 상세 화면으로
    MemberDAO.getInstance().markFirstOpened(capsuleId, userId);
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
