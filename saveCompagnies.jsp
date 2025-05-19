<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Vérifier si l'utilisateur est admin
String memberRole = (String) session.getAttribute("role");
if (!"ADMIN".equals(memberRole)) {
    session.setAttribute("errorMessage", "Accès refusé. Vous devez être administrateur.");
    response.sendRedirect("assurance.jsp");
    return;
}

// Récupérer les paramètres du formulaire
String nom = request.getParameter("nom");
String contactPersonne = request.getParameter("contact_personne");
String email = request.getParameter("email");
String telephone = request.getParameter("telephone");
String typeContrat = request.getParameter("type_contrat");
String dateDebutStr = request.getParameter("date_debut");
String dateFinStr = request.getParameter("date_fin");
String conditions = request.getParameter("conditions");

// Convertir les dates
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dateDebut = sdf.parse(dateDebutStr);
java.util.Date dateFin = null;
if (dateFinStr != null && !dateFinStr.isEmpty()) {
    dateFin = sdf.parse(dateFinStr);
}

try (Connection conn = DBConnection.getConnection()) {
    String sql = "INSERT INTO compagnies_assurance (nom, contact_personne, email, telephone, " +
                 "type_contrat, date_debut, date_fin, conditions, date_creation) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, nom);
        ps.setString(2, contactPersonne);
        ps.setString(3, email);
        ps.setString(4, telephone);
        ps.setString(5, typeContrat);
        ps.setDate(6, new java.sql.Date(dateDebut.getTime()));
        
        if (dateFin != null) {
            ps.setDate(7, new java.sql.Date(dateFin.getTime()));
        } else {
            ps.setNull(7, Types.DATE);
        }
        
        ps.setString(8, conditions);
        
        int affectedRows = ps.executeUpdate();
        
        if (affectedRows > 0) {
            session.setAttribute("successMessage", "La compagnie d'assurance a été ajoutée avec succès.");
        } else {
            session.setAttribute("errorMessage", "Erreur lors de l'ajout de la compagnie d'assurance.");
        }
    }
} catch (Exception e) {
    e.printStackTrace();
    session.setAttribute("errorMessage", "Une erreur est survenue: " + e.getMessage());
}

response.sendRedirect("assurance.jsp");
%>