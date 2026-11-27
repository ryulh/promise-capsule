<%-- 초대 링크 새로 만들기(개설자, 봉인 전). 이전 링크는 바로 쓸 수 없게 된다. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만 바꿀 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    // 봉인한 뒤에는 초대 링크가 필요 없다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 새 코드로 바꾸고 상세 화면으로
    CapsuleDAO.getInstance().changeInviteCode(capsuleId);
    session.setAttribute("notice", "draft.notice.reissued");
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
