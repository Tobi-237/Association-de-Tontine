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

@WebServlet("/DeclareSinistreServlet")
@MultipartConfig(
    maxFileSize = 10_000_000, // 10MB
    location = "/tmp" // Dossier temporaire
)
public class DeclareSinistreServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // 1. Vérification de la connexion et du paiement mutuelle
        Integer memberId = (Integer) session.getAttribute("memberId");
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 2. Récupération des paramètres
        String typeSinistre = getPartValue(request, "type_sinistre");
        String dateSinistreStr = getPartValue(request, "date_sinistre");
        String description = getPartValue(request, "description");
        String montantStr = getPartValue(request, "montant_demande");
        
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
        if (typeSinistre == null || dateSinistreStr == null || description == null || filePart == null) {
            session.setAttribute("errorMessage", "Données de déclaration incomplètes");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        LocalDate dateSinistre;
        BigDecimal montant = null;
        try {
            dateSinistre = LocalDate.parse(dateSinistreStr);
            
            if (montantStr != null && !montantStr.isEmpty()) {
                montant = new BigDecimal(montantStr);
                // Validation du montant minimum
                if (montant.compareTo(BigDecimal.ZERO) < 0) {
                    session.setAttribute("errorMessage", "Le montant ne peut pas être négatif");
                    response.sendRedirect("mesCaisses.jsp");
                    return;
                }
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Format de données invalide");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 4. Vérification que le membre a payé sa mutuelle
        try (Connection conn = DBConnection.getConnection()) {
            String checkSql = "SELECT 1 FROM versements WHERE member_id = ? AND caisse_id = 1 " +
                             "AND statut = 'VALIDATED' AND MONTH(date_versement) = MONTH(CURRENT_DATE()) " +
                             "AND YEAR(date_versement) = YEAR(CURRENT_DATE())";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, memberId);
                if (!checkPs.executeQuery().next()) {
                    session.setAttribute("errorMessage", "Vous devez payer votre cotisation mutuelle avant de déclarer un sinistre");
                    response.sendRedirect("mesCaisses.jsp");
                    return;
                }
            }
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Erreur technique lors de la vérification");
            response.sendRedirect("mesCaisses.jsp");
            return;
        }
        
        // 5. Traitement en base de données
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            // Avant la partie insertion, ajoutez cette validation
            String[] typesAutorises = {"HOSPITALISATION", "DECES_MEMBRE", "DECES_CONJOINT", "DECES_PARENT", "DECES_ENFANT"};
            boolean typeValide = false;
            for (String type : typesAutorises) {
                if (type.equals(typeSinistre)) {
                    typeValide = true;
                    break;
                }
            }

            if (!typeValide) {
                session.setAttribute("errorMessage", "Type de sinistre non valide");
                response.sendRedirect("mesCaisses.jsp");
                return;
            }
            
         // Insertion du sinistre
            String insertSql = "INSERT INTO sinistres_mutuelle (member_id, type_sinistre, date_sinistre, " +
                             "description, montant_demande, preuve, statut, date_traitement) " +
                             "VALUES (?, ?, ?, ?, ?, ?, 'PENDING', NOW())";

            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setString(2, typeSinistre);
                ps.setDate(3, java.sql.Date.valueOf(dateSinistre));
                ps.setString(4, description);
                
                if (montant != null) {
                    ps.setBigDecimal(5, montant);
                } else {
                    ps.setNull(5, java.sql.Types.DECIMAL);
                }
                
                ps.setString(6, fileName);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    session.setAttribute("successMessage", "Déclaration de sinistre enregistrée avec succès. Elle sera traitée sous 48h.");
                } else {
                    conn.rollback();
                    session.setAttribute("errorMessage", "Erreur lors de l'enregistrement de la déclaration");
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