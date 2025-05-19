package servlets;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import utils.DBConnection;

@WebServlet("/PaySanctionServlet")
@MultipartConfig(
    maxFileSize = 10_000_000, // 10MB
    location = "/tmp" // Dossier temporaire
)
public class PaySanctionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // 1. Vérification de la connexion
        Integer memberId = (Integer) session.getAttribute("memberId");
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 2. Récupération des paramètres du formulaire
        String sanctionIdStr = request.getParameter("sanction_id");
        String methodePaiement = request.getParameter("methode_paiement");
        String montantStr = request.getParameter("montant"); // Si vous voulez permettre la modification
        
        // 3. Validation des paramètres
        if (sanctionIdStr == null || sanctionIdStr.isEmpty()) {
            session.setAttribute("errorMessage", "ID de sanction manquant");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        int sanctionId;
        try {
            sanctionId = Integer.parseInt(sanctionIdStr);
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Format d'ID de sanction invalide");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 4. Gestion de l'upload de fichier
        String fileName = null;
        Part filePart = request.getPart("preuve");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            
            fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            filePart.write(uploadPath + File.separator + fileName);
        } else {
            session.setAttribute("errorMessage", "Une preuve de paiement est requise");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 5. Traitement en base de données
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // Vérification que la sanction existe et appartient bien au membre
            BigDecimal montantSanction = BigDecimal.ZERO;
            String checkSql = "SELECT montant FROM sanctions WHERE id = ? AND member_id = ? AND statut = 'PENDING'";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, sanctionId);
                checkPs.setInt(2, memberId);
                
                ResultSet rs = checkPs.executeQuery();
                if (!rs.next()) {
                    session.setAttribute("errorMessage", "Sanction non trouvée ou déjà payée");
                    response.sendRedirect("mesCaisses.jsp");
                    return;
                }
                montantSanction = rs.getBigDecimal("montant");
            }
            
            // Si vous voulez permettre de modifier le montant (optionnel)
            BigDecimal montantAPayer = montantSanction;
            if (montantStr != null && !montantStr.isEmpty()) {
                try {
                    montantAPayer = new BigDecimal(montantStr);
                    if (montantAPayer.compareTo(montantSanction) < 0) {
                        session.setAttribute("errorMessage", "Le montant payé ne peut pas être inférieur à la sanction");
                        response.sendRedirect("mesCaisses.jsp");
                        return;
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Format de montant invalide");
                    response.sendRedirect("mesCaisses.jsp");
                    return;
                }
            }
            
            // Insertion du paiement
            String insertSql = "INSERT INTO paiements_sanctions (sanction_id, member_id, montant, "
                             + "date_paiement, methode_paiement, preuve_paiement, statut) "
                             + "VALUES (?, ?, ?, NOW(), ?, ?, 'COMPLETED')";
            
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, sanctionId);
                ps.setInt(2, memberId);
                ps.setBigDecimal(3, montantAPayer);
                ps.setString(4, methodePaiement);
                ps.setString(5, fileName);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    // Mise à jour du statut de la sanction
                    String updateSql = "UPDATE sanctions SET statut = 'PAID' WHERE id = ?";
                    try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                        updatePs.setInt(1, sanctionId);
                        updatePs.executeUpdate();
                    }
                    
                    conn.commit();
                    session.setAttribute("successMessage", "Paiement de la sanction enregistré avec succès");
                } else {
                    conn.rollback();
                    session.setAttribute("errorMessage", "Erreur lors de l'enregistrement du paiement");
                }
            }
            
            response.sendRedirect("mesCaisses.jsp");
            
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
            response.sendRedirect("error.jsp");
            e.printStackTrace();
        }
    }
}