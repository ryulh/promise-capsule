<%-- 편지 저장: cos MultipartRequest로 사진을 업로드 폴더에 먼저 받고, 확인이 끝나면 캡슐 폴더로 옮긴다.
     사진에 문제가 있으면 받은 파일을 지우고 아무것도 저장하지 않은 채 letter.jsp로 forward한다(본문은 유지). --%>
<%@ page pageEncoding="UTF-8" import="java.io.*, java.nio.file.*, java.util.*, com.oreilly.servlet.MultipartRequest, com.oreilly.servlet.multipart.DefaultFileRenamePolicy, dto.Letter, dto.Photo, dao.LetterDAO, dao.PhotoDAO, util.DBConnection" %>
<%@ include file="/WEB-INF/includes/loginCheck.jsp" %>
<%!
    /** 이번 요청에서 받은 사진 파일을 지운다(저장하지 않을 때). */
    private void deleteUploads(MultipartRequest multi) {
        for (int k = 1; k <= 3; k++) {
            if (multi.getFile("photo" + k) != null) multi.getFile("photo" + k).delete();
        }
    }
%>
<%
    // 사진과 글을 함께 받는다(파일은 일단 업로드 폴더에 저장됨)
    MultipartRequest multi;
    try {
        multi = new MultipartRequest(request, DBConnection.config.getProperty("upload.dir"), 25 * 1024 * 1024, "UTF-8", new DefaultFileRenamePolicy());
    } catch (IOException e) {
        // 25MB를 넘으면 cos가 읽기를 멈춘다. 남은 요청을 읽어 버려야 연결이 끊기지 않고 400 화면이 나간다.
        InputStream rest = request.getInputStream();
        byte[] buf = new byte[64 * 1024];
        while (rest.read(buf) != -1) { }
        response.sendError(400);
        return;
    }
    // multipart는 request.getParameter로 읽을 수 없어 캡슐 번호를 속성으로 넘긴다
    request.setAttribute("capsuleId", multi.getParameter("capsuleId"));
%>
<%@ include file="/WEB-INF/includes/findCapsule.jsp" %>
<%
    // 본문 길이 확인(1~2000자)
    String body = multi.getParameter("body") == null ? "" : multi.getParameter("body").replace("\r\n", "\n").strip();
    int bodyLength = body.codePointCount(0, body.length());
    if (bodyLength < 1 || bodyLength > 2000) {
        deleteUploads(multi);
        response.sendError(400);
        return;
    }
    // 봉인 전에만 쓸 수 있다
    if (!draftLike) {
        deleteUploads(multi);
        stateChanged(request, response, capsule);
        return;
    }

    // 지울 사진은 내 편지의 사진이어야 하고, 저장된 사진 칸을 바꿔 끼우려면 그 사진을 지워야 한다
    Letter myLetter = LetterDAO.getInstance().find(capsuleId, userId);
    List<Photo> existing = myLetter == null ? new ArrayList<>() : PhotoDAO.getInstance().listByLetter(myLetter.getId());
    List<Photo> removed = new ArrayList<>();
    String[] deleteIds = multi.getParameterValues("deletePhotoId");
    for (Photo p : existing) {
        if (deleteIds != null && Arrays.asList(deleteIds).contains(String.valueOf(p.getId()))) removed.add(p);
    }
    boolean badSlot = deleteIds != null && removed.size() != deleteIds.length;
    for (int k = 1; k <= existing.size(); k++) {
        if (multi.getFile("photo" + k) != null && !removed.contains(existing.get(k - 1))) badSlot = true;
    }
    if (badSlot) {
        deleteUploads(multi);
        response.sendError(404);
        return;
    }

    // 사진 검사: jpg, png만, 장당 5MB, 합계 16MB, 저장된 것과 합쳐 3장까지
    Map<String, String> errors = new LinkedHashMap<>();
    Map<String, String> fileNames = new HashMap<>();
    long total = 0;
    int count = existing.size() - removed.size();
    for (int k = 1; k <= 3; k++) {
        File file = multi.getFile("photo" + k);
        if (file == null) continue;
        String name = multi.getOriginalFileName("photo" + k);
        fileNames.put("photo" + k, name);
        total += file.length();
        count++;
        if (!name.toLowerCase().matches(".*\\.(jpg|jpeg|png)")) errors.put("photo" + k, "letter.error.type");
        else if (file.length() == 0 || file.length() > 5 * 1024 * 1024) errors.put("photo" + k, "letter.error.size");
    }
    if (errors.isEmpty() && total > 16 * 1024 * 1024) errors.put("photos", "letter.error.size");
    if (errors.isEmpty() && count > 3) errors.put("photos", "letter.error.count");
    if (!errors.isEmpty()) {
        deleteUploads(multi);
        request.setAttribute("errors", errors);
        request.setAttribute("fileNames", fileNames);
        request.setAttribute("bodyValue", body);
%><jsp:forward page="/letter/letter.jsp"/><%
        return;
    }

    // 저장: 편지 -> 지운 사진 -> 새 사진(바꿔 끼운 칸은 그 자리 순서를, 뒤 칸은 맨 뒤 순서를 받는다)
    int letterId;
    if (myLetter == null) {
        letterId = LetterDAO.getInstance().insert(capsuleId, userId, body);
    } else {
        letterId = myLetter.getId();
        LetterDAO.getInstance().updateBody(letterId, body);
    }
    for (Photo p : removed) PhotoDAO.getInstance().delete(p);
    int maxOrder = 0;
    for (Photo p : existing) maxOrder = Math.max(maxOrder, p.getSortOrder());
    File folder = new File(DBConnection.config.getProperty("upload.dir"), String.valueOf(capsuleId));
    folder.mkdirs();
    for (int k = 1; k <= 3; k++) {
        File file = multi.getFile("photo" + k);
        if (file == null) continue;
        File saved = new DefaultFileRenamePolicy().rename(new File(folder, file.getName()));   // 같은 이름이 있으면 번호를 붙인다(빈 파일로 자리를 잡아 둠)
        Files.move(file.toPath(), saved.toPath(), StandardCopyOption.REPLACE_EXISTING);
        Photo p = new Photo();
        p.setLetterId(letterId);
        p.setStoredName(saved.getName());
        p.setOriginalName(multi.getOriginalFileName("photo" + k));
        p.setMimeType(file.getName().toLowerCase().endsWith(".png") ? "image/png" : "image/jpeg");
        p.setSizeBytes((int) saved.length());
        p.setSortOrder(k <= existing.size() ? existing.get(k - 1).getSortOrder() : ++maxOrder);
        PhotoDAO.getInstance().insert(p);
    }
    session.setAttribute("notice", "draft.notice.saved");
    session.setAttribute("clearDraft", capsuleId); // 편지 임시 보관본 지우기 신호
    response.sendRedirect(request.getContextPath() + "/capsule/capsule.jsp?id=" + capsuleId);
%>
