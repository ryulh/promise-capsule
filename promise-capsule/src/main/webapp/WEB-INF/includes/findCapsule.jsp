<%-- 캡슐 찾기(loginCheck.jsp 다음에 include). 번호는 capsuleId 또는 id 파라미터. 내가 참여한 캡슐이 아니면 404(있는지조차 알리지 않음). --%>
<%@ page import="dto.Capsule, dao.CapsuleDAO" %>
<%!
    /** 그사이 상태가 바뀌어 할 수 없는 요청: 캡슐 화면으로 돌아가 지금 상태를 알린다. */
    private void stateChanged(HttpServletRequest request, HttpServletResponse response, Capsule capsule) throws java.io.IOException {
        request.getSession().setAttribute("notice", "notice.state." + capsule.getState());
        response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsule.getId());
    }

    /** 역할이 맞지 않음(개설자만 할 수 있는 일 등): 403 화면에 캡슐로 돌아가는 버튼을 단다. */
    private void forbidden(HttpServletRequest request, HttpServletResponse response, Capsule capsule) throws java.io.IOException {
        request.setAttribute("errCapsuleId", capsule.getId());
        response.sendError(403);
    }
%>
<%
    // 캡슐 번호를 읽어 내가 참여한 캡슐인지 확인
    String idParam = request.getParameter("capsuleId") != null ? request.getParameter("capsuleId") : request.getParameter("id");
    if (idParam == null) idParam = (String) request.getAttribute("capsuleId");   // 편지 저장(multipart)에서 넘어온 경우
    int capsuleId = Integer.parseInt(idParam);
    Capsule capsule = CapsuleDAO.getInstance().find(capsuleId, (Integer) session.getAttribute("userId"));
    if (capsule == null) {
        response.sendError(404);
        return;
    }
    // 화면 상태를 정해 두고 화면에서도 쓰도록 request에 담는다
    String state = capsule.getState();
    boolean draftLike = state.equals("DRAFT") || state.equals("OVERDUE");   // 작성 중 또는 기한 경과
    request.setAttribute("capsule", capsule);
%>
