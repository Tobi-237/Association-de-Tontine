package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.Date;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.DBConnection;

@WebServlet(name = "SanctionServlet", urlPatterns = {"/SanctionServlet"})
public class SanctionServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if (action != null) {
            switch (action) {
                case "delete":
                    deleteSanction(request, response);
                    break;
                case "lift":
                    liftSanction(request, response);
                    break;
                default:
                    saveSanction(request, response);
            }
        } else {
            saveSanction(request, response);
        }
    }

    private void saveSanction(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String idStr = request.getParameter("sanctionId");
        int memberId = Integer.parseInt(request.getParameter("member_id"));
        String typeSanction = request.getParameter("type_sanction");
        double montant = Double.parseDouble(request.getParameter("montant"));
        String details = request.getParameter("details");
        
        // Gestion optionnelle de la tontine et de la date de fin
        String tontineIdStr = request.getParameter("tontine_id");
        Integer tontineId = tontineIdStr != null && !tontineIdStr.isEmpty() ? Integer.parseInt(tontineIdStr) : null;
        
        String dateFinStr = request.getParameter("date_fin");
        Timestamp dateFin = null;
        if (dateFinStr != null && !dateFinStr.isEmpty()) {
            dateFin = Timestamp.valueOf(dateFinStr.replace("T", " ") + ":00");
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            
            if (idStr == null || idStr.isEmpty()) {
                // Insertion d'une nouvelle sanction
                String sql = "INSERT INTO sanctions (member_id, tontine_id, type_sanction, montant, details, date_sanction, date_fin, statut) "
                           + "VALUES (?, ?, ?, ?, ?, NOW(), ?, 'ACTIVE')";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, memberId);
                if (tontineId != null) {
                    pstmt.setInt(2, tontineId);
                } else {
                    pstmt.setNull(2, java.sql.Types.INTEGER);
                }
                pstmt.setString(3, typeSanction);
                pstmt.setDouble(4, montant);
                pstmt.setString(5, details);
                pstmt.setTimestamp(6, dateFin);
            } else {
                // Mise à jour d'une sanction existante
                int id = Integer.parseInt(idStr);
                String sql = "UPDATE sanctions SET member_id=?, tontine_id=?, type_sanction=?, montant=?, details=?, date_fin=? WHERE id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, memberId);
                if (tontineId != null) {
                    pstmt.setInt(2, tontineId);
                } else {
                    pstmt.setNull(2, java.sql.Types.INTEGER);
                }
                pstmt.setString(3, typeSanction);
                pstmt.setDouble(4, montant);
                pstmt.setString(5, details);
                pstmt.setTimestamp(6, dateFin);
                pstmt.setInt(7, id);
            }
            
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la sauvegarde de la sanction");
        } finally {
            DBConnection.closeResources(conn, pstmt, null);
        }
        
        response.sendRedirect("sanctions.jsp");
    }

    private void deleteSanction(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "DELETE FROM sanctions WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la suppression de la sanction");
        } finally {
            DBConnection.closeResources(conn, pstmt, null);
        }
        
        response.sendRedirect("sanctions.jsp");
    }

    private void liftSanction(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "UPDATE sanctions SET statut='LEVEE', date_fin=NOW() WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la levée de la sanction");
        } finally {
            DBConnection.closeResources(conn, pstmt, null);
        }
        
        response.sendRedirect("sanctions.jsp");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet pour la gestion des sanctions";
    }
}