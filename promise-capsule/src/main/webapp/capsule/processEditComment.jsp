<%-- 내 한마디 고치기, 지우기(action=delete). 한마디 번호로 캡슐을 거꾸로 찾는다. --%>
<%@ page pageEncoding="UTF-8" import="dto.Comment, dto.Capsule, dao.CapsuleDAO, dao.CommentDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<jsp:useBean id="form" class="dto.CommentForm" scope="request"/>
<jsp:setProperty name="form" property="*"/>
<%
    // 고치기면 길이 확인(지우기는 본문이 없다)
    boolean delete = "delete".equals(request.getParameter("action"));
    if (!delete && !form.isValid()) {
        response.sendError(400);
        return;
    }
    // 한마디와 그 캡슐을 찾는다. 내가 참여한 캡슐이 아니면 404
    int commentId = Integer.parseInt(request.getParameter("commentId"));
    Comment comment = CommentDAO.getInstance().find(commentId);
    Capsule capsule = comment == null ? null : CapsuleDAO.getInstance().find(comment.getCapsuleId(), userId);
    if (capsule == null) {
        response.sendError(404);
        return;
    }
    // 내가 쓴 한마디만 고치거나 지울 수 있다
    if (comment.getUserId() != userId) {
        request.setAttribute("errCapsuleId", capsule.getId());
        response.sendError(403);
        return;
    }
    // 지우거나 고친 뒤 캡슐 화면으로 이동
    if (delete) {
        CommentDAO.getInstance().delete(commentId);
        response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsule.getId() + "#comments");
    } else {
        CommentDAO.getInstance().update(commentId, form.getBody());
        response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsule.getId() + "#c" + commentId);
    }
%>
