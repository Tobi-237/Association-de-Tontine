package servlets;

import utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;

@WebServlet("/EditTontineServlet")
public class EditTontineServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    // Affichage du formulaire d'édition
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!validateSession(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (!validateIdParam(idParam)) {
            response.sendRedirect("tontine.jsp?error=ID invalide");
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT * FROM tontines WHERE id = ?")) {
            
            ps.setInt(1, Integer.parseInt(idParam));
//            ps.setInt(2, (Integer) session.getAttribute("memberId"));
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                	Tontine tontine = Tontine.fromResultSet(rs);
                    request.setAttribute("tontine", tontine);
                    request.getRequestDispatcher("editTontine.jsp").forward(request, response);
                } else {
                    response.sendRedirect("tontine.jsp?error=Accès non autorisé");
                }
            }
        } catch (Exception e) {
            handleError(e, response);
        }
    }

    // Traitement de la modification
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (!validateSession(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Validation des paramètres
        String[] params = validateRequestParams(request);
        if (params == null) {
            response.sendRedirect("tontine.jsp?error=Données invalides");
            return;
        }

        // Mise à jour en base
        String sql = "UPDATE tontines SET nom=?, description=?, montant_mensuel=?, "
                   + "date_debut=?, date_fin=?, etat=? WHERE id=? AND member_id=?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, params[0]);
            ps.setString(2, params[1]);
            ps.setBigDecimal(3, new BigDecimal(params[2]));
            ps.setObject(4, LocalDate.parse(params[3]));
            ps.setObject(5, LocalDate.parse(params[4]));
            ps.setString(6, params[5]);
            ps.setInt(7, Integer.parseInt(params[6]));
            ps.setInt(8, (Integer) session.getAttribute("memberId"));

            if (ps.executeUpdate() > 0) {
                response.sendRedirect("tontine.jsp?success=Modification réussie");
            } else {
                response.sendRedirect("tontine.jsp?error=Échec de la modification");
            }
            
        } catch (SQLException e) {
            handleDatabaseError(e, response);
        } catch (Exception e) {
            handleError(e, response);
        }
    }

    // Méthodes utilitaires
    private boolean validateSession(HttpSession session) {
        return session != null && session.getAttribute("memberId") != null;
    }

    private boolean validateIdParam(String idParam) {
        try {
            Integer.parseInt(idParam);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private String[] validateRequestParams(HttpServletRequest request) {
        String[] params = new String[7];
        try {
            params[0] = request.getParameter("nom");
            params[1] = request.getParameter("description");
            params[2] = request.getParameter("montant");
            params[3] = request.getParameter("dateDebut");
            params[4] = request.getParameter("dateFin");
            params[5] = request.getParameter("etat");
            params[6] = request.getParameter("id");

            if (params[0] == null || params[0].trim().isEmpty() ||
                new BigDecimal(params[2]).compareTo(BigDecimal.ZERO) <= 0 ||
                LocalDate.parse(params[3]).isAfter(LocalDate.parse(params[4]))) {
                return null;
            }
            return params;
            
        } catch (Exception e) {
            return null;
        }
    }

    private void handleDatabaseError(SQLException e, HttpServletResponse response) throws IOException {
        String errorMsg = e.getErrorCode() == 1062 ? "Nom déjà existant" : "Erreur base de données";
        response.sendRedirect("tontine.jsp?error=" + errorMsg);
    }

    private void handleError(Exception e, HttpServletResponse response) throws IOException {
        e.printStackTrace();
        response.sendRedirect("tontine.jsp?error=Erreur système");
    }
}