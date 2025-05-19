package models;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.List;

public class Message {
    private int id;
    private int discussionId;
    private int senderId;
    private String senderType; // "member" ou "admin"
    private String content;
    private String attachmentUrl;
    private Timestamp sentAt;
    private Timestamp readAt;
    private String senderName;
    private String senderAvatar;

    public Message() {}

    public Message(int id, int discussionId, int senderId, String senderType, String content, 
                  String attachmentUrl, Timestamp sentAt, Timestamp readAt, 
                  String senderName, String senderAvatar) {
        this.id = id;
        this.discussionId = discussionId;
        this.senderId = senderId;
        this.senderType = senderType;
        this.content = content;
        this.attachmentUrl = attachmentUrl;
        this.sentAt = sentAt;
        this.readAt = readAt;
        this.senderName = senderName;
        this.senderAvatar = senderAvatar;
    }

    // Getters et Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public int getDiscussionId() { return discussionId; }
    public void setDiscussionId(int discussionId) { this.discussionId = discussionId; }
    
    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }
    
    public String getSenderType() { return senderType; }
    public void setSenderType(String senderType) { this.senderType = senderType; }
    
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getAttachmentUrl() { return attachmentUrl; }
    public void setAttachmentUrl(String attachmentUrl) { this.attachmentUrl = attachmentUrl; }
    
    public Timestamp getSentAt() { return sentAt; }
    public void setSentAt(Timestamp sentAt) { this.sentAt = sentAt; }
    
    public Timestamp getReadAt() { return readAt; }
    public void setReadAt(Timestamp readAt) { this.readAt = readAt; }
    
    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }
    
    public String getSenderAvatar() { return senderAvatar; }
    public void setSenderAvatar(String senderAvatar) { this.senderAvatar = senderAvatar; }

    public String getFormattedTime() {
        return new SimpleDateFormat("HH:mm").format(sentAt);
    }

	public boolean save() {
		// TODO Auto-generated method stub
		return false;
	}

	public static List<Message> getNewMessages(int discussionId2, int lastMessageId) {
		// TODO Auto-generated method stub
		return null;
	}

	
	}
