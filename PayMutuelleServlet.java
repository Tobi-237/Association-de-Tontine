package servlets;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.stream.Collectors;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import utils.DBConnection;

@WebServlet("/PayMutuelleServlet")
@MultipartConfig(
    maxFileSize = 10_000_000, // 10MB
    location = "/tmp" // Dossier temporaire
)
public class PayMutuelleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // 1. Vérification de la connexion
        Integer memberId = (Integer) session.getAttribute("memberId");
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 2. Récupération des paramètres
        String montantStr = getPartValue(request, "montant");
        String moisStr = getPartValue(request, "mois");
        String anneeStr = getPartValue(request, "annee");
        String methodePaiement = getPartValue(request, "methode_paiement");
        //String preuve = getPartValue(request, ("preuve");
        
        String fileName = null;
        Part filePart = request.getPart("preuve");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            
            fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            filePart.write(uploadPath + File.separator + fileName);
        }
        
        // 3. Validation des données
        if (montantStr == null || moisStr == null || anneeStr == null || methodePaiement == null || filePart == null) {
            session.setAttribute("errorMessage", "Données de paiement incomplètes");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        BigDecimal montant;
        int mois, annee;
        try {
            montant = new BigDecimal(montantStr);
            mois = Integer.parseInt(moisStr);
            annee = Integer.parseInt(anneeStr);
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Format de données invalide");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 5. Traitement en base de données
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // Vérification si le mois a déjà été payé
            String checkSql = "SELECT 1 FROM versements WHERE member_id = ? AND caisse_id = 1 " +
                            "AND MONTH(date_versement) = ? AND YEAR(date_versement) = ? AND statut = 'VALIDATED'";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, memberId);
                checkPs.setInt(2, mois);
                checkPs.setInt(3, annee);
                
                if (checkPs.executeQuery().next()) {
                    session.setAttribute("errorMessage", "Vous avez déjà payé la mutuelle pour " + mois + "/" + annee);
                    response.sendRedirect("mesCaisses.jsp");
                    return;
                }
            }
            
            // Insertion du paiement
            String insertSql = "INSERT INTO versements (member_id, caisse_id, montant, date_versement, " +
                             "methode_paiement, preuve, statut, mois, annee) " +
                             "VALUES (?, 1, ?, NOW(), ?, ?, 'VALIDATED', ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setBigDecimal(2, montant);
                ps.setString(3, methodePaiement);
                ps.setString(4, fileName);
                ps.setInt(5, mois);
                ps.setInt(6, annee);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    session.setAttribute("successMessage", "Paiement de la mutuelle enregistré avec succès pour " + 
                                        mois + "/" + annee);
                } else {
                    conn.rollback();
                    session.setAttribute("errorMessage", "Erreur lors de l'enregistrement du paiement");
                }
            }
            
            response.sendRedirect("mesCaisses.jsp");
            
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
            response.sendRedirect("erreur.jsp");
            e.printStackTrace();
        }
    }
    
    private String getPartValue(HttpServletRequest request, String partName) throws IOException, ServletException {
        Part part = request.getPart(partName);
        if (part != null) {
            return new BufferedReader(new InputStreamReader(part.getInputStream()))
                     .lines()
                     .collect(Collectors.joining("\n"));
        }
        return null;
    }
}