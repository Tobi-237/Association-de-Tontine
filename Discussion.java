package models;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import utils.DBConnection;
public class Discussion {
    private int id;
    private String title;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private boolean isGroup;
    private int createdBy;
    private String avatar;
    private String lastMessageTime;
    private int unreadCount;
    private int participantsCount;
    
    

    public Discussion(int id, String title, Timestamp createdAt, Timestamp updatedAt, boolean isGroup, int createdBy,
			String avatar, String lastMessageTime, int unreadCount, int participantsCount) {
		super();
		this.id = id;
		this.title = title;
		this.createdAt = createdAt;
		this.updatedAt = updatedAt;
		this.isGroup = isGroup;
		this.createdBy = createdBy;
		this.avatar = avatar;
		this.lastMessageTime = lastMessageTime;
		this.unreadCount = unreadCount;
		this.participantsCount = participantsCount;
	}

	// Getters et Setters

    public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public Timestamp getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}

	public Timestamp getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Timestamp updatedAt) {
		this.updatedAt = updatedAt;
	}

	public boolean isGroup() {
		return isGroup;
	}

	public void setGroup(boolean isGroup) {
		this.isGroup = isGroup;
	}

	public int getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(int createdBy) {
		this.createdBy = createdBy;
	}

	public String getAvatar() {
		return avatar;
	}

	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}

	public String getLastMessageTime() {
		return lastMessageTime;
	}

	public void setLastMessageTime(String lastMessageTime) {
		this.lastMessageTime = lastMessageTime;
	}

	public int getUnreadCount() {
		return unreadCount;
	}

	public void setUnreadCount(int unreadCount) {
		this.unreadCount = unreadCount;
	}

	public int getParticipantsCount() {
		return participantsCount;
	}

	public void setParticipantsCount(int participantsCount) {
		this.participantsCount = participantsCount;
	}

	public static List<Discussion> getMemberDiscussions(int memberId) {
        List<Discussion> discussions = new ArrayList<>();
        // Implémentation de la requête SQL pour récupérer les discussions du membre
        return discussions;
    }
	  public static List<Discussion> getMemberArchivedDiscussions(int memberId) {
	        // Logique ici : récupérer les discussions archivées pour ce membre
	        return new ArrayList<>();
	    }
	   public static List<Discussion> getMemberActiveDiscussions(int memberId) {
	        // Logique ici pour récupérer les discussions actives
	        return new ArrayList<>();
	        }

    public static List<Discussion> getAdminActiveDiscussions(int adminId) {
        List<Discussion> discussions = new ArrayList<>();
        // Implémentation de la requête SQL pour récupérer les discussions actives de l'admin
        return discussions;
    }

    public static List<Discussion> getAdminArchivedDiscussions(int adminId) {
        List<Discussion> discussions = new ArrayList<>();
        // Implémentation de la requête SQL pour récupérer les discussions archivées de l'admin
        return discussions;
    }

    public static Discussion getById(int id) {
        String query = "SELECT * FROM discussions WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Discussion(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getTimestamp("created_at"),
                        rs.getTimestamp("updated_at"),
                        rs.getBoolean("is_group"),
                        rs.getInt("created_by")
                        // Ajoutez d'autres paramètres si nécessaire
, query, query, id, id
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null; // ou lancez une exception si préféré
    }

    public static int getUnreadCount(int memberId) {
        // Implémentation pour compter les messages non lus
        return 0;
    }

    public static int getAdminUnreadCount(int adminId) {
        // Implémentation pour compter les messages non lus pour l'admin
        return 0;
    }
    // Méthode statique pour récupérer le nombre de discussions non lues d'un membre
    public static int getMemberUnreadCount(int memberId) {
        int count = 0;

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            // Connexion à ta base de données (à adapter selon ton contexte)
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ta_base", "utilisateur", "motdepasse");

            String sql = "SELECT COUNT(*) FROM discussions WHERE membre_id = ? AND statut = 'non_lue'";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, memberId);

            rs = stmt.executeQuery();
            if (rs.next()) {
                count = rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            // Libérer les ressources
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        return count;
    }
    public String getLastMessagePreview() {
        String preview = "(Aucun message)";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/ta_base", "utilisateur", "motdepasse");

            String sql = "SELECT contenu FROM messages WHERE discussion_id = ? ORDER BY date_envoi DESC LIMIT 1";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, this.id);

            rs = stmt.executeQuery();
            if (rs.next()) {
                String message = rs.getString("contenu");
                preview = message.length() > 50 ? message.substring(0, 50) + "..." : message;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }

        return preview;
    }
}

