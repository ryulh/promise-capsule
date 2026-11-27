package dto;

import java.util.Date;

/** 참여자 한 명과 그 사람의 편지 상태. */
public class Member {
	private int capsuleId;
	private int userId;
	private String nickname;
	private int letterId;
	private Date withdrawnAt;
	private int photoCount;

	public int getCapsuleId() {
		return capsuleId;
	}
	public void setCapsuleId(int capsuleId) {
		this.capsuleId = capsuleId;
	}
	public int getUserId() {
		return userId;
	}
	public void setUserId(int userId) {
		this.userId = userId;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public int getLetterId() {
		return letterId;
	}
	public void setLetterId(int letterId) {
		this.letterId = letterId;
	}
	public Date getWithdrawnAt() {
		return withdrawnAt;
	}
	public void setWithdrawnAt(Date withdrawnAt) {
		this.withdrawnAt = withdrawnAt;
	}
	public int getPhotoCount() {
		return photoCount;
	}
	public void setPhotoCount(int photoCount) {
		this.photoCount = photoCount;
	}

	/** 편지 상태: NONE, WRITTEN, WITHDRAWN */
	public String getLetterStatus() {
		if (letterId == 0)
			return "NONE";
		return withdrawnAt == null ? "WRITTEN" : "WITHDRAWN";
	}
}
