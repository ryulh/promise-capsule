package dto;

/** 회원 번호는 폼으로 받지 않는다(세션에서만). */
public class MeForm {
	private String nickname;
	private String email;
	private String notifyOnOpen;

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
	public String getNotifyOnOpen() {
		return notifyOnOpen;
	}
	public void setNotifyOnOpen(String notifyOnOpen) {
		this.notifyOnOpen = notifyOnOpen;
	}
}
