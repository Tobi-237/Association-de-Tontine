<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.sql.*"%>
<%@page import="utils.DBConnection"%>
<%@page import="org.json.JSONObject"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>

<%
    response.setContentType("application/json");
    String id = request.getParameter("id");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    
    JSONObject result = new JSONObject();
    
    if (id == null || id.isEmpty()) {
        result.put("success", false);
        result.put("message", "ID d'intérêt non spécifié");
        out.print(result.toString());
        return;
    }
    
    try (Connection conn = DBConnection.getConnection()) {
        // Vérifier d'abord si l'intérêt n'a pas déjà été payé
        String checkSql = "SELECT statut FROM interets_scolaires WHERE id = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, Integer.parseInt(id));
            ResultSet rs = checkPs.executeQuery();
            if (rs.next()) {
                if ("PAID".equals(rs.getString("statut"))) {
                    result.put("success", false);
                    result.put("message", "Cet intérêt a déjà été payé");
                    out.print(result.toString());
                    return;
                }
            } else {
                result.put("success", false);
                result.put("message", "Intérêt non trouvé");
                out.print(result.toString());
                return;
            }
        }
        
        // Mettre à jour le statut et la date de paiement
        String updateSql = "UPDATE interets_scolaires SET statut = 'PAID', date_paiement = ? WHERE id = ?";
        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
            updatePs.setString(1, sdf.format(new Date()));
            updatePs.setInt(2, Integer.parseInt(id));
            
            int rowsAffected = updatePs.executeUpdate();
            if (rowsAffected > 0) {
                result.put("success", true);
                result.put("message", "Paiement enregistré avec succès");
            } else {
                result.put("success", false);
                result.put("message", "Échec de la mise à jour du paiement");
            }
        }
    } catch (SQLException e) {
        result.put("success", false);
        result.put("message", "Erreur de base de données: " + e.getMessage());
    } catch (NumberFormatException e) {
        result.put("success", false);
        result.put("message", "ID invalide");
    }
    
    out.print(result.toString());
%>