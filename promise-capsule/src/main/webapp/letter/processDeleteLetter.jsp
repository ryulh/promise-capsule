<%-- 내 편지, 사진 모두 지우기(봉인 전) --%>
<%@ page pageEncoding="UTF-8" import="dto.Letter, dao.LetterDAO, dao.PhotoDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 봉인 전이고 내 편지가 있을 때만
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    if (!draftLike || myLetter == null) {
        stateChanged(request, response, capsule);
        return;
    }
    // 사진과 편지를 지우고 상세 화면으로
    PhotoDAO.getInstance().deleteByLetter(myLetter.getId());
    LetterDAO.getInstance().delete(myLetter.getId());
    session.setAttribute("notice", "draft.notice.letterDeleted");
    session.setAttribute("clearDraft", capsuleId);
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
