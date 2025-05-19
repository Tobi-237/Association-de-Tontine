package servlets;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
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

@WebServlet("/AddVersementScolaireServlet")
@MultipartConfig(
    maxFileSize = 10_000_000, // 10MB
    location = "/tmp" // Dossier temporaire
)
public class AddVersementScolaireServlet extends HttpServlet {
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
        String dateVersementStr = getPartValue(request, "date_versement");
        String methodePaiement = getPartValue(request, "methode_paiement");
        
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
        if (montantStr == null || dateVersementStr == null || methodePaiement == null || filePart == null) {
            session.setAttribute("errorMessage", "Données de versement incomplètes");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        BigDecimal montant;
        LocalDate dateVersement;
        try {
            montant = new BigDecimal(montantStr);
            dateVersement = LocalDate.parse(dateVersementStr);
            
            // Validation du montant minimum
            if (montant.compareTo(new BigDecimal("1000")) < 0) {
                session.setAttribute("errorMessage", "Le montant minimum est de 1 000 FCFA");
                response.sendRedirect("mesCaisses.jsp");
                return;
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Format de données invalide");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 4. Traitement en base de données
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // Insertion du versement scolaire (caisse_id = 2 pour scolaire)
            String insertSql = "INSERT INTO versements (member_id, caisse_id, montant, date_versement, " +
                             "methode_paiement, preuve, statut) " +
                             "VALUES (?, 2, ?, ?, ?, ?, 'VALIDATED')";
            
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setBigDecimal(2, montant);
                ps.setDate(3, java.sql.Date.valueOf(dateVersement));
                ps.setString(4, methodePaiement);
                ps.setString(5, fileName);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    session.setAttribute("successMessage", "Versement scolaire enregistré avec succès");
                } else {
                    conn.rollback();
                    session.setAttribute("errorMessage", "Erreur lors de l'enregistrement du versement");
                }
            }
            
            response.sendRedirect("mesCaisses.jsp");
            
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
            response.sendRedirect("mesCaisses.jsp");
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
