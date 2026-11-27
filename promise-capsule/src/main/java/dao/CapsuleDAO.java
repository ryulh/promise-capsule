package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import dto.Capsule;
import util.DBConnection;

/** 캡슐 테이블 담당 DAO */
public class CapsuleDAO {

	private static final CapsuleDAO instance = new CapsuleDAO();

	public static CapsuleDAO getInstance() {
		return instance;
	}

	/** 보는 사람(?) 기준 값과 인원, 편지, 사진 수를 함께 읽는다. 앞의 ? 세 개는 모두 보는 사람 번호. */
	private static final String SELECT = "SELECT c.*, u.nickname AS owner_nickname, c.owner_id = ? AS is_owner,"
			+ " (SELECT COUNT(*) FROM capsule_members WHERE capsule_id = c.id) AS member_count,"
			+ " (SELECT COUNT(*) FROM letters WHERE capsule_id = c.id AND withdrawn_at IS NULL) AS letter_count,"
			+ " (SELECT COUNT(*) FROM photos p JOIN letters l ON l.id = p.letter_id WHERE l.capsule_id = c.id) AS photo_count,"
			+ " (SELECT COUNT(*) FROM capsule_members x WHERE x.capsule_id = c.id AND NOT EXISTS"
			+ "   (SELECT 1 FROM letters l WHERE l.capsule_id = c.id AND l.user_id = x.user_id)) AS not_written_count,"
			+ " EXISTS (SELECT 1 FROM letters l WHERE l.capsule_id = c.id AND l.user_id = ? AND l.withdrawn_at IS NULL) AS my_letter,"
			+ " m.first_opened_at AS my_first_opened_at"
			+ " FROM capsules c JOIN users u ON u.id = c.owner_id"
			+ " LEFT JOIN capsule_members m ON m.capsule_id = c.id AND m.user_id = ?";

	/** 새 캡슐 저장(초대 코드도 만든다). 새 캡슐 번호를 돌려준다. */
	public int insert(int ownerId, String title, String description, Timestamp openAt) throws SQLException {
		String sql = "INSERT INTO capsules (owner_id, title, description, open_at, invite_code, created_at)"
				+ " VALUES (?, ?, ?, ?, ?, NOW())";
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
			ps.setInt(1, ownerId);
			ps.setString(2, title);
			ps.setString(3, description);
			ps.setTimestamp(4, openAt);
			ps.setString(5, newInviteCode());
			ps.executeUpdate();
			ResultSet keys = ps.getGeneratedKeys();
			keys.next();
			return keys.getInt(1);
		}
	}

	/** 내가 참여한 캡슐만 찾는다. 참여자가 아니면 null(있는지조차 알리지 않음). */
	public Capsule find(int capsuleId, int userId) throws SQLException {
		List<Capsule> list = list(SELECT + " WHERE c.id = ? AND m.user_id IS NOT NULL", userId, capsuleId);
		return list.isEmpty() ? null : list.get(0);
	}

	/** 초대 링크로 찾는다(참여 전이라 보는 사람 번호는 0이어도 된다). */
	public Capsule findByInviteCode(String code, int userId) throws SQLException {
		try (Connection conn = DBConnection.getConnection();
				PreparedStatement ps = prepare(conn, SELECT + " WHERE c.invite_code = ?", userId)) {
			ps.setString(4, code);
			ResultSet rs = ps.executeQuery();
			return rs.next() ? map(rs) : null;
		}
	}

	/** 내 캡슐 목록(여는 날 순) */
	public List<Capsule> listByMember(int userId) throws SQLException {
		return list(SELECT + " WHERE m.user_id IS NOT NULL ORDER BY c.open_at, c.id", userId, 0);
	}

	/** 캡슐 정보(제목, 설명, 여는 일시) 수정 */
	public void update(int id, String title, String description, Timestamp openAt) throws SQLException {
		execute("UPDATE capsules SET title = ?, description = ?, open_at = ? WHERE id = ?", title, description,
				openAt, id);
	}

	/** 초대 링크를 새 코드로 바꾼다 */
	public void changeInviteCode(int id) throws SQLException {
		execute("UPDATE capsules SET invite_code = ? WHERE id = ?", newInviteCode(), id);
	}

	/** 봉인: 상태를 SEALED로 바꾸고 봉인 시각을 남긴다 */
	public void seal(int id) throws SQLException {
		execute("UPDATE capsules SET status = 'SEALED', sealed_at = NOW() WHERE id = ?", id);
	}

	/** 참여, 편지, 사진, 한마디는 외래 키 CASCADE로 함께 지워진다. */
	public void delete(int id) throws SQLException {
		execute("DELETE FROM capsules WHERE id = ?", id);
	}

	/** 초대 코드 8자: 헷갈리는 0, O, 1, I, L을 뺀 대문자, 숫자. 이미 있으면 다시 만든다. */
	private String newInviteCode() throws SQLException {
		String letters = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
		Random random = new Random();
		while (true) {
			String code = "";
			for (int i = 0; i < 8; i++)
				code += letters.charAt(random.nextInt(letters.length()));
			try (Connection conn = DBConnection.getConnection();
					PreparedStatement ps = conn.prepareStatement("SELECT 1 FROM capsules WHERE invite_code = ?")) {
				ps.setString(1, code);
				if (!ps.executeQuery().next())
					return code;
			}
		}
	}

	/** 여러 건 조회(캡슐 번호가 0보다 크면 네 번째 ?에 넣는다) */
	private List<Capsule> list(String sql, int userId, int capsuleId) throws SQLException {
		List<Capsule> list = new ArrayList<>();
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = prepare(conn, sql, userId)) {
			if (capsuleId > 0)
				ps.setInt(4, capsuleId);
			ResultSet rs = ps.executeQuery();
			while (rs.next())
				list.add(map(rs));
		}
		return list;
	}

	/** SELECT 앞의 ? 세 개에 보는 사람 번호를 넣는다 */
	private PreparedStatement prepare(Connection conn, String sql, int userId) throws SQLException {
		PreparedStatement ps = conn.prepareStatement(sql);
		ps.setInt(1, userId);
		ps.setInt(2, userId);
		ps.setInt(3, userId);
		return ps;
	}

	/** 값 목록을 차례로 ?에 넣고 UPDATE, DELETE 실행 */
	private void execute(String sql, Object... values) throws SQLException {
		try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
			for (int i = 0; i < values.length; i++)
				ps.setObject(i + 1, values[i]);
			ps.executeUpdate();
		}
	}

	/** 결과 한 줄을 Capsule 객체로 옮긴다 */
	private Capsule map(ResultSet rs) throws SQLException {
		Capsule c = new Capsule();
		c.setId(rs.getInt("id"));
		c.setOwnerId(rs.getInt("owner_id"));
		c.setTitle(rs.getString("title"));
		c.setDescription(rs.getString("description"));
		c.setOpenAt(rs.getTimestamp("open_at"));
		c.setStatus(rs.getString("status"));
		c.setInviteCode(rs.getString("invite_code"));
		c.setSealedAt(rs.getTimestamp("sealed_at"));
		c.setOwnerNickname(rs.getString("owner_nickname"));
		c.setOwner(rs.getBoolean("is_owner"));
		c.setMemberCount(rs.getInt("member_count"));
		c.setLetterCount(rs.getInt("letter_count"));
		c.setPhotoCount(rs.getInt("photo_count"));
		c.setNotWrittenCount(rs.getInt("not_written_count"));
		c.setMyLetterWritten(rs.getBoolean("my_letter"));
		c.setMyFirstOpenedAt(rs.getTimestamp("my_first_opened_at"));
		return c;
	}
}
