<%-- 참여자 내보내기(개설자, 봉인 전). 그 사람의 편지, 사진도 지운다. reissue=true면 초대 링크도 새로 만든다. --%>
<%@ page pageEncoding="UTF-8" import="dto.Member, dao.MemberDAO, dao.PhotoDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만 내보낼 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    // 봉인한 뒤에는 내보낼 수 없다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    int memberUserId = Integer.parseInt(request.getParameter("memberUserId"));
    // 내보낼 사람이 이 캡슐의 참여자인지 확인
    Member target = null;
    for (Member m : MemberDAO.getInstance().listByCapsule(capsuleId)) {
        if (m.getUserId() == memberUserId && memberUserId != capsule.getOwnerId()) target = m;
    }
    if (target == null) {   // 이 캡슐의 참여자가 아니거나 개설자 자신
        response.sendError(404);
        return;
    }
    // 그 사람의 사진, 참여를 지우고(편지는 함께 지워짐) 필요하면 초대 링크도 새로
    if (target.getLetterId() > 0) PhotoDAO.getInstance().deleteByLetter(target.getLetterId());
    MemberDAO.getInstance().delete(capsuleId, memberUserId);
    boolean reissue = "true".equals(request.getParameter("reissue"));
    if (reissue) CapsuleDAO.getInstance().changeInviteCode(capsuleId);
    session.setAttribute("notice", reissue ? "draft.notice.removed" : "draft.notice.removedKeepLink");
    session.setAttribute("noticeArg", target.getNickname());
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
