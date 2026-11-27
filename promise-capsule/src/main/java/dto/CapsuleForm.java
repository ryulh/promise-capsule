package dto;

import java.sql.Timestamp;

/** 캡슐 만들기, 정보 수정 폼 빈. 여는 일시는 날짜(yyyy-MM-dd)와 시각(HH:mm) 두 칸. */
public class CapsuleForm {
	private String title = "";
	private String description = "";
	private String openDate;
	private String openTime;

	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title.strip();
	}
	public String getDescription() {
		return description;
	}
	/** 줄바꿈 CRLF를 LF로 바꿔 브라우저와 같은 글자 수로 센다. */
	public void setDescription(String description) {
		this.description = description.replace("\r\n", "\n").strip();
	}
	public String getOpenDate() {
		return openDate;
	}
	public void setOpenDate(String openDate) {
		this.openDate = openDate;
	}
	public String getOpenTime() {
		return openTime;
	}
	public void setOpenTime(String openTime) {
		this.openTime = openTime;
	}

	/** 날짜와 시각을 합친 여는 일시(형식이 틀리거나 2월 30일처럼 없는 날짜면 null) */
	public Timestamp getOpenAt() {
		try {
			Timestamp at = Timestamp.valueOf(openDate + " " + openTime + ":00");
			// 없는 날짜는 다음 달로 넘어가므로, 되돌린 글자가 입력과 같은지 본다
			return at.toString().startsWith(openDate + " " + openTime) ? at : null;
		} catch (RuntimeException e) {
			return null;
		}
	}

	/** 브라우저 검사와 같은 형식 규칙: 제목 1~40자, 설명 200자 이하, 여는 일시 있음 */
	public boolean isValid() {
		int t = title.codePointCount(0, title.length());
		int d = description.codePointCount(0, description.length());
		return t >= 1 && t <= 40 && d <= 200 && getOpenAt() != null;
	}
}
