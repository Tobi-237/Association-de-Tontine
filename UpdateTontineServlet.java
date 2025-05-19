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
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebServlet("/UpdateTontineServlet")
public class UpdateTontineServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        if (session == null || session.getAttribute("memberId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer memberId = (Integer) session.getAttribute("memberId");
        
        // Récupération des paramètres
        String idParam = request.getParameter("id");
        String nom = request.getParameter("nom");
        String description = request.getParameter("description");
        String montantStr = request.getParameter("montant");
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinStr = request.getParameter("dateFin");
        //String etat = request.getParameter("etat");
        String modeReglement = request.getParameter("mode_reglement");
        String periode = request.getParameter("periode");
        String frequence = request.getParameter("frequence");
        String jourCotisationStr = request.getParameter("jour_cotisation");
        
        // Validation des données
        StringBuilder error = new StringBuilder();
        
        // Validation de l'ID
        int id = 0;
        try {
            id = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            error.append("ID invalide. ");
        }
        
        if (nom == null || nom.trim().isEmpty()) {
            error.append("Nom requis. ");
        }
        
        BigDecimal montant = null;
        try {
            montant = new BigDecimal(montantStr);
            if (montant.compareTo(BigDecimal.ZERO) <= 0) {
                error.append("Montant invalide. ");
            }
        } catch (NumberFormatException | NullPointerException e) {
            error.append("Montant invalide. ");
        }

        LocalDate dateDebut = null;
        LocalDate dateFin = null;
        try {
            dateDebut = LocalDate.parse(dateDebutStr);
            dateFin = LocalDate.parse(dateFinStr);
            if (dateDebut.isAfter(dateFin)) {
                error.append("Dates incohérentes. ");
            }
        } catch (DateTimeParseException | NullPointerException e) {
            error.append("Format de date invalide. ");
        }

        //if (etat == null || !(etat.equals("ACTIVE") || etat.equals("COMPLETED") || etat.equals("CANCELLED"))) {
          //  error.append("État invalide. ");
        //}

       

        if (error.length() > 0) {
            response.sendRedirect("tontine.jsp?editId=" + idParam + "&error=" + error.toString());
            return;
        }

        // Requête SQL de mise à jour
        String sql = "UPDATE tontines SET nom=?, description=?, montant_mensuel=?, "
                   + "date_debut=?, date_fin=?, mode_reglement=?, periode=?, "
                   + "frequence=? WHERE id =?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, nom);
            pstmt.setString(2, description);
            pstmt.setBigDecimal(3, montant);
            pstmt.setObject(4, dateDebut);
            pstmt.setObject(5, dateFin);
            //pstmt.setString(6, etat);
            pstmt.setString(6, modeReglement);
            pstmt.setString(7, periode);
            pstmt.setString(8, frequence);
           
            pstmt.setInt(9, id);

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                response.sendRedirect("tontine.jsp?success=Tontine mise à jour avec succès");
            } else {
                response.sendRedirect("tontine.jsp?editId=" + idParam + "&error=Échec de la mise à jour ou accès non autorisé");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            handleDatabaseError(e, response, idParam);
        }
    }

    private void handleDatabaseError(SQLException e, HttpServletResponse response, String idParam) throws IOException {
        String errorMessage;
        if (e.getSQLState().startsWith("23")) { // Violation de contrainte
            errorMessage = "Une tontine avec ce nom existe déjà";
        } else {
            errorMessage = "Erreur base de données: " + e.getMessage();
        }
        response.sendRedirect("tontine.jsp?editId=" + idParam + "&error=" + errorMessage);
    }
}