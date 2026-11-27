package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.Member;
import util.DBConnection;

/** 캡슐 참여자 테이블 담당 DAO */
public class MemberDAO {

	private static final MemberDAO instance = new MemberDAO();

	public static MemberDAO getInstance() {
		return instance;
	}

	/** 캡슐에 참여시킨다 */
	public void insert(int capsuleId, int userId) throws SQLException {
		execute("INSERT INTO capsule_members (capsule_id, user_id, joined_at) VALUES (?, ?, NOW())", capsuleId,
				userId);
	}

	/** 이미 참여한 사람인지 */
	public boolean exists(int capsuleId, int userId) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn
						.prepareStatement("SELECT 1 FROM capsule_members WHERE capsule_id = ? AND user_id = ?")) {
			ps.setInt(1, capsuleId);
			ps.setInt(2, userId);
			return ps.executeQuery().next();
		}
	}

	/** 참여 순서대로, 각자의 편지 상태와 사진 수를 함께 읽는다. */
	public List<Member> listByCapsule(int capsuleId) throws SQLException {
		String sql = "SELECT m.capsule_id, m.user_id, u.nickname, l.id AS letter_id, l.withdrawn_at,"
				+ " (SELECT COUNT(*) FROM photos p WHERE p.letter_id = l.id) AS photo_count"
				+ " FROM capsule_members m JOIN users u ON u.id = m.user_id"
				+ " LEFT JOIN letters l ON l.capsule_id = m.capsule_id AND l.user_id = m.user_id"
				+ " WHERE m.capsule_id = ? ORDER BY m.joined_at, m.user_id";
		List<Member> list = new ArrayList<>();
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, capsuleId);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Member m = new Member();
				m.setCapsuleId(rs.getInt("capsule_id"));
				m.setUserId(rs.getInt("user_id"));
				m.setNickname(rs.getString("nickname"));
				m.setLetterId(rs.getInt("letter_id"));
				m.setWithdrawnAt(rs.getTimestamp("withdrawn_at"));
				m.setPhotoCount(rs.getInt("photo_count"));
				list.add(m);
			}
		}
		return list;
	}

	/** 편지, 사진도 외래 키 CASCADE로 함께 지워진다. */
	public void delete(int capsuleId, int userId) throws SQLException {
		execute("DELETE FROM capsule_members WHERE capsule_id = ? AND user_id = ?", capsuleId, userId);
	}

	/** 열린 캡슐을 처음 본 시각을 남긴다(이미 있으면 그대로) */
	public void markFirstOpened(int capsuleId, int userId) throws SQLException {
		execute("UPDATE capsule_members SET first_opened_at = NOW()"
				+ " WHERE capsule_id = ? AND user_id = ? AND first_opened_at IS NULL", capsuleId, userId);
	}

	/** 캡슐 번호, 회원 번호로 INSERT, UPDATE, DELETE 실행 */
	private void execute(String sql, int capsuleId, int userId) throws SQLException {
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, capsuleId);
			ps.setInt(2, userId);
			ps.executeUpdate();
		}
	}
}
