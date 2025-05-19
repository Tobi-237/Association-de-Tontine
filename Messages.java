package models;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import utils.DBConnection;

public class Messages {
    public static List<Message> getByDiscussion(int discussionId) {
        List<Message> messages = new ArrayList<>();
        String query = "SELECT m.*, " +
                      "CASE WHEN m.sender_type = 'admin' THEN u.nom ELSE m2.nom END as sender_name, " +
                      "CASE WHEN m.sender_type = 'admin' THEN u.avatar ELSE m2.avatar END as sender_avatar " +
                      "FROM messages m " +
                      "LEFT JOIN users u ON m.sender_id = u.id AND m.sender_type = 'admin' " +
                      "LEFT JOIN members m2 ON m.sender_id = m2.id AND m.sender_type = 'member' " +
                      "WHERE m.discussion_id = ? " +
                      "ORDER BY m.sent_at ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, discussionId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Message message = new Message();
                    message.setId(rs.getInt("id"));
                    message.setDiscussionId(rs.getInt("discussion_id"));
                    message.setSenderId(rs.getInt("sender_id"));
                    message.setSenderType(rs.getString("sender_type"));
                    message.setContent(rs.getString("content"));
                    message.setAttachmentUrl(rs.getString("attachment_url"));
                    message.setSentAt(rs.getTimestamp("sent_at"));
                    message.setReadAt(rs.getTimestamp("read_at"));
                    message.setSenderName(rs.getString("sender_name")); 
                    message.setSenderAvatar(rs.getString("sender_avatar"));
                    
                    messages.add(message);
                } 
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return messages;
    }
}