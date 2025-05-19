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
import java.sql.ResultSet;

@WebServlet("/UpdateMemberServlet")
public class UpdateMemberServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    // Affichage du formulaire de modification
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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
            String sql = "SELECT * FROM members WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, Integer.parseInt(idParam));
                ResultSet rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    request.setAttribute("member", rs);
                    request.getRequestDispatcher("modifier_adherent.jsp").forward(request, response);
                } else {
                    response.sendRedirect("adherents.jsp?error=Adhérent introuvable");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adherents.jsp?error=Erreur de chargement");
        }
    }

    // Traitement de la modification
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp");
            return;
        }

        String id = request.getParameter("id");
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email");
        String inscription = request.getParameter("inscription");
        String fondCaisse = request.getParameter("fond_caisse");
        String localisation = request.getParameter("localisation");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE members SET nom = ?, prenom = ?, email = ?, inscription = ?, fond_caisse = ?, localisation = ? WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, nom);
                pstmt.setString(2, prenom);
                pstmt.setString(3, email);
                pstmt.setString(4, inscription);
                pstmt.setString(5, fondCaisse);
                pstmt.setString(6, localisation);
                pstmt.setInt(7, Integer.parseInt(id));

                int rowsAffected = pstmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("adherents.jsp?success=Modification réussie");
                } else {
                    response.sendRedirect("adherents.jsp?error=Échec de la modification");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adherents.jsp?error=Erreur de mise à jour");
        }
    }
}