package dao;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import dto.User;
import util.DBConnection;

/** 회원 테이블 담당 DAO */
public class UserDAO {

	private static final UserDAO instance = new UserDAO();

	public static UserDAO getInstance() {
		return instance;
	}

	/** 회원 가입 저장. 새 회원 번호를 돌려준다. */
	public int insert(User user) throws SQLException {
		String sql = "INSERT INTO users (login_id, password_hash, nickname, email, notify_on_open, created_at)"
				+ " VALUES (?, ?, ?, ?, TRUE, NOW())";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setString(1, user.getLoginId());
			ps.setString(2, user.getPasswordHash());
			ps.setString(3, user.getNickname());
			ps.setString(4, user.getEmail());
			ps.executeUpdate();
			ResultSet keys = ps.getGeneratedKeys();
			keys.next();
			return keys.getInt(1);
		}
	}

	/** 회원 번호로 찾기(없으면 null) */
	public User findById(int id) throws SQLException {
		return find("SELECT * FROM users WHERE id = ?", String.valueOf(id));
	}

	/** 아이디로 찾기(로그인, 아이디 중복 확인) */
	public User findByLoginId(String loginId) throws SQLException {
		return find("SELECT * FROM users WHERE login_id = ?", loginId);
	}

	/** 닉네임 중복(대소문자 무시). exceptId는 빼고 본다(가입이면 0). */
	public boolean existsNickname(String nickname, int exceptId) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM users WHERE nickname = ? AND id <> ?")) {
			ps.setString(1, nickname);
			ps.setInt(2, exceptId);
			return ps.executeQuery().next();
		}
	}

	/** 내 정보(닉네임, 이메일, 알림 여부) 수정 */
	public void update(int id, String nickname, String email, boolean notifyOnOpen) throws SQLException {
		String sql = "UPDATE users SET nickname = ?, email = ?, notify_on_open = ? WHERE id = ?";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, nickname);
			ps.setString(2, email);
			ps.setBoolean(3, notifyOnOpen);
			ps.setInt(4, id);
			ps.executeUpdate();
		}
	}

	/** 비밀번호는 SHA-256 해시(16진수)로만 저장한다. */
	public static String hash(String password) {
		try {
			byte[] digest = MessageDigest.getInstance("SHA-256").digest(password.getBytes(StandardCharsets.UTF_8));
			StringBuilder sb = new StringBuilder();
			for (byte b : digest)
				sb.append(String.format("%02x", b));
			return sb.toString();
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException(e);
		}
	}

	/** 조건 하나로 회원 한 명 조회 */
	private User find(String sql, String value) throws SQLException {
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setString(1, value);
			ResultSet rs = ps.executeQuery();
			if (!rs.next())
				return null;
			User u = new User();
			u.setId(rs.getInt("id"));
			u.setLoginId(rs.getString("login_id"));
			u.setPasswordHash(rs.getString("password_hash"));
			u.setNickname(rs.getString("nickname"));
			u.setEmail(rs.getString("email"));
			u.setNotifyOnOpen(rs.getBoolean("notify_on_open"));
			u.setCreatedAt(rs.getTimestamp("created_at"));
			return u;
		}
	}
}
