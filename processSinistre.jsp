<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Date" %>

<%
    // Vérification du rôle admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Récupération et validation des paramètres
    String idParam = request.getParameter("id");
    String action = request.getParameter("action");
    
    // Vérification que les paramètres ne sont pas null ou vides
    if (idParam == null || idParam.trim().isEmpty() || action == null || action.trim().isEmpty()) {
        session.setAttribute("errorMessage", "Paramètres manquants ou vides");
        response.sendRedirect("caisse.jsp#sinistres");
        return;
    }
    
    // Vérification que l'ID est bien numérique
    int id;
    try {
        id = Integer.parseInt(idParam);
        if (id <= 0) {
            session.setAttribute("errorMessage", "L'ID doit être un nombre positif");
            response.sendRedirect("caisse.jsp#sinistres");
            return;
        }
    } catch (NumberFormatException e) {
        session.setAttribute("errorMessage", "L'ID doit être un nombre valide");
        response.sendRedirect("caisse.jsp#sinistres");
        return;
    }
    
    try (Connection conn = DBConnection.getConnection()) {
        // Vérifier d'abord si le sinistre existe et est en attente
        String checkSql = "SELECT statut FROM sinistres_mutuelle WHERE id = ?";
        String currentStatus = null;
        
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setInt(1, id);
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
        
        if (!"PENDING".equals(currentStatus)) {
            session.setAttribute("errorMessage", "Le statut du sinistre ne permet pas cette action");
            response.sendRedirect("caisse.jsp#sinistres");
            return;
        }
        
        // Mise à jour du statut du sinistre
        String updateSql = "UPDATE sinistres_mutuelle SET statut = ?, date_traitement = ? WHERE id = ?";
        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
            updatePs.setString(1, action);
            updatePs.setDate(2, new java.sql.Date(new Date().getTime()));
            updatePs.setInt(3, id);
            updatePs.executeUpdate();
        }
        
        // Si le sinistre est approuvé, déterminer le montant à payer selon le type
        if ("APPROVED".equals(action)) {
            // Récupérer les infos du sinistre
            String sinistreSql = "SELECT type_sinistre, member_id FROM sinistres_mutuelle WHERE id = ?";
            String typeSinistre = null;
            int memberId = 0;
            
            try (PreparedStatement sinistrePs = conn.prepareStatement(sinistreSql)) {
                sinistrePs.setInt(1, id);
                try (ResultSet rs = sinistrePs.executeQuery()) {
                    if (rs.next()) {
                        typeSinistre = rs.getString("type_sinistre");
                        memberId = rs.getInt("member_id");
                    }
                }
            }
            
            // Déterminer le montant selon le type de sinistre
            BigDecimal montant = BigDecimal.ZERO;
            if (typeSinistre != null) {
                switch(typeSinistre) {
                    case "HOSPITALISATION":
                        montant = new BigDecimal("50000"); // 50,000 FCFA
                        break;
                    case "DECES_MEMBRE":
                        montant = new BigDecimal("100000"); // 100,000 FCFA
                        break;
                    case "DECES_CONJOINT":
                        montant = new BigDecimal("50000"); // 50,000 FCFA
                        break;
                    case "DECES_PARENT":
                        montant = new BigDecimal("30000"); // 30,000 FCFA
                        break;
                    case "DECES_ENFANT":
                        montant = new BigDecimal("30000"); // 30,000 FCFA
                        break;
                    default:
                        session.setAttribute("errorMessage", "Type de sinistre non reconnu");
                        response.sendRedirect("caisse.jsp#sinistres");
                        return;
                }
            }
            
            // Mettre à jour le montant dans la table sinistres_mutuelle
            String updateMontantSql = "UPDATE sinistres_mutuelle SET montant_verse = ? WHERE id = ?";
            try (PreparedStatement updateMontantPs = conn.prepareStatement(updateMontantSql)) {
                updateMontantPs.setBigDecimal(1, montant);
                updateMontantPs.setInt(2, id);
                updateMontantPs.executeUpdate();
            }
        }
        
        session.setAttribute("successMessage", "Le sinistre a été traité avec succès");
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors du traitement du sinistre: " + e.getMessage());
    }
    
    response.sendRedirect("caisse.jsp#sinistres");
%>