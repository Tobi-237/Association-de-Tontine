package models;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import utils.DBConnection;

public class User {
    private int id;
    private String nom;
    private String prenom;
    private String email;
    private String password;
    private Timestamp createdAt;
    private String role;
    private boolean isAdmin;
    private String avatar;
	private String firstName;
	private String lastName;

    // Constructeurs
    public User() {}

    public User(int id, String nom, String prenom, String email, String password, 
               Timestamp createdAt, String role, boolean isAdmin, String avatar) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
        this.password = password;
        this.createdAt = createdAt;
        this.role = role;
        this.isAdmin = isAdmin;
        this.avatar = avatar;
    }

    // Getters et Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getFullName() {
        return prenom + " " + nom;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public boolean isAdmin() {
        return isAdmin;
    }

    public void setAdmin(boolean isAdmin) {
        this.isAdmin = isAdmin;
    }

    public String getAvatar() {
        return avatar != null ? avatar : "https://via.placeholder.com/50";
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getFirstName() {
        return getFirstName();
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    // Même chose pour lastName
    public String getLastName() {
        return getFirstName();
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    // Méthodes de persistance
    public static User authenticate(String email, String password) {
        User user = null;
        String query = "SELECT * FROM users WHERE email = ? AND password = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setNom(rs.getString("nom"));
                    user.setPrenom(rs.getString("prenom"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setRole(rs.getString("role"));
                    user.setAdmin(rs.getBoolean("isAdmin"));
                    user.setAvatar(rs.getString("avatar"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user;
    }

    public static User getById(int id) {
        User user = null;
        String query = "SELECT * FROM users WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, id);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user = new User();
                    user.setId(rs.getInt("id"));
                    user.setNom(rs.getString("nom"));
                    user.setPrenom(rs.getString("prenom"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    user.setRole(rs.getString("role"));
                    user.setAdmin(rs.getBoolean("isAdmin"));
                    user.setAvatar(rs.getString("avatar"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user;
    }

    public boolean save() {
        String query;
        if (this.id == 0) {
            query = "INSERT INTO users (nom, prenom, email, password, role, isAdmin, avatar) VALUES (?, ?, ?, ?, ?, ?, ?)";
        } else {
            query = "UPDATE users SET nom = ?, prenom = ?, email = ?, password = ?, role = ?, isAdmin = ?, avatar = ? WHERE id = ?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, this.nom);
            stmt.setString(2, this.prenom);
            stmt.setString(3, this.email);
            stmt.setString(4, this.password);
            stmt.setString(5, this.role);
            stmt.setBoolean(6, this.isAdmin);
            stmt.setString(7, this.avatar);
            
            if (this.id != 0) {
                stmt.setInt(8, this.id);
            }
            
            int affectedRows = stmt.executeUpdate();
            
            if (this.id == 0 && affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        this.id = rs.getInt(1);
                    }
                }
            }
            
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public static List<User> getAllAdmins() {
        List<User> admins = new ArrayList<>();
        String query = "SELECT * FROM users WHERE isAdmin = true";
        
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            while (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setNom(rs.getString("nom"));
                user.setPrenom(rs.getString("prenom"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setCreatedAt(rs.getTimestamp("created_at"));
                user.setRole(rs.getString("role"));
                user.setAdmin(rs.getBoolean("isAdmin"));
                user.setAvatar(rs.getString("avatar"));
                
                admins.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return admins;
    }

    // Méthode pour vérifier si un email existe déjà
    public static boolean emailExists(String email) {
        String query = "SELECT COUNT(*) FROM users WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, email);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return false;
    }
}