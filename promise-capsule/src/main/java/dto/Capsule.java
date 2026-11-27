package dto;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Date;

/** 캡슐 한 개. owner, my...는 보는 사람 기준, ...Count는 조회할 때 SQL로 센 값. */
public class Capsule {
	private int id;
	private int ownerId;
	private String title;
	private String description;
	private Date openAt;
	private String status;
	private String inviteCode;
	private Date sealedAt;
	private String ownerNickname;
	private boolean owner;
	private int memberCount;
	private int letterCount;
	private int photoCount;
	private int notWrittenCount;
	private Date myFirstOpenedAt;
	private boolean myLetterWritten;

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getOwnerId() {
		return ownerId;
	}
	public void setOwnerId(int ownerId) {
		this.ownerId = ownerId;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
	public Date getOpenAt() {
		return openAt;
	}
	public void setOpenAt(Date openAt) {
		this.openAt = openAt;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getInviteCode() {
		return inviteCode;
	}
	public void setInviteCode(String inviteCode) {
		this.inviteCode = inviteCode;
	}
	public Date getSealedAt() {
		return sealedAt;
	}
	public void setSealedAt(Date sealedAt) {
		this.sealedAt = sealedAt;
	}
	public String getOwnerNickname() {
		return ownerNickname;
	}
	public void setOwnerNickname(String ownerNickname) {
		this.ownerNickname = ownerNickname;
	}
	public boolean isOwner() {
		return owner;
	}
	public void setOwner(boolean owner) {
		this.owner = owner;
	}
	public int getMemberCount() {
		return memberCount;
	}
	public void setMemberCount(int memberCount) {
		this.memberCount = memberCount;
	}
	public int getLetterCount() {
		return letterCount;
	}
	public void setLetterCount(int letterCount) {
		this.letterCount = letterCount;
	}
	public int getPhotoCount() {
		return photoCount;
	}
	public void setPhotoCount(int photoCount) {
		this.photoCount = photoCount;
	}
	public int getNotWrittenCount() {
		return notWrittenCount;
	}
	public void setNotWrittenCount(int notWrittenCount) {
		this.notWrittenCount = notWrittenCount;
	}
	public Date getMyFirstOpenedAt() {
		return myFirstOpenedAt;
	}
	public void setMyFirstOpenedAt(Date myFirstOpenedAt) {
		this.myFirstOpenedAt = myFirstOpenedAt;
	}
	public boolean isMyLetterWritten() {
		return myLetterWritten;
	}
	public void setMyLetterWritten(boolean myLetterWritten) {
		this.myLetterWritten = myLetterWritten;
	}

	/** 저장 상태(DRAFT, SEALED)와 지금 시각으로 화면 상태를 정한다: 작성 중, 기한 경과, 잠김, 열림 */
	public String getState() {
		boolean beforeOpen = new Date().before(openAt);
		if ("SEALED".equals(status))
			return beforeOpen ? "LOCKED" : "OPENED";
		return beforeOpen ? "DRAFT" : "OVERDUE";
	}
	/** 정원(6명)이 찼는지 */
	public boolean isFull() {
		return memberCount >= 6;
	}
	/** 여는 날까지 남은 날(오늘이면 0) */
	public long getDDay() {
		return ChronoUnit.DAYS.between(LocalDate.now(), toDate(openAt));
	}
	/** 여는 시각까지 남은 초(카운트다운용) */
	public long getRemainingSeconds() {
		return Math.max(0, (openAt.getTime() - System.currentTimeMillis()) / 1000);
	}
	/** 봉인한 날부터 연 날까지 */
	public long getDaysSealed() {
		return sealedAt == null ? 0 : ChronoUnit.DAYS.between(toDate(sealedAt), toDate(openAt));
	}
	/** 열렸는데 내가 아직 안 열어 본 캡슐 */
	public boolean isNewlyOpened() {
		return "OPENED".equals(getState()) && myFirstOpenedAt == null;
	}
	/** 목록의 할 일 한 줄 */
	public String getTodo() {
		String state = getState();
		if (state.equals("LOCKED") || state.equals("OPENED"))
			return "done";
		if (state.equals("OVERDUE"))
			return owner ? "overdueOwner" : "overdueMember";
		if (!myLetterWritten)
			return "noLetter";
		if (owner && letterCount == memberCount)
			return "canSeal";
		return "done";
	}
	/** 할 일을 강조해서 보여 줄지(내가 할 일이 남았을 때) */
	public boolean isTodoActive() {
		String todo = getTodo();
		return !todo.equals("done") && !todo.equals("overdueMember");
	}
	/** 날짜 부분만 떼어 낸다 */
	private static LocalDate toDate(Date d) {
		return new Timestamp(d.getTime()).toLocalDateTime().toLocalDate();
	}
}
