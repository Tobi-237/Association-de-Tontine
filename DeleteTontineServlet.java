package servlets;

import utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/DeleteTontineServlet")
public class DeleteTontineServlet extends HttpServlet {
	 private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("memberId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || !idParam.matches("\\d+")) {
            response.sendRedirect("tontine.jsp?error=ID invalide");
            return;
        }

        String sql = "DELETE FROM tontines WHERE id = ? AND member_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, Integer.parseInt(idParam));
            ps.setInt(2, (Integer) session.getAttribute("memberId"));

            int rowsDeleted = ps.executeUpdate();
            
            if (rowsDeleted > 0) {
                response.sendRedirect("tontine.jsp?success=Tontine supprimée");
            } else {
                response.sendRedirect("tontine.jsp?error=Suppression impossible");
            }
            
        } catch (SQLException e) {
            handleDeletionError(e, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("tontine.jsp?error=Erreur système");
        }
    }

    private void handleDeletionError(SQLException e, HttpServletResponse response) throws IOException {
        String errorMsg;
        if (e.getSQLState().startsWith("23")) { // Contrainte d'intégrité
            errorMsg = "Impossible de supprimer : tontine liée à des opérations";
        } else {
            errorMsg = "Erreur base de données : " + e.getMessage();
        }
        response.sendRedirect("tontine.jsp?error=" + errorMsg);
    }
}
