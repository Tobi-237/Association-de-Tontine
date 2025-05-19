package servlets;

import utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/saveSanctionServlet")
public class saveSanctionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        try {
            // Récupération des paramètres
            String memberId = request.getParameter("memberSelect");
            String sanctionType = request.getParameter("sanctionType");
            String amount = request.getParameter("sanctionAmount");
            String date = request.getParameter("sanctionDate");
            String endDate = request.getParameter("sanctionEndDate");
            String reason = request.getParameter("sanctionReason");

            // Validation
            if (memberId == null || memberId.isEmpty() || 
                sanctionType == null || sanctionType.isEmpty() || 
                amount == null || amount.isEmpty() || 
                date == null || date.isEmpty() || 
                reason == null || reason.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Tous les champs obligatoires doivent être remplis");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO sanctions (member_id, type_sanction, montant, date_sanction, date_fin, motif, statut) "
                           + "VALUES (?, ?, ?, ?, ?, ?, 'ACTIVE')";

                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setInt(1, Integer.parseInt(memberId));
                    pstmt.setString(2, sanctionType);
                    pstmt.setDouble(3, Double.parseDouble(amount));
                    pstmt.setString(4, date);
                    
                    if (endDate == null || endDate.isEmpty()) {
                        pstmt.setNull(5, java.sql.Types.TIMESTAMP);
                    } else {
                        pstmt.setString(5, endDate);
                    }
                    
                    pstmt.setString(6, reason);

                    int rows = pstmt.executeUpdate();
                    if (rows > 0) {
                        // Redirection vers sanctionAdmin.jsp après succès
                        response.sendRedirect("sanctionAdmin.jsp");
                        return;
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("Aucune ligne n'a été insérée");
                    }
                }
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Format numérique invalide");
        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Erreur de base de données: " + e.getMessage());
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Erreur serveur: " + e.getMessage());
        }
    }
}