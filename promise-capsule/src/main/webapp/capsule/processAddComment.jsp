<%-- 한마디 쓰기(열린 캡슐) --%>
<%@ page pageEncoding="UTF-8" import="dao.CommentDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<jsp:useBean id="form" class="dto.CommentForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 한마디 길이 확인
    if (!form.isValid()) {
        response.sendError(400);
        return;
    }
    // 열린 캡슐에만 쓸 수 있다
    if (!state.equals("OPENED")) {
        stateChanged(request, response, capsule);
        return;
    }
    // 저장하고 한마디 목록으로 이동
    CommentDAO.getInstance().insert(capsuleId, userId, form.getBody());
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId + "#comments");
%>
