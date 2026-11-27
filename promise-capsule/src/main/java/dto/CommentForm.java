package dto;

/** 한마디 폼 빈 */
public class CommentForm {
	private String body = "";

	public String getBody() {
		return body;
	}
	public void setBody(String body) {
		this.body = body.replace("\r\n", "\n").strip();
	}

	/** 1~300자 */
	public boolean isValid() {
		int n = body.codePointCount(0, body.length());
		return n >= 1 && n <= 300;
	}
}
