package servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import java.util.*;
import utils.DBConnection;

@WebServlet("/SinistreServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1 MB
    maxFileSize = 1024 * 1024 * 5,     // 5 MB
    maxRequestSize = 1024 * 1024 * 10  // 10 MB
)
public class SinistreServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer memberId = (Integer) session.getAttribute("memberId");
        
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("declarer".equals(action)) {
            try {
                // Récupération des paramètres du formulaire
                String typeSinistre = request.getParameter("typeSinistre");
                int assuranceId = Integer.parseInt(request.getParameter("assuranceId"));
                String dateSinistre = request.getParameter("dateSinistre");
                double montantIndemnisation = Double.parseDouble(request.getParameter("montantIndemnisation"));
                String description = request.getParameter("description");
                
                // Traitement des fichiers uploadés
                Collection<Part> fileParts = request.getParts().stream()
                    .filter(part -> "documents".equals(part.getName()) && part.getSize() > 0)
                    .toList();
                
                List<String> fileNames = new ArrayList<>();
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdir();
                }
                
                for (Part filePart : fileParts) {
                    String fileName = getFileName(filePart);
                    if (fileName != null && !fileName.isEmpty()) {
                        // Générer un nom de fichier unique
                        String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                        fileNames.add(uniqueFileName);
                        filePart.write(uploadPath + File.separator + uniqueFileName);
                    }
                }
                
                // Enregistrement en base de données
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "INSERT INTO sinistres (member_id, assurance_id, type_sinistre, date_sinistre, " +
                               "montant_indemnisation, description, documents, statut, date_declaration) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, 'EN_COURS', NOW())";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, memberId);
                        ps.setInt(2, assuranceId);
                        ps.setString(3, typeSinistre);
                        ps.setString(4, dateSinistre);
                        ps.setDouble(5, montantIndemnisation);
                        ps.setString(6, description);
                        ps.setString(7, String.join(",", fileNames));
                        
                        int rowsAffected = ps.executeUpdate();
                        
                        if (rowsAffected > 0) {
                            request.setAttribute("successMessage", "Votre déclaration de sinistre a été enregistrée avec succès.");
                        } else {
                            request.setAttribute("errorMessage", "Une erreur est survenue lors de l'enregistrement de votre déclaration.");
                        }
                    }
                }
                
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Erreur lors du traitement de votre demande: " + e.getMessage());
            }
            
            // Redirection vers la même page avec un message
            request.getRequestDispatcher("declarerSinistre.jsp").forward(request, response);
        }
    }
    
    private String getFileName(Part part) {
        String contentDisposition = part.getHeader("content-disposition");
        String[] tokens = contentDisposition.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }
}