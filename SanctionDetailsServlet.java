package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import utils.DBConnection;

@WebServlet(name = "SanctionDetailsServlet", urlPatterns = {"/SanctionDetailsServlet"})
public class SanctionDetailsServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String mode = request.getParameter("mode");
        
        if (mode != null && mode.equals("edit")) {
            getSanctionForEdit(response, id);
        } else {
            getSanctionDetails(response, id);
        }
    }
    
    private void getSanctionDetails(HttpServletResponse response, String id) throws IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT s.*, m.nom, m.prenom, t.nom as tontine_nom "
                       + "FROM sanctions s "
                       + "JOIN members m ON s.member_id = m.id "
                       + "LEFT JOIN tontines t ON s.tontine_id = t.id "
                       + "WHERE s.id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(id));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                response.setContentType("text/html");
                PrintWriter out = response.getWriter();
                
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                
                out.println("<div class='sanction-details'>");
                out.println("<div class='detail-row'><strong>Membre:</strong> " + rs.getString("prenom") + " " + rs.getString("nom") + "</div>");
                
                if (rs.getString("tontine_nom") != null) {
                    out.println("<div class='detail-row'><strong>Tontine:</strong> " + rs.getString("tontine_nom") + "</div>");
                }
                
                out.println("<div class='detail-row'><strong>Type:</strong> " + getSanctionTypeLabel(rs.getString("type_sanction")) + "</div>");
                out.println("<div class='detail-row'><strong>Montant:</strong> " + String.format("%,.2f", rs.getDouble("montant")) + " FCFA</div>");
                out.println("<div class='detail-row'><strong>Date sanction:</strong> " + sdf.format(rs.getTimestamp("date_sanction")) + "</div>");
                
                if (rs.getTimestamp("date_fin") != null) {
                    out.println("<div class='detail-row'><strong>Date fin:</strong> " + sdf.format(rs.getTimestamp("date_fin")) + "</div>");
                }
                
                out.println("<div class='detail-row'><strong>Statut:</strong> " + getStatusLabel(rs.getString("statut")) + "</div>");
                out.println("<div class='detail-row'><strong>Détails:</strong><br>" + rs.getString("details") + "</div>");
                out.println("</div>");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la récupération des détails");
        } finally {
            DBConnection.closeResources(conn, pstmt, rs);
        }
    }
    
    private void getSanctionForEdit(HttpServletResponse response, String id) throws IOException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM sanctions WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(id));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                JSONObject json = new JSONObject();
                json.put("id", rs.getInt("id"));
                json.put("member_id", rs.getInt("member_id"));
                json.put("tontine_id", rs.getObject("tontine_id"));
                json.put("type_sanction", rs.getString("type_sanction"));
                json.put("montant", rs.getDouble("montant"));
                json.put("details", rs.getString("details"));
                
                if (rs.getTimestamp("date_fin") != null) {
                    json.put("date_fin", rs.getTimestamp("date_fin").toString());
                }
                
                response.setContentType("application/json");
                response.getWriter().print(json.toString());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Erreur lors de la récupération des données");
        } finally {
            DBConnection.closeResources(conn, pstmt, rs);
        }
    }
    
    private String getSanctionTypeLabel(String type) {
        switch(type) {
            case "RETARD": return "Retard de paiement";
            case "NON_PAIEMENT": return "Non-paiement répété";
            case "RETRAIT": return "Retrait anticipé";
            case "FRAUDE": return "Fraude ou abus";
            default: return type;
        }
    }
    
    private String getStatusLabel(String status) {
        switch(status) {
            case "ACTIVE": return "Active";
            case "LEVEE": return "Levée";
            case "ANNULEE": return "Annulée";
            default: return status;
        }
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
        return "Servlet pour les détails des sanctions";
    }
}