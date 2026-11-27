package listener;

import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.Properties;
import java.util.Timer;
import java.util.TimeZone;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import util.DBConnection;

/** 서버 시작 때 한 번: 설정 파일 읽기, 시간대(KST), 메일 비밀번호가 있으면 개봉 알림 메일 작업(1분마다) 시작. */
public class AppListener implements ServletContextListener {

	private Timer timer;

	/** 서버가 시작될 때 한 번 실행 */
	@Override
	public void contextInitialized(ServletContextEvent event) {
		ServletContext application = event.getServletContext();
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Seoul"));
		Locale.setDefault(Locale.KOREA);

		Properties config = DBConnection.config;
		try (InputStream in = application.getResourceAsStream("/WEB-INF/config/app.properties")) {
			config.load(new InputStreamReader(in, StandardCharsets.UTF_8));
		} catch (Exception e) {
			throw new IllegalStateException("WEB-INF/config/app.properties를 읽을 수 없어요(app.properties.example 참고)", e);
		}

		new File(config.getProperty("upload.dir")).mkdirs();   // 사진 폴더(없으면 만든다)

		// 화면 문구에 쓰는 값: 서비스 주소, 봉인 뒤 최소 개봉 간격(1440분 -> 1일)
		application.setAttribute("baseUrl", config.getProperty("app.baseUrl"));
		int minutes = Integer.parseInt(config.getProperty("seal.minIntervalMinutes", "1440"));
		String unit = minutes % 1440 == 0 ? "day" : minutes % 60 == 0 ? "hour" : "minute";
		application.setAttribute("minIntervalMinutes", minutes);
		application.setAttribute("minIntervalUnit", unit);
		application.setAttribute("minIntervalAmount",
				unit.equals("day") ? minutes / 1440 : unit.equals("hour") ? minutes / 60 : minutes);

		// 메일 비밀번호가 있을 때만 1분마다 메일 작업 시작
		if (!config.getProperty("mail.password", "").isBlank()) {
			timer = new Timer(true);
			timer.schedule(new MailTask(), 0, 60 * 1000);
		}
	}

	/** 서버가 멈출 때 메일 작업도 멈춘다 */
	@Override
	public void contextDestroyed(ServletContextEvent event) {
		if (timer != null)
			timer.cancel();
	}
}
