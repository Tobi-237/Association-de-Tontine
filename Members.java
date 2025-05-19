package servlets;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Members {
    private int id;
    private Integer memberId;
    private String nom;
    private String prenom;
    private String email;
    private String inscription;
    private int fondCaisse;
    private String localisation;
    private String statut;
    private String phone; // Ajouté pour correspondre à votre JSP

    // Constructeurs
    public Members() {}

    public Members(int id, String nom, String prenom, String email) {
        this.id = id;
        this.nom = nom;
        this.prenom = prenom;
        this.email = email;
    }

    // Getters et Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getMemberId() {
        return memberId;
    }

    public void setMemberId(Integer memberId) {
        this.memberId = memberId;
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

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getInscription() {
        return inscription;
    }

    public void setInscription(String inscription) {
        this.inscription = inscription;
    }

    public int getFondCaisse() {
        return fondCaisse;
    }

    public void setFondCaisse(int fondCaisse) {
        this.fondCaisse = fondCaisse;
    }

    public String getLocalisation() {
        return localisation;
    }

    public void setLocalisation(String localisation) {
        this.localisation = localisation;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }
   

    // Méthodes supplémentaires
    public String getFullName() {
        return this.nom + " " + this.prenom;
    }

    public String getJoinDate() {
        return this.inscription;
    }
    public void setJoinDate(String joinDate) {
        this.inscription = joinDate;
    }

    // Méthode statique pour récupérer un membre par son ID
    public static Members getById(Connection conn, int memberId) throws SQLException {
        String query = "SELECT * FROM members WHERE id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                Members member = new Members();
                member.setId(rs.getInt("id"));
                member.setNom(rs.getString("nom"));
                member.setPrenom(rs.getString("prenom"));
                member.setEmail(rs.getString("email"));
                member.setInscription(rs.getString("inscription"));
                member.setFondCaisse(rs.getInt("fond_caisse"));
                member.setLocalisation(rs.getString("localisation"));
                member.setStatut(rs.getString("statut"));
                return member;
            }
        }
        return null;
    }
}