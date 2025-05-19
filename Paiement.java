package servlets;

import java.security.Timestamp;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class Paiement {
    private int id;
    private int memberId;
    private double montant;
    private String typePaiement;
    private String datePaiementFormatted;
    private String statut;

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

    public double getMontant() {
        return montant;
    }

    public void setMontant(double montant) {
        this.montant = montant;
    }

    public String getTypePaiement() {
        return typePaiement;
    }

    public void setTypePaiement(String typePaiement) {
        this.typePaiement = typePaiement;
    }

    public String getDatePaiementFormatted() {
        return datePaiementFormatted;
    }

    public void setDatePaiementFormatted(String datePaiementFormatted) {
        this.datePaiementFormatted = datePaiementFormatted;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    // Méthode pour formater le montant
    public String getMontantFormatted() {
        return String.format("%,.2f", montant);
    }

    // Méthode statique pour récupérer les paiements d'un membre
    public static List<Paiement> getByMemberId(Connection conn, int memberId) throws SQLException {
        List<Paiement> paiements = new ArrayList<>();
        String query = "SELECT id, montant, type_paiement, date_paiement, statut FROM paiements WHERE member_id = ? ORDER BY date_paiement DESC LIMIT 5";
        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setInt(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                Paiement paiement = new Paiement();
                paiement.setId(rs.getInt("id"));
                paiement.setMemberId(memberId);
                paiement.setMontant(rs.getDouble("montant"));
                paiement.setTypePaiement(rs.getString("type_paiement"));
                
                java.sql.Timestamp ts = rs.getTimestamp("date_paiement");
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                paiement.setDatePaiementFormatted(sdf.format(ts));
                
                paiement.setStatut(rs.getString("statut"));
                
                paiements.add(paiement);
            }
        }
        return paiements;
    }
}