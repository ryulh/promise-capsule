package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** 수업 예제 dbconn.jsp를 클래스로 옮긴 것. 접속 정보는 서버가 시작할 때 읽은 app.properties에서 가져온다. */
public class DBConnection {

	/** AppListener가 서버 시작 때 채운다(DB, 사진 폴더, 주소, 메일 설정). */
	public static Properties config = new Properties();

	public static Connection getConnection() throws SQLException {
		try {
			// 드라이버를 올리고 설정 파일의 주소, 계정으로 연결한다
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			throw new SQLException("JDBC 드라이버를 찾을 수 없어요", e);
		}
		return DriverManager.getConnection(config.getProperty("db.url"), config.getProperty("db.user"),
				config.getProperty("db.password"));
	}
}
