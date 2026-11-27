package dao;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import dto.Photo;
import util.DBConnection;

/** 사진 행에는 캡슐 번호가 없어 편지와 조인해 캡슐, 작성자를 채운다. */
public class PhotoDAO {

	private static final PhotoDAO instance = new PhotoDAO();

	public static PhotoDAO getInstance() {
		return instance;
	}

	private static final String SELECT = "SELECT p.*, l.capsule_id, l.user_id AS writer_id"
			+ " FROM photos p JOIN letters l ON l.id = p.letter_id";

	/** 사진 한 장 조회(없으면 null) */
	public Photo find(int id) throws SQLException {
		List<Photo> list = list(SELECT + " WHERE p.id = ?", id);
		return list.isEmpty() ? null : list.get(0);
	}

	/** 편지의 사진 목록(보여 줄 순서) */
	public List<Photo> listByLetter(int letterId) throws SQLException {
		return list(SELECT + " WHERE p.letter_id = ? ORDER BY p.sort_order", letterId);
	}

	/** 사진 정보 저장 */
	public void insert(Photo p) throws SQLException {
		String sql = "INSERT INTO photos (letter_id, stored_name, original_name, mime_type, size_bytes, sort_order, created_at)"
				+ " VALUES (?, ?, ?, ?, ?, ?, NOW())";
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, p.getLetterId());
			ps.setString(2, p.getStoredName());
			ps.setString(3, p.getOriginalName());
			ps.setString(4, p.getMimeType());
			ps.setInt(5, p.getSizeBytes());
			ps.setInt(6, p.getSortOrder());
			ps.executeUpdate();
		}
	}

	/** 행과 파일을 함께 지운다. */
	public void delete(Photo p) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement("DELETE FROM photos WHERE id = ?")) {
			ps.setInt(1, p.getId());
			ps.executeUpdate();
		}
		fileOf(p).delete();
	}

	/** 편지의 사진 행과 파일을 모두 지운다. */
	public void deleteByLetter(int letterId) throws SQLException {
		for (Photo p : listByLetter(letterId))
			delete(p);
	}

	/** 사진 파일 위치: {upload.dir}/{캡슐 번호}/{저장 이름} (웹 루트 밖) */
	public static File fileOf(Photo p) {
		return new File(DBConnection.config.getProperty("upload.dir") + "/" + p.getCapsuleId(), p.getStoredName());
	}

	/** 번호 하나로 사진 목록 조회 */
	private List<Photo> list(String sql, int key) throws SQLException {
		List<Photo> list = new ArrayList<>();
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			ps.setInt(1, key);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Photo p = new Photo();
				p.setId(rs.getInt("id"));
				p.setLetterId(rs.getInt("letter_id"));
				p.setStoredName(rs.getString("stored_name"));
				p.setOriginalName(rs.getString("original_name"));
				p.setMimeType(rs.getString("mime_type"));
				p.setSizeBytes(rs.getInt("size_bytes"));
				p.setSortOrder(rs.getInt("sort_order"));
				p.setCapsuleId(rs.getInt("capsule_id"));
				p.setWriterId(rs.getInt("writer_id"));
				list.add(p);
			}
		}
		return list;
	}
}
