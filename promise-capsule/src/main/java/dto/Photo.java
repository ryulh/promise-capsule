package dto;

/** 사진 한 장. 파일은 {upload.dir}/{capsuleId}/{storedName}. */
public class Photo {
	private int id;
	private int letterId;
	private String storedName;
	private String originalName;
	private String mimeType;
	private int sizeBytes;
	private int sortOrder;
	private int capsuleId;
	private int writerId;

	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public int getLetterId() {
		return letterId;
	}
	public void setLetterId(int letterId) {
		this.letterId = letterId;
	}
	public String getStoredName() {
		return storedName;
	}
	public void setStoredName(String storedName) {
		this.storedName = storedName;
	}
	public String getOriginalName() {
		return originalName;
	}
	public void setOriginalName(String originalName) {
		this.originalName = originalName;
	}
	public String getMimeType() {
		return mimeType;
	}
	public void setMimeType(String mimeType) {
		this.mimeType = mimeType;
	}
	public int getSizeBytes() {
		return sizeBytes;
	}
	public void setSizeBytes(int sizeBytes) {
		this.sizeBytes = sizeBytes;
	}
	public int getSortOrder() {
		return sortOrder;
	}
	public void setSortOrder(int sortOrder) {
		this.sortOrder = sortOrder;
	}
	public int getCapsuleId() {
		return capsuleId;
	}
	public void setCapsuleId(int capsuleId) {
		this.capsuleId = capsuleId;
	}
	public int getWriterId() {
		return writerId;
	}
	public void setWriterId(int writerId) {
		this.writerId = writerId;
	}
}
