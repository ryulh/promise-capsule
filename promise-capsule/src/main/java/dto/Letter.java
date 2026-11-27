package dto;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/** 편지 한 통. 철회하면 body는 null. */
public class Letter {
	private int id;
	private int capsuleId;
	private int userId;
	private String nickname;
	private String body;
	private Date createdAt;
	private Date updatedAt;
	private Date withdrawnAt;
	private List<Photo> photos = new ArrayList<>();

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
	public Date getUpdatedAt() {
		return updatedAt;
	}
	public void setUpdatedAt(Date updatedAt) {
		this.updatedAt = updatedAt;
	}
	public Date getWithdrawnAt() {
		return withdrawnAt;
	}
	public void setWithdrawnAt(Date withdrawnAt) {
		this.withdrawnAt = withdrawnAt;
	}
	public List<Photo> getPhotos() {
		return photos;
	}
	public void setPhotos(List<Photo> photos) {
		this.photos = photos;
	}
}
