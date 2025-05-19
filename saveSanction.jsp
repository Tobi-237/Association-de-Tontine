<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.math.BigDecimal" %>
<%
    // Vérification du rôle admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Récupération des paramètres du formulaire
    int memberId = Integer.parseInt(request.getParameter("member_id"));
    String typeSanction = request.getParameter("type_sanction");
    BigDecimal montant = new BigDecimal(request.getParameter("montant"));
    String dateSanctionStr = request.getParameter("date_sanction");
    String raison = request.getParameter("raison");

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    Date dateSanction = sdf.parse(dateSanctionStr);

    // Connexion à la base de données et insertion
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "INSERT INTO sanctions (member_id, type_sanction, montant, date_sanction, raison, statut) " +
                     "VALUES (?, ?, ?, ?, ?, 'PENDING')";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.setString(2, typeSanction);
            ps.setBigDecimal(3, montant);
            ps.setDate(4, new java.sql.Date(dateSanction.getTime()));
            ps.setString(5, raison);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                session.setAttribute("successMessage", "Sanction enregistrée avec succès !");
            } else {
                session.setAttribute("errorMessage", "Erreur lors de l'enregistrement de la sanction.");
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur: " + e.getMessage());
    }

    // Redirection vers la page de gestion des caisses
    response.sendRedirect("adminCaisses.jsp");
%>