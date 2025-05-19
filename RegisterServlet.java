package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import utils.DBConnection;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String member_id = request.getParameter("member_id");
        String nom = request.getParameter("nom");
        String prenom = request.getParameter("prenom");
        String email = request.getParameter("email").trim();
        String inscription = request.getParameter("Fraid_dadhesion");
        String numero = request.getParameter("numero");
        String localisation = request.getParameter("localisation");
        String password = request.getParameter("password").trim();

        Connection conn = null;
        PreparedStatement membreStmt = null;
        PreparedStatement mutuelleStmt = null;
        
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Démarrer une transaction

            // Insertion dans la table members
            String requeteMembre = "INSERT INTO members (member_id, nom, prenom, email, inscription, numero, localisation, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            membreStmt = conn.prepareStatement(requeteMembre);
            membreStmt.setString(1, member_id);
            membreStmt.setString(2, nom);
            membreStmt.setString(3, prenom);
            membreStmt.setString(4, email);
            membreStmt.setString(5, inscription);
            membreStmt.setString(6, numero);
            membreStmt.setString(7, localisation);
            membreStmt.setString(8, password);
            
            int lignesInserees = membreStmt.executeUpdate();
            
            if (lignesInserees > 0) {
                // Si l'insertion du membre réussit, insérer dans la table mutuelle
                String requeteMutuelle = "INSERT INTO mutuelle (member_id, montant, statut) VALUES (?, ?, 'ACTIVE')";
                mutuelleStmt = conn.prepareStatement(requeteMutuelle);
                mutuelleStmt.setString(1, member_id);
                mutuelleStmt.setString(2, inscription);
                
                int lignesMutuelle = mutuelleStmt.executeUpdate();
                
                if (lignesMutuelle > 0) {
                    conn.commit(); // Valider la transaction si les deux insertions réussissent
                    response.sendRedirect("login.jsp?success=Compte créé avec succès");
                } else {
                    conn.rollback(); // Annuler si l'insertion mutuelle échoue
                    response.sendRedirect("login.jsp?error=Échec de l'inscription à la mutuelle");
                }
            } else {
                conn.rollback(); // Annuler si l'insertion du membre échoue
                response.sendRedirect("login.jsp?error=Échec de l'inscription");
            }
        } catch (Exception e) {
            try {
                if (conn != null) conn.rollback(); // Annuler en cas d'exception
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Erreur de base de données: " + e.getMessage());
        } finally {
            // Fermer les ressources
            try {
                if (membreStmt != null) membreStmt.close();
                if (mutuelleStmt != null) mutuelleStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}