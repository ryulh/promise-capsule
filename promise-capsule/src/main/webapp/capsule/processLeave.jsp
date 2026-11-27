<%-- 참여 취소(개설자가 아닌 참여자, 봉인 전). 내 편지, 사진도 지운다. --%>
<%@ page pageEncoding="UTF-8" import="dto.Letter, dao.LetterDAO, dao.MemberDAO, dao.PhotoDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자는 참여를 취소할 수 없다(캡슐 삭제를 쓴다)
    if (capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    // 봉인한 뒤에는 취소할 수 없다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 내 사진, 참여를 지우고(편지는 함께 지워짐) 내 캡슐 목록으로
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    if (myLetter != null) PhotoDAO.getInstance().deleteByLetter(myLetter.getId());
    MemberDAO.getInstance().delete(capsuleId, userId);
    session.setAttribute("notice", "capsules.notice.left");
    session.setAttribute("noticeArg", capsule.getTitle());
    response.sendRedirect(request.getContextPath() + "/capsule/capsules.jsp");
%>
