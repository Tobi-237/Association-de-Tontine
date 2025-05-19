<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>

<%
// Vérifier si l'utilisateur est admin
String memberRole = (String) session.getAttribute("role");
if (!"ADMIN".equals(memberRole)) {
    session.setAttribute("errorMessage", "Accès refusé. Vous devez être administrateur.");
    response.sendRedirect("assurances.jsp");
    return;
}

// Récupérer l'ID de la compagnie
int compagnieId = Integer.parseInt(request.getParameter("id"));

try (Connection conn = DBConnection.getConnection()) {
    // Vérifier si la compagnie est utilisée dans des assurances
    String checkSql = "SELECT COUNT(*) FROM assurances WHERE compagnie_id = ?";
    try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
        checkPs.setInt(1, compagnieId);
        try (ResultSet rs = checkPs.executeQuery()) {
            if (rs.next() && rs.getInt(1) > 0) {
                session.setAttribute("errorMessage", "Impossible de supprimer cette compagnie car elle est utilisée dans des contrats d'assurance.");
                response.sendRedirect("compagnieDetails.jsp?id=" + compagnieId);
                return;
            }
        }
    }
    
    // Supprimer la compagnie
    String sql = "DELETE FROM compagnies_assurance WHERE id = ?";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, compagnieId);
        
        int affectedRows = ps.executeUpdate();
        
        if (affectedRows > 0) {
            session.setAttribute("successMessage", "La compagnie d'assurance a été supprimée avec succès.");
        } else {
            session.setAttribute("errorMessage", "Erreur lors de la suppression de la compagnie.");
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
    session.setAttribute("errorMessage", "Une erreur est survenue: " + e.getMessage());
}

response.sendRedirect("assurances.jsp?tab=compagnies");
%>