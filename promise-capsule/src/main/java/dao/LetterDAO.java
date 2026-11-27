package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import dto.Letter;
import util.DBConnection;

/** 편지 테이블 담당 DAO */
public class LetterDAO {

	private static final LetterDAO instance = new LetterDAO();

	public static LetterDAO getInstance() {
		return instance;
	}

	/** 이 캡슐에 쓴 내 편지(없으면 null) */
	public Letter find(int capsuleId, int userId) throws SQLException {
		String sql = "SELECT l.*, u.nickname FROM letters l JOIN users u ON u.id = l.user_id"
				+ " WHERE l.capsule_id = ? AND l.user_id = ?";
		List<Letter> list = list(sql, capsuleId, userId);
		return list.isEmpty() ? null : list.get(0);
	}

	/** 열린 캡슐의 편지 카드: 내 편지 먼저, 나머지는 참여 순. 사진도 함께 채운다. */
	public List<Letter> listByCapsule(int capsuleId, int userId) throws SQLException {
		String sql = "SELECT l.*, u.nickname FROM letters l JOIN users u ON u.id = l.user_id"
				+ " JOIN capsule_members m ON m.capsule_id = l.capsule_id AND m.user_id = l.user_id"
				+ " WHERE l.capsule_id = ? ORDER BY l.user_id = ? DESC, m.joined_at, m.user_id";
		List<Letter> letters = list(sql, capsuleId, userId);
		for (Letter l : letters)
			l.setPhotos(PhotoDAO.getInstance().listByLetter(l.getId()));
		return letters;
	}

	/** 새 편지 저장. 새 편지 번호를 돌려준다. */
	public int insert(int capsuleId, int userId, String body) throws SQLException {
		String sql = "INSERT INTO letters (capsule_id, user_id, body, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setInt(1, capsuleId);
			ps.setInt(2, userId);
			ps.setString(3, body);
			ps.executeUpdate();
			ResultSet keys = ps.getGeneratedKeys();
			keys.next();
			return keys.getInt(1);
		}
	}

	/** 편지 본문 수정 */
	public void updateBody(int id, String body) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("UPDATE letters SET body = ?, updated_at = NOW() WHERE id = ?")) {
			ps.setString(1, body);
			ps.setInt(2, id);
			ps.executeUpdate();
		}
	}

	/** 사진도 외래 키 CASCADE로 함께 지워진다. */
	public void delete(int id) throws SQLException {
		execute("DELETE FROM letters WHERE id = ?", id);
	}

	/** 철회: 행은 남기고 본문만 비운다(사진은 따로 지운다). */
	public void withdraw(int id) throws SQLException {
		execute("UPDATE letters SET body = NULL, withdrawn_at = NOW() WHERE id = ?", id);
	}

	/** 번호 하나로 UPDATE, DELETE 실행 */
	private void execute(String sql, int id) throws SQLException {
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, id);
			ps.executeUpdate();
		}
	}

	/** 캡슐 번호, 회원 번호로 편지 목록 조회 */
	private List<Letter> list(String sql, int capsuleId, int userId) throws SQLException {
		List<Letter> list = new ArrayList<>();
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, capsuleId);
			ps.setInt(2, userId);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Letter l = new Letter();
				l.setId(rs.getInt("id"));
				l.setCapsuleId(rs.getInt("capsule_id"));
				l.setUserId(rs.getInt("user_id"));
				l.setNickname(rs.getString("nickname"));
				l.setBody(rs.getString("body"));
				l.setCreatedAt(rs.getTimestamp("created_at"));
				l.setUpdatedAt(rs.getTimestamp("updated_at"));
				l.setWithdrawnAt(rs.getTimestamp("withdrawn_at"));
				list.add(l);
			}
		}
		return list;
	}
}
