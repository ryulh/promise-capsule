<%-- 캡슐 삭제(개설자, 봉인 전): 사진 파일 폴더를 비우고 캡슐을 지운다(편지, 사진, 참여 행은 CASCADE). --%>
<%@ page pageEncoding="UTF-8" import="java.io.File, util.DBConnection" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 개설자만 지울 수 있다
    if (!capsule.isOwner()) {
        forbidden(request, response, capsule);
        return;
    }
    // 봉인한 캡슐은 지울 수 없다
    if (!draftLike) {
        stateChanged(request, response, capsule);
        return;
    }
    // 사진 폴더를 비우고 캡슐을 지운 뒤 내 캡슐 목록으로
    File folder = new File(DBConnection.config.getProperty("upload.dir"), String.valueOf(capsuleId));
    if (folder.listFiles() != null) {
        for (File f : folder.listFiles()) f.delete();
    }
    folder.delete();
    CapsuleDAO.getInstance().delete(capsuleId);
    session.setAttribute("notice", "capsules.notice.deleted");
    session.setAttribute("noticeArg", capsule.getTitle());
    response.sendRedirect(request.getContextPath() + "/capsule/capsules.jsp");
%>
