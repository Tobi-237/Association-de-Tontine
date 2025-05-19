package servlets;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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

@WebServlet("/ImageServlet")
@MultipartConfig(
    maxFileSize = 10_000_000, // 10MB
    location = "/tmp" // Dossier temporaire
)
public class ImageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // 1. Vérification de la connexion
        Integer memberId = (Integer) session.getAttribute("memberId");
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // 2. Préparation des variables
        String moisAnnee = getPartValue(request, "mois_annee");
        String methodePaiement = getPartValue(request, "methode_paiement");
        String reference = getPartValue(request, "reference");
        int selectedTontineId = 0;
        
        // 3. Gestion de l'upload de fichier
        String fileName = null;
        Part filePart = request.getPart("preuve_paiement");
        if (filePart != null && filePart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();
            
            fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            filePart.write(uploadPath + File.separator + fileName);
        }
        
        // 4. Récupération de tontine_id
        String selectedTontineIdParam = getPartValue(request, "tontine_id");
        if (selectedTontineIdParam != null && !selectedTontineIdParam.isEmpty()) {
            selectedTontineId = Integer.parseInt(selectedTontineIdParam);
        }
        
        // 5. Connexion à la base de données et traitement
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            
            // Vérification si le mois a déjà été payé
            String checkSql = "SELECT 1 FROM paiements WHERE member_id = ? AND tontine_id = ? AND mois_annee = ? AND type_paiement = 'COTISATION'";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, memberId);
                checkPs.setInt(2, selectedTontineId);
                checkPs.setString(3, moisAnnee);
                
                if (checkPs.executeQuery().next()) {
                    session.setAttribute("errorMessage", "Vous avez déjà payé la cotisation pour " + moisAnnee);
                    response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                    return;
                }
            }
            
            // Récupération du montant mensuel
            BigDecimal montantMensuel = BigDecimal.ZERO;
            String montantSql = "SELECT montant_mensuel FROM tontines WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(montantSql)) {
                ps.setInt(1, selectedTontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        montantMensuel = rs.getBigDecimal("montant_mensuel");
                    }
                }
            }
            
            // Vérification du fond de caisse
            BigDecimal fondCaisse = BigDecimal.ZERO;
            String fondSql = "SELECT montant_souscription FROM tontine_adherents1 WHERE member_id = ? AND tontine_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(fondSql)) {
                ps.setInt(1, memberId);
                ps.setInt(2, selectedTontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        fondCaisse = rs.getBigDecimal("montant_souscription");
                    }
                }
            }
            
            BigDecimal totalPaiements = BigDecimal.ZERO;
            String totalSql = "SELECT COALESCE(SUM(montant), 0) as total FROM paiements WHERE member_id = ? AND tontine_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(totalSql)) {
                ps.setInt(1, memberId);
                ps.setInt(2, selectedTontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        totalPaiements = rs.getBigDecimal("total");
                    }
                }
            }
            
            BigDecimal nouveauTotal = totalPaiements.add(montantMensuel);
            if (nouveauTotal.compareTo(fondCaisse) > 0) {
                session.setAttribute("errorMessage", "Paiement refusé : Le montant dépasse votre fond de caisse");
                response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                return;
            }
            
            // Insertion dans la base de données
            String insertSql = "INSERT INTO paiements (member_id, tontine_id, montant, date_paiement, "
                            + "type_paiement, statut, mois_annee, methode_paiement, reference, preuve_paiement) "
                            + "VALUES (?, ?, ?, NOW(), 'COTISATION', 'COMPLETED', ?, ?, ?, ?)";
            
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, memberId);
                ps.setInt(2, selectedTontineId);
                ps.setBigDecimal(3, montantMensuel);
                ps.setString(4, moisAnnee);
                
                // Conversion pour LONGBLOB
                if (methodePaiement != null) {
                    ps.setBytes(5, methodePaiement.getBytes(StandardCharsets.UTF_8));
                } else {
                    ps.setNull(5, Types.BLOB);
                }
                
                ps.setString(6, reference);
                ps.setString(7, fileName);
                
                int rows = ps.executeUpdate();
                if (rows > 0) {
                    conn.commit();
                    session.setAttribute("successMessage", "Paiement enregistré avec succès");
                } else {
                    conn.rollback();
                    session.setAttribute("errorMessage", "Erreur lors de l'enregistrement");
                }
            }
            
            response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
            
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