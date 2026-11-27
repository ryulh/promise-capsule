<%@ page pageEncoding="UTF-8" trimDirectiveWhitespaces="true" import="java.io.File, java.nio.file.Files, java.net.URLEncoder, java.nio.charset.StandardCharsets, dto.Photo, dto.Capsule, dao.PhotoDAO, dao.CapsuleDAO" %>
<%-- 사진 응답: 사진은 웹 루트 밖에 있어 이 JSP로만 볼 수 있다. 열림이면 참여자 누구나, 잠김이면 아무도, 작성 중이면 내 사진만. --%>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%
    // 사진과 그 캡슐을 찾는다. 내가 참여한 캡슐이 아니거나 파일이 없으면 404
    int photoId = Integer.parseInt(request.getParameter("id"));
    boolean download = "1".equals(request.getParameter("download"));
    Photo photo = PhotoDAO.getInstance().find(photoId);
    Capsule capsule = photo == null ? null : CapsuleDAO.getInstance().find(photo.getCapsuleId(), userId);
    if (capsule == null || !PhotoDAO.fileOf(photo).isFile()) {
        response.sendError(404);
        return;
    }
    String state = capsule.getState();
    if (state.equals("LOCKED")) {   // "403 잠김" 화면에 남은 기간을 보여 준다
        long seconds = capsule.getRemainingSeconds();
        request.setAttribute("errLocked", true);
        request.setAttribute("errCapsuleId", capsule.getId());
        request.setAttribute("errRemainDays", seconds / 86400);
        request.setAttribute("errRemainHours", seconds % 86400 / 3600);
        response.sendError(403);
        return;
    }
    // 작성 중에는 내 사진 보기만 된다(내려받기는 열린 뒤에)
    if (!state.equals("OPENED") && (download || photo.getWriterId() != userId)) {
        request.setAttribute("errCapsuleId", capsule.getId());
        response.sendError(403);
        return;
    }
    // 원래 파일 이름으로 사진 바이트를 보낸다
    String fileName = URLEncoder.encode(photo.getOriginalName(), StandardCharsets.UTF_8).replace("+", "%20");
    response.setContentType(photo.getMimeType());
    response.setHeader("Content-Disposition", (download ? "attachment" : "inline") + "; filename*=UTF-8''" + fileName);
    out.clear();
    Files.copy(PhotoDAO.fileOf(photo).toPath(), response.getOutputStream());
    out = pageContext.pushBody();   // 이미 바이트로 보냈으므로 JSP가 끝에서 글자 출력기를 다시 쓰지 않게
%>
