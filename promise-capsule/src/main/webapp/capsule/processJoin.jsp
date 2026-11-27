<%-- 참여: 캡슐 번호는 받지 않고 초대 코드로만 찾는다. 참여할 수 없으면 join.jsp로 forward해 이유를 보여 준다. --%>
<%@ page pageEncoding="UTF-8" import="dto.Capsule, dao.CapsuleDAO, dao.MemberDAO" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%
    // 초대 코드로 캡슐을 찾고, 참여할 수 없는 이유가 있는지 확인
    String code = request.getParameter("code");
    if (code == null) code = (String) session.getAttribute("inviteCode");
    Capsule capsule = CapsuleDAO.getInstance().findByInviteCode(code, userId);
    String joinStatus = null;
    if (capsule == null) joinStatus = "INVALID";                       // 코드 없음, 재발급, 삭제
    else if (MemberDAO.getInstance().exists(capsule.getId(), userId)) joinStatus = "MEMBER";
    else if (!"DRAFT".equals(capsule.getStatus())) joinStatus = "SEALED";
    else if (capsule.isFull()) joinStatus = "FULL";

    // 참여할 수 있으면 참여자로 넣는다
    if (joinStatus == null) {
        MemberDAO.getInstance().insert(capsule.getId(), userId);
        session.setAttribute("notice", "draft.notice.joined");
    }
    if (joinStatus == null || joinStatus.equals("MEMBER")) {   // 이미 참여 중이면 등록 없이 캡슐로
        session.removeAttribute("inviteCode");
        response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsule.getId());
        return;
    }
    // 참여할 수 없으면 이유를 담아 참여 확인 화면으로
    request.setAttribute("joinStatus", joinStatus);
%><jsp:forward page="/capsule/join.jsp"/>
