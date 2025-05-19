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
    System.out.println("zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz" );
    // Récupération des paramètres
    String id = request.getParameter("id");
    String type = request.getParameter("type");
    
    if (id == null || type == null) {
        session.setAttribute("errorMessage", "Paramètres manquants");
        response.sendRedirect("caisse.jsp");
        return;
    }
    
    try (Connection conn = DBConnection.getConnection()) {
        // Mise à jour du statut selon le type
        if ("sanction".equals(type)) {
            String sql = "UPDATE sanctions SET statut = 'PAID', date_sanction = ? WHERE id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setDate(1, new java.sql.Date(new Date().getTime()));
                ps.setInt(2, Integer.parseInt(id));
                ps.executeUpdate();
            }
            
            // Enregistrer le versement dans la caisse punition
            String insertSql = "INSERT INTO versements (member_id, caisse_id, montant, date_versement, methode_paiement, statut) " +
                              "SELECT member_id, (SELECT id FROM caisses WHERE type_caisse = 'PUNITION'), montant, ?, 'ESPECES', 'VALIDATED' " +
                              "FROM sanctions WHERE id = ?";
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setDate(1, new java.sql.Date(new Date().getTime()));
                insertPs.setInt(2, Integer.parseInt(id));
                insertPs.executeUpdate();
            }
            
            session.setAttribute("successMessage", "Paiement de la sanction validé avec succès");
        } else {
            session.setAttribute("errorMessage", "Type de paiement non reconnu");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors de la validation du paiement: " + e.getMessage());
    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "ID invalide");
    }
    
    response.sendRedirect("caisse.jsp");
%>