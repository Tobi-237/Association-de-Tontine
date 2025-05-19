<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    // Vérification du rôle admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Récupération et validation de l'ID du sinistre
    String idParam = request.getParameter("id");
    
    // Vérification que le paramètre n'est pas null ou vide
    if (idParam == null || idParam.trim().isEmpty()) {
        session.setAttribute("errorMessage", "L'ID du sinistre est manquant");
        response.sendRedirect("caisse.jsp#sinistres");
        return;
    }

    // Conversion sécurisée de l'ID
    int sinistreId;
    try {
        sinistreId = Integer.parseInt(idParam);
        if (sinistreId <= 0) {
            session.setAttribute("errorMessage", "L'ID du sinistre doit être un nombre positif");
            response.sendRedirect("caisse.jsp#sinistres");
            return;
        }
    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "L'ID du sinistre doit être un nombre valide");
        response.sendRedirect("caisse.jsp#sinistres");
        return;
    }

    try (Connection conn = DBConnection.getConnection()) {
        // Vérifier d'abord que le sinistre existe et est approuvé
        String checkSql = "SELECT statut FROM sinistres_mutuelle WHERE id = ?";
        String currentStatus = null;
        
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, sinistreId);
            try (ResultSet rs = checkPs.executeQuery()) {
                if (rs.next()) {
                    currentStatus = rs.getString("statut");
                } else {
                    session.setAttribute("errorMessage", "Aucun sinistre trouvé avec cet ID");
                    response.sendRedirect("caisse.jsp#sinistres");
                    return;
                }
            }
        }

        if (!"APPROVED".equals(currentStatus)) {
            session.setAttribute("errorMessage", "Le sinistre doit être approuvé avant paiement");
            response.sendRedirect("caisse.jsp#sinistres");
            return;
        }

        // Mettre à jour le statut du sinistre en "PAID"
        String updateSql = "UPDATE sinistres_mutuelle SET statut = 'PAID', date_traitement = ? WHERE id = ?";
        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
            updatePs.setDate(1, new java.sql.Date(new Date().getTime()));
            updatePs.setInt(2, sinistreId);
            updatePs.executeUpdate();
        }

        session.setAttribute("successMessage", "Le paiement du sinistre a été enregistré avec succès");
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors du paiement du sinistre: " + e.getMessage());
    }
    
    response.sendRedirect("caisse.jsp#sinistres");
%>