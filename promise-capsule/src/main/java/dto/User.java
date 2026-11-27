package dto;

import java.util.Date;

/** 회원 한 명 */
public class User {
	private int id;
	private String loginId;
	private String passwordHash;
	private String nickname;
	private String email;
	private boolean notifyOnOpen;
	private Date createdAt;

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getLoginId() {
		return loginId;
	}
	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}
	public String getPasswordHash() {
		return passwordHash;
	}
	public void setPasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
	}
	public String getNickname() {
		return nickname;
	}
	public void setNickname(String nickname) {
		this.nickname = nickname;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public boolean isNotifyOnOpen() {
		return notifyOnOpen;
	}
	public void setNotifyOnOpen(boolean notifyOnOpen) {
		this.notifyOnOpen = notifyOnOpen;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
}
