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

@WebServlet("/ValidateUserServlet")
public class ValidateUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Constantes pour les statuts et actions
    private static final String ACTION_VALIDATE = "validate";
    private static final String ACTION_REJECT = "reject";
    private static final String ACTIVE_STATUS = "valide";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            int userId = Integer.parseInt(request.getParameter("userId"));
            String action = request.getParameter("action");
            
            processUserValidation(userId, action, response);
            
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Invalid+user+ID");
        }
    }
    
    private void processUserValidation(int userId, String action, HttpServletResponse response) 
            throws IOException {
        
        try (Connection conn = DBConnection.getConnection()) {
            Member member = getMemberById(conn, userId);
            
            if (member == null) {
                response.sendRedirect("error.jsp?message=User+not+found");
                return;
            }
            
            if (ACTION_VALIDATE.equals(action)) {
                validateMember(conn, userId);
                sendValidationEmail(member.getEmail(), member.getNom());
                
            } else if (ACTION_REJECT.equals(action)) {
                rejectMember(conn, userId);
                sendRejectionEmail(member.getEmail(), member.getNom());
            }
            
            response.sendRedirect("welcome.jsp");
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Database+error");
        }
    }
    
    private void validateMember(Connection conn, int userId) throws SQLException {
        String sql = "UPDATE members SET statut = ?, isMember = 0 WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, ACTIVE_STATUS);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }
    
    private void rejectMember(Connection conn, int userId) throws SQLException {
        String sql = "DELETE FROM members WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
    
    private Member getMemberById(Connection conn, int id) throws SQLException {
        String sql = "SELECT id, nom, prenom, email FROM members WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Member(
                        rs.getInt("id"),
                        rs.getString("nom"),
                        rs.getString("prenom"),
                        rs.getString("email")
                        // autres champs si nécessaire
                    );
                }
            }
        }
        return null;
    }
    
    private void sendValidationEmail(String toEmail, String name) {
        String subject = "Validation de votre adhésion";
        String content = "Bonjour " + name + ",\n\n" +
            "Nous avons le plaisir de vous informer que votre demande d'adhésion a été validée.\n\n" +
            "Vous pouvez maintenant vous connecter à votre compte et accéder à toutes les fonctionnalités.\n\n" +
            "Cordialement,\n" +
            "L'équipe Tontine GO-FAR";
        
        EmailService.sendEmail(toEmail, subject, content);
    }
    
    private void sendRejectionEmail(String toEmail, String name) {
        String subject = "Réponse à votre demande d'adhesion";
        String content = "Objet : Réponse à votre demande d'adhésion\n\n" +
            "Bonjour " + name + ",\n\n" +
            "Nous avons bien reçu votre demande d'adhésion à Tontine GO-FAR et vous remercions pour l'intérêt que vous portez à notre organisation.\n\n" +
            "Après examen de votre dossier, nous regrettons de vous informer que nous ne pouvons pas donner une suite favorable à votre demande. En effet, nous avons constaté un historique de défauts de paiement lors de votre précédente adhésion, ce qui ne nous permet pas d'accepter votre réintégration à ce jour.\n\n" +
            "Toutefois, nous vous informons que le montant que vous avez éventuellement versé sera remboursé dans les plus brefs délais.\n\n" +
            "Si vous souhaitez régulariser votre situation ou obtenir des précisions, nous restons disponibles pour en discuter.\n\n" +
            "Nous vous remercions pour votre compréhension.\n\n" +
            "Cordialement,\n" +
            "L'administrateur\n" +
            "Tontine GO-FAR\n" +
            "https://wa.me/+237695050801";
        
        EmailService.sendEmail(toEmail, subject, content);
    }
}  