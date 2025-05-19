package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.math.BigDecimal;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import models.User;
import utils.DBConnection;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final BigDecimal MONTANT_SOUSCRIPTION = new BigDecimal("10000");

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
    	
    	
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        
        try (Connection conn = DBConnection.getConnection()) {
            HttpSession session = request.getSession(true);
            
            // Essai de connexion en tant qu'administrateur
            if (connexionAdmin(conn, session, email, password)) {
                response.sendRedirect("welcome.jsp");
                return;
            }
            
            // Essai de connexion en tant que membre
            if (connexionMembre(conn, session, email, password)) {
                response.sendRedirect("admin.jsp");
                return;
            }
            
            // Si les identifiants sont incorrects
            response.sendRedirect("login.jsp?error=Identifiants invalides");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=Erreur base de données");
        }
    }
    
    private boolean connexionAdmin(Connection conn, HttpSession session, String email, String password) 
            throws Exception {
        String requete = "SELECT * FROM users WHERE email = ? AND password = ? AND role = 'ADMIN'";
        
        try (PreparedStatement stmt = conn.prepareStatement(requete)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int idMembre = rs.getInt("id");
                    configurerSessionAdmin(session, email, idMembre);
                    return true;
                }
            }
        }
        return false;
    }
    
    private boolean connexionMembre(Connection conn, HttpSession session, String email, String password) 
            throws Exception {
        String requete = "SELECT * FROM members WHERE email = ? AND password = ?";
        
        try (PreparedStatement stmt = conn.prepareStatement(requete)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    if (!"valide".equals(rs.getString("statut"))) {
                        return false;
                    }
                    
                    int idMembre = rs.getInt("id");
                    configurerSessionMembre(conn, session, email, idMembre);
                    return true;
                }
            }
        }
        return false;
    }
    
    private void configurerSessionAdmin(HttpSession session, String email, int idMembre) {
        session.setAttribute("email", email);
        session.setAttribute("role", "ADMIN");
        session.setAttribute("memberId", idMembre);
        session.setAttribute("isAdmin", true);
        
        
        // Création de l'utilisateur avec les paramètres appropriés
        // (Adaptez selon le constructeur réel de votre classe User)
        User utilisateur = new User();
        utilisateur.setEmail(email);
        utilisateur.setRole("ADMIN");
        session.setAttribute("currentUser", utilisateur);
        
        // Configuration des attributs de paiement (optionnel pour admin)
        session.setAttribute("paymentSuccess", true);
        session.setAttribute("paymentAmount", MONTANT_SOUSCRIPTION);
    }
    
    private void configurerSessionMembre(Connection conn, HttpSession session, String email, int idMembre) 
            throws Exception {
        session.setAttribute("memberId", idMembre);
        session.setAttribute("member_id", idMembre);
        session.setAttribute("email", email);
        session.setAttribute("role", "MEMBER");
        User user = new User();
        user.setEmail(email);
        user.setRole("MEMBER");
        session.setAttribute("currentUser", user);
        
        
        verifierPaiementMembre(conn, session, idMembre);
    }
    
    private void verifierPaiementMembre(Connection conn, HttpSession session, int idMembre) 
            throws Exception {
        String requete = "SELECT * FROM paiements WHERE member_id = ? AND type_paiement = 'SOUSCRIPTION'";
        
        try (PreparedStatement stmt = conn.prepareStatement(requete)) {
            stmt.setInt(1, idMembre);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    // Membre a déjà payé
                    session.setAttribute("paymentSuccess", true);
                    session.setAttribute("paymentAmount", rs.getBigDecimal("montant"));
                    session.setAttribute("paymentMethod", rs.getString("methode_paiement"));
                    session.setAttribute("paymentReference", rs.getString("reference"));
                } else {
                    // Membre n'a pas encore payé
                    session.setAttribute("paymentSuccess", false);
                }
            }
        }
    }
}