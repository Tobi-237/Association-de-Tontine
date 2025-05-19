<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page session="true" %>

<%
    // V�rifier si l'utilisateur est admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("cotisation.jsp");
        return;
    }

    // R�cup�rer les param�tres du formulaire
    String reminderType = request.getParameter("reminder_type");
    String message = request.getParameter("reminder_message");
    int tontineId = Integer.parseInt(request.getParameter("tontine_id"));
    String memberIdParam = request.getParameter("member_id");

    try (Connection conn = DBConnection.getConnection()) {
        // Pr�parer la liste des membres � notifier
        List<Map<String, String>> members = new ArrayList<>();
        
        if (memberIdParam != null) {
            // Rappel pour un seul membre
            String sql = "SELECT m.prenom, m.nom, m.telephone, m.email FROM members m WHERE m.id = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(memberIdParam));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Map<String, String> member = new HashMap<>();
                        member.put("prenom", rs.getString("prenom"));
                        member.put("nom", rs.getString("nom"));
                        member.put("telephone", rs.getString("telephone"));
                        member.put("email", rs.getString("email"));
                        members.add(member);
                    }
                }
            }
        } else {
            // Rappel pour tous les membres en retard
            String sql = "SELECT m.prenom, m.nom, m.telephone, m.email " +
                        "FROM members m " +
                        "JOIN tontine_adherents1 ta ON m.id = ta.member_id " +
                        "WHERE ta.tontine_id = ? " +
                        "AND m.id NOT IN (SELECT member_id FROM paiements WHERE tontine_id = ? AND type_paiement = 'COTISATION')";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, tontineId);
                ps.setInt(2, tontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, String> member = new HashMap<>();
                        member.put("prenom", rs.getString("prenom"));
                        member.put("nom", rs.getString("nom"));
                        member.put("telephone", rs.getString("telephone"));
                        member.put("email", rs.getString("email"));
                        members.add(member);
                    }
                }
            }
        }

        // Simuler l'envoi des rappels (dans un vrai syst�me, vous utiliseriez une API SMS/Email)
        for (Map<String, String> member : members) {
            String personalizedMessage = message.replace("[NOM]", member.get("prenom"));
            
            // Enregistrer l'historique des rappels dans la base de donn�es
            String logSql = "INSERT INTO reminder_logs (tontine_id, member_id, reminder_type, message, sent_at) " +
                          "VALUES (?, ?, ?, ?, NOW())";
            
            try (PreparedStatement ps = conn.prepareStatement(logSql)) {
                ps.setInt(1, tontineId);
                ps.setInt(2, memberIdParam != null ? Integer.parseInt(memberIdParam) : 0);
                ps.setString(3, reminderType);
                ps.setString(4, personalizedMessage);
                ps.executeUpdate();
            }
        }

        // Message de succ�s
        session.setAttribute("successMessage", "Rappels envoy�s avec succ�s � " + members.size() + " membre(s)");
    } catch (Exception e) {
        session.setAttribute("errorMessage", "Erreur lors de l'envoi des rappels: " + e.getMessage());
        e.printStackTrace();
    }

    response.sendRedirect("cotisation.jsp");
%>