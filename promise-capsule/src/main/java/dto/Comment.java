package dto;

import java.util.Date;

/** 한마디 한 개(열린 캡슐 아래에 남기는 짧은 글) */
public class Comment {
	private int id;
	private int capsuleId;
	private int userId;
	private String nickname;
	private String body;
	private Date createdAt;
	private Date editedAt;

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
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
	public String getBody() {
		return body;
	}
	public void setBody(String body) {
		this.body = body;
	}
	public Date getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}
	public Date getEditedAt() {
		return editedAt;
	}
	public void setEditedAt(Date editedAt) {
		this.editedAt = editedAt;
	}
}
