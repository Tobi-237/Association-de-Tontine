<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
// Vérifier si l'utilisateur est admin
String memberRole = (String) session.getAttribute("role");
if (!"ADMIN".equals(memberRole)) {
    session.setAttribute("errorMessage", "Accès refusé. Vous devez être administrateur.");
    response.sendRedirect("assurance.jsp");
    return;
}

// Récupérer les paramètres du formulaire
String typeAssurance = request.getParameter("type_assurance");
int memberId = Integer.parseInt(request.getParameter("member_id"));
BigDecimal montantCouverture = new BigDecimal(request.getParameter("montant_couverture"));
BigDecimal primeMensuelle = new BigDecimal(request.getParameter("prime_mensuelle"));
String dateDebutStr = request.getParameter("date_debut");
String dateFinStr = request.getParameter("date_fin");
String compagnieIdStr = request.getParameter("compagnie_id");
String notes = request.getParameter("notes");

// Convertir les dates
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
java.util.Date dateDebut = sdf.parse(dateDebutStr);
java.util.Date dateFin = null;
if (dateFinStr != null && !dateFinStr.isEmpty()) {
    dateFin = sdf.parse(dateFinStr);
}

Integer compagnieId = null;
if (compagnieIdStr != null && !compagnieIdStr.isEmpty()) {
    compagnieId = Integer.parseInt(compagnieIdStr);
}

try (Connection conn = DBConnection.getConnection()) {
    String sql = "INSERT INTO assurances (type_assurance, member_id, montant_couverture, prime_mensuelle, " +
                 "date_debut, date_fin, compagnie_id, notes, statut, date_creation) " +
                 "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', NOW())";
    
    try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
        ps.setString(1, typeAssurance);
        ps.setInt(2, memberId);
        ps.setBigDecimal(3, montantCouverture);
        ps.setBigDecimal(4, primeMensuelle);
        ps.setDate(5, new java.sql.Date(dateDebut.getTime()));
        
        if (dateFin != null) {
            ps.setDate(6, new java.sql.Date(dateFin.getTime()));
        } else {
            ps.setNull(6, Types.DATE);
        }
        
        if (compagnieId != null) {
            ps.setInt(7, compagnieId);
        } else {
            ps.setNull(7, Types.INTEGER);
        }
        
        ps.setString(8, notes);
        
        int affectedRows = ps.executeUpdate();
        
        if (affectedRows > 0) {
            session.setAttribute("successMessage", "Le contrat d'assurance a été créé avec succès.");
        } else {
            session.setAttribute("errorMessage", "Erreur lors de la création du contrat d'assurance.");
        }
    }
} catch (Exception e) {
    e.printStackTrace();
    session.setAttribute("errorMessage", "Une erreur est survenue: " + e.getMessage());
}

response.sendRedirect("assurance.jsp");
%>