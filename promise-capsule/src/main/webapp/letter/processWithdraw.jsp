<%-- 내 편지 철회(봉인 뒤): 본문과 사진을 지우고 "지운 편지" 자리만 남긴다. --%>
<%@ page pageEncoding="UTF-8" import="dto.Letter, dao.LetterDAO, dao.PhotoDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 내 편지를 찾는다
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    if (myLetter == null) {   // 편지를 쓰지 않은 사람
        forbidden(request, response, capsule);
        return;
    }
    // 봉인 뒤에만, 한 번만 철회할 수 있다
    if (draftLike || myLetter.getWithdrawnAt() != null) {
        stateChanged(request, response, capsule);
        return;
    }
    // 사진을 지우고 본문을 비운 뒤 상세 화면으로
    PhotoDAO.getInstance().deleteByLetter(myLetter.getId());
    LetterDAO.getInstance().withdraw(myLetter.getId());
    session.setAttribute("notice", state.equals("OPENED") ? "opened.notice.withdrawn" : "locked.notice.withdrawn");
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
