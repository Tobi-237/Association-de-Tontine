package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import utils.DBConnection;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;

@WebServlet("/ImageServlet2")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 100   // 100 MB
)
public class ImageServlet2 extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Montant fixe de la souscription
    private static final BigDecimal SOUSCRIPTION_AMOUNT = new BigDecimal("10000");

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        
        // 1. Vérification de l'authentification
        Integer memberId = (Integer) session.getAttribute("memberId");
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 2. Récupération des paramètres du formulaire
        String paymentMethod = request.getParameter("payment_method");
        String reference = request.getParameter("reference");
        BigDecimal montant = SOUSCRIPTION_AMOUNT;
        
        try {
            String montantParam = request.getParameter("montant");
            if (montantParam != null && !montantParam.isEmpty()) {
                montant = new BigDecimal(montantParam);
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Montant invalide");
            response.sendRedirect("souscription.jsp");
            return;
        }
        
        // 3. Validation du montant minimum
        if (montant.compareTo(SOUSCRIPTION_AMOUNT) < 0) {
            session.setAttribute("errorMessage", "Le montant doit être d'au moins " + SOUSCRIPTION_AMOUNT + " FCFA");
            response.sendRedirect("souscription.jsp");
            return;
        }
        
        // 4. Gestion de l'upload de fichier
        String fileName = null;
        Part filePart = request.getPart("preuve");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }
            
            fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            filePart.write(uploadPath + File.separator + fileName);
        }
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Démarrer une transaction
            
            // 5. Vérification que le membre existe
            String checkMemberSql = "SELECT id FROM members WHERE id = ?";
            try (PreparedStatement checkMemberPs = conn.prepareStatement(checkMemberSql)) {
                checkMemberPs.setInt(1, memberId);
                ResultSet memberRs = checkMemberPs.executeQuery();
                
                if (!memberRs.next()) {
                    session.setAttribute("errorMessage", "Erreur : Votre compte membre n'existe pas.");
                    response.sendRedirect("souscription.jsp");
                    return;
                }
            }
            
            // 6. Enregistrement du paiement
            String insertPaymentSql = "INSERT INTO paiements (member_id, montant, type_paiement, date_paiement, methode_paiement, reference, statut) " +
                                    "VALUES (?, ?, 'SOUSCRIPTION', NOW(), ?, ?, 'COMPLETED')";
            int paymentId = 0;
            
            try (PreparedStatement insertPaymentPs = conn.prepareStatement(insertPaymentSql, Statement.RETURN_GENERATED_KEYS)) {
                insertPaymentPs.setInt(1, memberId);
                insertPaymentPs.setBigDecimal(2, montant);
                insertPaymentPs.setString(3, paymentMethod);
                insertPaymentPs.setString(4, reference);
                
                int affectedRows = insertPaymentPs.executeUpdate();
                
                if (affectedRows == 0) {
                    throw new SQLException("Échec de l'insertion du paiement, aucune ligne affectée.");
                }
                
                try (ResultSet generatedKeys = insertPaymentPs.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        paymentId = generatedKeys.getInt(1);
                    }
                }
            }
            
            // 7. Enregistrement de la souscription dans la table mutuelle
            String insertMutuelleSql = "INSERT INTO mutuelle (member_id, montant, payment_id, statut, preuve_souscription) " +
                                     "VALUES (?, ?, ?, 'ACTIVE', ?)";
            
            try (PreparedStatement insertMutuellePs = conn.prepareStatement(insertMutuelleSql)) {
                insertMutuellePs.setInt(1, memberId);
                insertMutuellePs.setBigDecimal(2, montant);
                insertMutuellePs.setInt(3, paymentId);
                
                if (fileName != null) {
                    insertMutuellePs.setString(4, fileName);
                } else {
                    insertMutuellePs.setNull(4, Types.VARCHAR);
                }
                
                insertMutuellePs.executeUpdate();
            }
            
            // 8. Envoi d'une notification à l'administrateur
            String messageSql = "INSERT INTO messages (sender_id, receiver_id, subject, content, related_payment_id) " +
                             "VALUES (?, 1, 'Nouveau paiement de souscription', ?, ?)";
            try (PreparedStatement messagePs = conn.prepareStatement(messageSql)) {
                messagePs.setInt(1, memberId);
                messagePs.setString(2, "Le membre ID " + memberId + " a effectué un paiement de souscription de " + 
                                      montant + " FCFA. Méthode: " + paymentMethod + ", Référence: " + reference);
                messagePs.setInt(3, paymentId);
                messagePs.executeUpdate();
            }
            
            conn.commit(); // Valider la transaction
            
            session.setAttribute("successMessage", "Paiement de souscription effectué avec succès! Vous êtes maintenant membre actif.");
            response.sendRedirect("souscription.jsp");
            
        } catch(Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Annuler la transaction en cas d'erreur
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            session.setAttribute("errorMessage", "Erreur lors du paiement: " + e.getMessage());
            response.sendRedirect("souscription.jsp");
        } finally {
            if (conn != null) {
                try { 
                    conn.close(); 
                } catch(SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
