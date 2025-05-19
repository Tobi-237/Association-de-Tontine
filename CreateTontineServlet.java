package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import utils.DBConnection;

@WebServlet("/CreateTontineServlet")
public class CreateTontineServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer memberId = (Integer) session.getAttribute("memberId");
        
        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Récupérer les paramètres du formulaire
        String nom = request.getParameter("nom");
        String code = request.getParameter("code");
        String description = request.getParameter("description");
        String montantStr = request.getParameter("montant");
        String modeReglement = request.getParameter("mode_reglement");
        String frequence = request.getParameter("frequence");
        String periode = determinePeriodeFromFrequence(frequence); // Nouvelle ligne
        String dateDebutStr = request.getParameter("dateDebut");
        String dateFinStr = request.getParameter("dateFin");
        
        // Validation des champs obligatoires
        if (nom == null || nom.trim().isEmpty() ||
            montantStr == null || montantStr.trim().isEmpty() ||
            modeReglement == null || modeReglement.trim().isEmpty() ||
            frequence == null || frequence.trim().isEmpty() ||
            dateDebutStr == null || dateDebutStr.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Tous les champs obligatoires doivent être remplis");
            response.sendRedirect("tontine.jsp");
            return;
        }
        
        try {
            // Convertir les types avec gestion des erreurs
            double montant = Double.parseDouble(montantStr.trim());
            
            // Validation du montant selon la fréquence
            switch(frequence) {
                case "PRESENCE":
                    if (montant != 1000) {
                        session.setAttribute("errorMessage", "Pour la fréquence 'Présence', le montant doit être 1000 FCFA");
                        response.sendRedirect("tontine.jsp");
                        return;
                    }
                    break;
                case "HEBDOMADAIRE":
                    if (montant < 5000 || montant > 10000) {
                        session.setAttribute("errorMessage", "Pour la fréquence 'Hebdomadaire', le montant doit être entre 5000 et 10000 FCFA");
                        response.sendRedirect("tontine.jsp");
                        return;
                    }
                    break;
                case "MENSUELLE":
                    if (montant < 15000 || montant > 20000) {
                        session.setAttribute("errorMessage", "Pour la fréquence 'Mensuelle', le montant doit être entre 15000 et 20000 FCFA");
                        response.sendRedirect("tontine.jsp");
                        return;
                    }
                    break;
            }
            
            // Si dateFin est vide, on la calcule selon la fréquence
            if (dateFinStr == null || dateFinStr.trim().isEmpty()) {
                java.time.LocalDate dateDebut = java.time.LocalDate.parse(dateDebutStr);
                java.time.LocalDate dateFin = dateDebut;
                
                switch(frequence) {
                    case "PRESENCE":
                        // Même jour
                        break;
                    case "HEBDOMADAIRE":
                        dateFin = dateDebut.plusDays(7);
                        break;
                    case "MENSUELLE":
                        // Dernier samedi du mois
                        dateFin = dateDebut.with(java.time.temporal.TemporalAdjusters.lastDayOfMonth());
                        while (dateFin.getDayOfWeek() != java.time.DayOfWeek.SATURDAY) {
                            dateFin = dateFin.minusDays(1);
                        }
                        break;
                }
                dateFinStr = dateFin.toString();
            }
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            
            try {
                conn = DBConnection.getConnection();
                String sql = "INSERT INTO tontines (member_id, nom, code, description, montant_mensuel, " +
                             "mode_reglement, frequence, periode, date_debut, date_fin, etat) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                
                pstmt = conn.prepareStatement(sql);
                pstmt.setInt(1, memberId);
                pstmt.setString(2, nom);
                pstmt.setString(3, code);
                pstmt.setString(4, description);
                pstmt.setDouble(5, montant);
                pstmt.setString(6, modeReglement);
                pstmt.setString(7, frequence);
                pstmt.setString(8, periode); // Ajout de la période
                pstmt.setString(9, dateDebutStr);
                pstmt.setString(10, dateFinStr);
                pstmt.setString(11, "ACTIVE");
                
                int rowsAffected = pstmt.executeUpdate();
                
                if (rowsAffected > 0) {
                    session.setAttribute("successMessage", "Tontine créée avec succès!");
                } else {
                    session.setAttribute("errorMessage", "Erreur lors de la création de la tontine");
                }
                
            } catch (SQLException e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Erreur de base de données: " + e.getMessage());
            } finally {
                try {
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Montant invalide: doit être un nombre");
            response.sendRedirect("tontine.jsp");
            return;
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Erreur inattendue: " + e.getMessage());
        }
        
        response.sendRedirect("tontine.jsp");
    }
    
    // Méthode pour déterminer la période en fonction de la fréquence
    private String determinePeriodeFromFrequence(String frequence) {
        switch(frequence) {
            case "PRESENCE": return "1J";
            case "HEBDOMADAIRE": return "1S";
            case "MENSUELLE": return "1M";
            default: return "1M";
        }
    }
}