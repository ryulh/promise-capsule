package dto;

/** 로그인 폼 빈(아이디 저장 체크 포함) */
public class LoginForm {
	private String loginId;
	private String password;
	private String saveId;

	public String getLoginId() {
		return loginId;
	}
	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getSaveId() {
		return saveId;
	}
	public void setSaveId(String saveId) {
		this.saveId = saveId;
	}
}
