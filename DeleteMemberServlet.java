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

@WebServlet("/DeleteMemberServlet")
public class DeleteMemberServlet extends HttpServlet {
	 private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("adherents.jsp?error=ID manquant");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "DELETE FROM members WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, Integer.parseInt(idParam));
                int rowsAffected = pstmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("adherents.jsp?success=Adhérent supprimé");
                } else {
                    response.sendRedirect("adherents.jsp?error=Adhérent introuvable");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adherents.jsp?error=Erreur de suppression");
        }
    }
}
