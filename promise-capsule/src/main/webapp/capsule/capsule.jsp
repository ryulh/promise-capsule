<%-- 캡슐 상세: 상태에 따라 조각을 고른다(작성 중 / 잠김 / 열림). 버튼을 보일지도 여기서 정한다. --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List, dto.Member, dto.Letter, dao.MemberDAO, dao.LetterDAO, dao.PhotoDAO, dao.CommentDAO" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    boolean owner = capsule.isOwner();
    // 참여자 목록과 내 편지를 읽는다
    List<Member> members = MemberDAO.getInstance().listByCapsule(capsuleId);
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    boolean hasMyLetter = myLetter != null && myLetter.getWithdrawnAt() == null;
    boolean solo = members.size() == 1 && owner && myLetter == null;   // 개설자 혼자이고 편지가 없는 상태
    request.setAttribute("members", members);
    request.setAttribute("myLetter", myLetter);
    request.setAttribute("hasMyLetter", hasMyLetter);
    request.setAttribute("solo", solo);
    request.setAttribute("canManage", owner && draftLike);    // 정보 수정, 삭제, 초대 링크 새로, 내보내기
    request.setAttribute("canLeave", !owner && draftLike);
    request.setAttribute("canWithdraw", hasMyLetter && !draftLike);

    if (draftLike) {
        // 내 편지가 없으면 내 편지 카드를 위로
        request.setAttribute("bodyState", solo ? "solo" : hasMyLetter ? "" : "empty");
        if (hasMyLetter) request.setAttribute("myPhotos", PhotoDAO.getInstance().listByLetter(myLetter.getId()));
    }
    // 열림: 편지 카드와 한마디, 처음 열어 보는지
    if (state.equals("OPENED")) {
        request.setAttribute("firstOpen", capsule.getMyFirstOpenedAt() == null);
        request.setAttribute("letters", LetterDAO.getInstance().listByCapsule(capsuleId, userId));
        request.setAttribute("comments", CommentDAO.getInstance().listByCapsule(capsuleId));
        String edit = request.getParameter("editComment");
        request.setAttribute("editCommentId", edit == null ? 0 : Integer.parseInt(edit));
    }

    // 봉인 애니메이션은 봉인 직후 한 번만
    if (Integer.valueOf(capsuleId).equals(session.getAttribute("sealAnim"))) {
        request.setAttribute("sealAnim", true);
        session.removeAttribute("sealAnim");
    }
%>
<c:set var="pageTitle" value="${capsule.title}"/>
<%@ include file="/WEB-INF/includes/header.jsp" %>
  <main class="page">
    <div class="wrap">
      <c:choose>
        <c:when test="${capsule.state == 'DRAFT' || capsule.state == 'OVERDUE'}"><jsp:include page="/WEB-INF/includes/capsuleDraft.jsp"/></c:when>
        <c:when test="${capsule.state == 'LOCKED'}"><jsp:include page="/WEB-INF/includes/capsuleLocked.jsp"/></c:when>
        <c:otherwise><jsp:include page="/WEB-INF/includes/capsuleOpened.jsp"/></c:otherwise>
      </c:choose>
    </div>
  </main>
<%@ include file="/WEB-INF/includes/footer.jsp" %>
