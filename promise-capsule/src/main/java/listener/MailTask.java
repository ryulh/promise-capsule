package listener;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.MessageFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.Properties;
import java.util.ResourceBundle;
import java.util.TimerTask;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import util.DBConnection;

/** 개봉 알림 메일: 1분마다 열린 캡슐의 참여자 중 알림을 켜 두고 아직 안 받은 사람에게 보낸다. 3번 실패하면 그만 보낸다. */
public class MailTask extends TimerTask {

	/** 1분마다 실행: 보낼 대상을 찾아 한 명씩 보내고 결과를 기록한다 */
	@Override
	public void run() {
		String sql = "SELECT m.capsule_id, m.user_id, u.email, c.title, c.open_at FROM capsule_members m"
				+ " JOIN users u ON u.id = m.user_id JOIN capsules c ON c.id = m.capsule_id"
				+ " WHERE c.status = 'SEALED' AND c.open_at <= NOW() AND m.notified_at IS NULL"
				+ " AND m.notify_fail_count < 3 AND u.notify_on_open = TRUE";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql);
				ResultSet rs = ps.executeQuery()) {
			while (rs.next()) {
				int capsuleId = rs.getInt("capsule_id");
				String done;
				try {
					send(rs.getString("email"), capsuleId, rs.getString("title"),
							new SimpleDateFormat("yyyy-MM-dd HH:mm").format(rs.getTimestamp("open_at")) + " (KST)");
					done = "UPDATE capsule_members SET notified_at = NOW() WHERE capsule_id = ? AND user_id = ?";
				} catch (Exception e) {
					System.out.println("[MAIL] 발송 실패: 캡슐 " + capsuleId + " (" + e + ")");
					done = "UPDATE capsule_members SET notify_fail_count = notify_fail_count + 1 WHERE capsule_id = ? AND user_id = ?";
				}
				// 보냈으면 보낸 시각, 실패했으면 실패 횟수를 남긴다
				try (PreparedStatement up = conn.prepareStatement(done)) {
					up.setInt(1, capsuleId);
					up.setInt(2, rs.getInt("user_id"));
					up.executeUpdate();
				}
			}
		} catch (Exception e) {
			System.out.println("[MAIL] 메일 작업 실패: " + e);
		}
	}

	/** 메일 한 통 보내기 */
	private void send(String to, int capsuleId, String title, String opened) throws Exception {
		Properties config = DBConnection.config;
		Properties p = new Properties();
		// SMTP 서버 접속 설정(설정 파일의 계정으로 로그인)
		p.put("mail.smtp.host", config.getProperty("mail.smtp.host"));
		p.put("mail.smtp.port", config.getProperty("mail.smtp.port", "587"));
		p.put("mail.smtp.auth", "true");
		p.put("mail.smtp.starttls.enable", "true");
		Session session = Session.getInstance(p, new Authenticator() {
			@Override
			protected PasswordAuthentication getPasswordAuthentication() {
				return new PasswordAuthentication(config.getProperty("mail.user"), config.getProperty("mail.password"));
			}
		});

		// 한국어, 영어를 함께 싣는다
		ResourceBundle ko = ResourceBundle.getBundle("bundle.message", Locale.KOREAN);
		ResourceBundle en = ResourceBundle.getBundle("bundle.message", Locale.ENGLISH);
		String baseUrl = config.getProperty("app.baseUrl");
		// from=mail: 비로그인으로 열면 로그인 화면이 메일에서 온 안내를 보여 준다
		String link = baseUrl + "/capsule/capsule.jsp?id=" + capsuleId + "&from=mail";
		String meLink = baseUrl + "/account/me.jsp";

		// 보내는 사람, 받는 사람, 제목, 본문을 채워 보낸다
		MimeMessage msg = new MimeMessage(session);
		msg.setFrom(new InternetAddress(config.getProperty("mail.from"), ko.getString("common.service"), "UTF-8"));
		msg.setRecipient(Message.RecipientType.TO, new InternetAddress(to));
		msg.setSubject(fmt(ko, "mail.subject", title), "UTF-8");
		msg.setContent(htmlBody(ko, en, title, opened, link, meLink), "text/html; charset=UTF-8");
		Transport.send(msg);
	}

	/** 메일 앱 호환을 위해 표와 인라인 스타일만 쓴다. */
	private String htmlBody(ResourceBundle ko, ResourceBundle en, String title, String opened, String link,
			String meLink) {
		String t = html(title);
		String o = html(opened);
		String l = html(link);
		String me = html(meLink);
		return "<!doctype html><html lang=\"ko\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width\"></head>"
				+ "<body style=\"margin:0;padding:0;background:#F7F4EF;\">"
				+ "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#F7F4EF;\"><tr><td style=\"padding:24px 8px;\">"
				+ "<div style=\"display:none;max-height:0;overflow:hidden;mso-hide:all;font-size:1px;line-height:1px;color:#F7F4EF;\">"
				+ html(fmt(ko, "mail.preheader", opened)) + " · " + html(en.getString("mail.heading")) + "</div>"
				+ "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"max-width:600px;margin:0 auto;background:#FFFDFA;border:1px solid #DCD5CB;border-radius:12px;border-collapse:separate;overflow:hidden;font-family:'Apple SD Gothic Neo','Malgun Gothic','Noto Sans KR',Arial,sans-serif;color:#26222B;\">"
				+ "<tr><td style=\"background:#FFFDFA;padding:14px 24px;border-bottom:1px solid #DCD5CB;border-radius:11px 11px 0 0;\">"
				+ "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\"><tr>"
				// Gmail이 표 칸 높이를 늘리므로 크기를 고정한 상자로. 가운데 ◐는 글자 대신 테두리(왼쪽 반 채움)
				+ "<td width=\"28\" valign=\"middle\" style=\"width:28px;padding:0;\"><div style=\"width:24px;height:24px;border:2px solid #26222B;border-radius:50%;font-size:0;line-height:0;\"><div style=\"width:4.5px;height:9px;margin:6px auto 0;border:1.5px solid #26222B;border-left:6px solid #26222B;border-radius:50%;\"></div></div></td>"
				+ "<td style=\"padding-left:8px;font-size:15px;font-weight:700;color:#26222B;white-space:nowrap;\">"
				+ html(ko.getString("common.service")) + "</td>"
				+ "<td style=\"padding-left:6px;font-size:13px;color:#6E6772;white-space:nowrap;\" lang=\"en\">"
				+ html(en.getString("common.service")) + "</td>" + "</tr></table></td></tr>"
				+ "<tr><td style=\"padding:28px 24px 0;\">"
				+ "<p style=\"margin:0 0 8px;font-family:'Pretendard','Apple SD Gothic Neo','Malgun Gothic','Noto Sans KR',sans-serif;font-size:26px;font-weight:800;line-height:1.3;color:#26222B;\">"
				+ html(ko.getString("mail.heading")) + "</p>"
				+ "<p style=\"margin:0 0 20px;font-size:15px;line-height:1.6;color:#4E4855;\">"
				+ html(ko.getString("mail.lead")) + "</p>"
				+ "<table role=\"presentation\" width=\"100%\" cellpadding=\"0\" cellspacing=\"0\" style=\"background:#F3EFE8;border-radius:8px;\"><tr><td style=\"padding:14px 16px;font-size:14px;line-height:1.8;color:#26222B;\">"
				+ "<span style=\"color:#6E6772;\">" + html(ko.getString("mail.capsule")) + "</span>&nbsp;&nbsp;<b>" + t
				+ "</b><br>" + "<span style=\"color:#6E6772;\">" + html(ko.getString("mail.openedOn"))
				+ "</span>&nbsp;&nbsp;<b>" + o + "</b>" + "</td></tr></table>"
				+ "<table role=\"presentation\" cellpadding=\"0\" cellspacing=\"0\" style=\"margin:24px 0 0;\"><tr>"
				+ "<td style=\"background:#3A3787;border-radius:12px;\"><a href=\"" + l
				+ "\" style=\"display:inline-block;padding:14px 28px;color:#FFFFFF;font-size:16px;font-weight:700;line-height:1.2;text-decoration:none;border-radius:12px;\">"
				+ html(ko.getString("mail.button")) + " · " + html(en.getString("mail.button"))
				+ "</a></td></tr></table>"
				+ "<p style=\"margin:10px 0 0;font-size:13px;line-height:1.5;color:#6E6772;\">"
				+ html(ko.getString("mail.loginNote")) + "</p>" + "</td></tr>"
				+ "<tr><td style=\"padding:28px 24px 0;\"><div style=\"border-top:1px solid #EAE4DA;font-size:0;line-height:0;\">&nbsp;</div></td></tr>"
				+ "<tr><td style=\"padding:20px 24px 0;\" lang=\"en\">"
				+ "<p style=\"margin:0 0 6px;font-family:Georgia,'Times New Roman',serif;font-size:19px;font-weight:700;line-height:1.3;color:#26222B;\">"
				+ html(en.getString("mail.heading")) + "</p>"
				+ "<p style=\"margin:0 0 10px;font-size:14px;line-height:1.6;color:#4E4855;\">"
				+ html(en.getString("mail.lead")) + "</p>"
				+ "<p style=\"margin:0;font-size:13px;line-height:1.7;color:#4E4855;\"><span style=\"color:#6E6772;\">"
				+ html(en.getString("mail.capsule")) + ":</span> <b style=\"color:#26222B;\">" + t + "</b><br>"
				+ "<span style=\"color:#6E6772;\">" + html(en.getString("mail.openedOn"))
				+ ":</span> <b style=\"color:#26222B;\">" + o + "</b><br>" + html(en.getString("mail.loginNote"))
				+ "</p>" + "</td></tr>"
				+ "<tr><td style=\"padding:28px 24px 24px;font-size:12px;line-height:1.6;color:#6E6772;\">"
				+ html(fmt(ko, "mail.footer", title)) + " " + html(ko.getString("mail.footerOff")) + " <a href=\"" + me
				+ "\" style=\"color:#4E4855;text-decoration:underline;\">" + html(ko.getString("mail.meLink"))
				+ "</a><br>" + "<span lang=\"en\">" + html(en.getString("mail.footer")) + " "
				+ html(en.getString("mail.footerOff")) + " <a href=\"" + me
				+ "\" style=\"color:#4E4855;text-decoration:underline;\">" + html(en.getString("mail.meLink"))
				+ "</a></span>" + "</td></tr></table></td></tr></table></body></html>";
	}

	/** 메시지 번들 문장에 값 끼워 넣기 */
	private static String fmt(ResourceBundle b, String key, Object... args) {
		return MessageFormat.format(b.getString(key), args);
	}

	/** & 를 먼저 바꿔야 뒤에서 만든 &lt; 등이 다시 바뀌지 않는다. */
	private static String html(String s) {
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;")
				.replace("'", "&#39;");
	}
}
