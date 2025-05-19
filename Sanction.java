package servlets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;

import java.util.List;


public class Sanction {
    private int id;
    private int memberId;
    private String typeSanction;
    private double montant;
    private String details;
    private String dateSanctionFormatted;
    private String statut;
    private String dateFinFormatted;

    // Getters et Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getMemberId() {
        return memberId;
    }

    public void setMemberId(int memberId) {
        this.memberId = memberId;
    }

    public String getTypeSanction() {
        return typeSanction;
    }

    public void setTypeSanction(String typeSanction) {
        this.typeSanction = typeSanction;
    }

    public double getMontant() {
        return montant;
    }

    public void setMontant(double montant) {
        this.montant = montant;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getDateSanctionFormatted() {
        return dateSanctionFormatted;
    }

    public void setDateSanctionFormatted(String dateSanctionFormatted) {
        this.dateSanctionFormatted = dateSanctionFormatted;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getDateFinFormatted() {
        return dateFinFormatted;
    }

    public void setDateFinFormatted(String dateFinFormatted) {
        this.dateFinFormatted = dateFinFormatted;
    }

    // Méthode pour formater le montant
    public String getMontantFormatted() {
        return String.format("%,.2f", montant);
    }

    // Vérifie si la sanction est active
    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.statut);
    }
  private String appliedBy;  // Nom de l'admin qui a appliqué la sanction
    
    // ... autres méthodes existantes ...

    // Getter et Setter pour appliedBy
    public String getAppliedBy() {
        return appliedBy;
    }

    public void setAppliedBy(String appliedBy) {
        this.appliedBy = appliedBy;
    }

    // Méthode statique pour récupérer les sanctions d'un membre
    public static List<Sanction> getByMemberId(Connection conn, int memberId) throws SQLException {
        List<Sanction> sanctions = new ArrayList<>();
        String query = "SELECT id, type_sanction, montant, details, date_sanction, statut, date_fin FROM sanctions WHERE member_id = ? ORDER BY date_sanction DESC";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Sanction sanction = new Sanction();
                sanction.setId(rs.getInt("id"));
                sanction.setMemberId(memberId);
                sanction.setTypeSanction(rs.getString("type_sanction"));
                sanction.setMontant(rs.getDouble("montant"));
                sanction.setDetails(rs.getString("details"));
                
                Timestamp ts = rs.getTimestamp("date_sanction");
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                sanction.setDateSanctionFormatted(sdf.format(ts));
                
                sanction.setStatut(rs.getString("statut"));
                
                if (rs.getTimestamp("date_fin") != null) {
                    ts = rs.getTimestamp("date_fin");
                    sanction.setDateFinFormatted(sdf.format(ts));
                }
                
                sanctions.add(sanction);
            }
        }
        return sanctions;
    }
}
