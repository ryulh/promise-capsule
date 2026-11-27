package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.Comment;
import util.DBConnection;

/** 한마디 테이블 담당 DAO */
public class CommentDAO {

	private static final CommentDAO instance = new CommentDAO();

	public static CommentDAO getInstance() {
		return instance;
	}

	private static final String SELECT = "SELECT c.*, u.nickname FROM comments c JOIN users u ON u.id = c.user_id";

	/** 한마디 저장 */
	public void insert(int capsuleId, int userId, String body) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(
						"INSERT INTO comments (capsule_id, user_id, body, created_at) VALUES (?, ?, ?, NOW())")) {
			ps.setInt(1, capsuleId);
			ps.setInt(2, userId);
			ps.setString(3, body);
			ps.executeUpdate();
		}
	}

	/** 한마디 한 건 조회(없으면 null) */
	public Comment find(int id) throws SQLException {
		List<Comment> list = list(SELECT + " WHERE c.id = ?", id);
		return list.isEmpty() ? null : list.get(0);
	}

	/** 캡슐의 한마디 목록(쓴 순서) */
	public List<Comment> listByCapsule(int capsuleId) throws SQLException {
		return list(SELECT + " WHERE c.capsule_id = ? ORDER BY c.created_at, c.id", capsuleId);
	}

	/** 한마디 고치기(고친 시각을 남긴다) */
	public void update(int id, String body) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("UPDATE comments SET body = ?, edited_at = NOW() WHERE id = ?")) {
			ps.setString(1, body);
			ps.setInt(2, id);
			ps.executeUpdate();
		}
	}

	/** 한마디 지우기 */
	public void delete(int id) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("DELETE FROM comments WHERE id = ?")) {
			ps.setInt(1, id);
			ps.executeUpdate();
		}
	}

	/** 번호 하나로 한마디 목록 조회 */
	private List<Comment> list(String sql, int key) throws SQLException {
		List<Comment> list = new ArrayList<>();
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, key);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Comment c = new Comment();
				c.setId(rs.getInt("id"));
				c.setCapsuleId(rs.getInt("capsule_id"));
				c.setUserId(rs.getInt("user_id"));
				c.setNickname(rs.getString("nickname"));
				c.setBody(rs.getString("body"));
				c.setCreatedAt(rs.getTimestamp("created_at"));
				c.setEditedAt(rs.getTimestamp("edited_at"));
				list.add(c);
			}
		}
		return list;
	}
}
