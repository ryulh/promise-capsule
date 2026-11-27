<%-- 봉인(개설자, 작성 중). 편지가 없거나, 여는 날이 너무 가깝거나, 미작성자 확인이 없으면 seal.jsp로 forward. 성공하면 봉인 애니메이션 한 번. --%>
<%@ page pageEncoding="UTF-8" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만 봉인할 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    if (!state.equals("DRAFT")) {   // 기한 경과면 여는 날부터 다시 정해야 한다
        stateChanged(request, response, capsule);
        return;
    }
    // 편지가 없거나 여는 날이 너무 가깝거나 미작성자 확인이 없으면 확인 화면으로 돌려보낸다
    int minMinutes = (Integer) application.getAttribute("minIntervalMinutes");
    String sealError = null;
    if (capsule.getLetterCount() == 0) sealError = "noLetter";
    else if (capsule.getOpenAt().getTime() < System.currentTimeMillis() + minMinutes * 60000L) sealError = "tooSoon";
    else if (capsule.getLetterCount() < capsule.getMemberCount() && !"true".equals(request.getParameter("confirmMissing"))) sealError = "confirm";
    if (sealError != null) {
        request.setAttribute("sealError", sealError);
%><jsp:forward page="/capsule/seal.jsp"/><%
        return;
    }
    // 봉인하고 상세 화면으로 이동(봉인 애니메이션 한 번)
    CapsuleDAO.getInstance().seal(capsuleId);
    session.setAttribute("notice", "locked.notice.sealed");
    session.setAttribute("sealAnim", capsuleId);
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
