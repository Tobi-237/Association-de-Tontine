<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page session="true" %>
<%
    // Vérifier si l'utilisateur est connecté et est admin
    Integer memberId = (Integer) session.getAttribute("memberId");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    
    if (memberId == null || isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Marquer un message comme lu
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (request.getParameter("mark_as_read") != null) {
            int messageId = Integer.parseInt(request.getParameter("message_id"));
            
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "UPDATE messages SET is_read = 1 WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, messageId);
                    ps.executeUpdate();
                    
                    session.setAttribute("successMessage", "Message marqué comme lu.");
                    response.sendRedirect("messages.jsp");
                    return;
                }
            } catch(Exception e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Erreur: " + e.getMessage());
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Messages - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: 'Poppins', sans-serif;
        }
        
        body { 
            background: #f5f5f5; 
            display: flex; 
            min-height: 100vh; 
            overflow-x: hidden;
        }
        
        .sidebar {
            width: 250px;
            background: #2c3e50;
            color: white;
            height: 100vh;
            position: fixed;
            transition: all 0.3s;
            z-index: 1000;
        }
        
        .content { 
            flex: 1; 
            padding: 30px; 
            background: rgba(255, 255, 255, 0.95); 
            border-top-left-radius: 20px; 
            overflow-y: auto;
            height: 100vh;
            margin-left: -30px;
            width: calc(100% - 250px);
        }
        
        h2 {
            margin: 20px 0;
            color: #2c3e50;
            font-size: 24px;
            position: relative;
            padding-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        h2:after {
            content: "";
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 3px;
            background: #27ae60;
        }
        
        .messages-container {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        
        .message {
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: all 0.3s;
        }
        
        .message.unread {
            background: #f8f9fa;
            border-left: 4px solid #27ae60;
        }
        
        .message:hover {
            background: #f1f8fe;
        }
        
        .message-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .message-title {
            font-weight: 600;
            color: #2c3e50;
            font-size: 18px;
        }
        
        .message-date {
            color: #95a5a6;
            font-size: 14px;
        }
        
        .message-content {
            color: #34495e;
            margin-bottom: 15px;
        }
        
        .message-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 8px 15px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #219653;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #95a5a6;
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 15px;
            color: #bdc3c7;
        }
        
        .alert {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #e8f5e9;
            color: #27ae60;
            border-left: 4px solid #27ae60;
        }
        
        .alert-error {
            background: #ffebee;
            color: #e74c3c;
            border-left: 4px solid #e74c3c;
        }
        
        .badge {
            padding: 3px 8px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .badge-success {
            background: #e8f5e9;
            color: #27ae60;
        }
        
        @media (max-width: 768px) {
            .content {
                margin-left: 0;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <h2><i class="fas fa-envelope"></i> Messages</h2>
        
        <%-- Affichage des messages --%>
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= session.getAttribute("successMessage") %>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= session.getAttribute("errorMessage") %>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <div class="messages-container">
         <%
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT m.*, mem.prenom, mem.nom FROM messages m " +
                 "LEFT JOIN members mem ON m.sender_id = mem.id " +
                 "WHERE m.receiver_id = ? " +
                 "ORDER BY m.is_read ASC, m.created_at DESC";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, memberId);
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.isBeforeFirst()) {
                // Aucun message
%>
                            <div class="empty-state">
                                <i class="fas fa-inbox"></i>
                                <h4>Aucun message</h4>
                                <p>Votre boîte de réception est vide.</p>
                            </div>
            <%
                        } else {
                            while (rs.next()) {
                                String unreadClass = rs.getInt("is_read") == 0 ? "unread" : "";
                                String senderName = rs.getInt("sender_id") == 0 ? "Système" : 
                                                  rs.getString("prenom") + " " + rs.getString("nom");
            %>
                            <div class="message <%= unreadClass %>">
                                <div class="message-header">
                                    <div class="message-title">
                                        <%= rs.getString("subject") %>
                                        <% if (rs.getInt("is_read") == 0) { %>
                                            <span class="badge badge-success">Nouveau</span>
                                        <% } %>
                                    </div>
                                    <div class="message-date">
                                        <i class="far fa-clock"></i> <%= rs.getTimestamp("created_at") %>
                                    </div>
                                </div>
                                <div class="message-content">
                                    <p><strong>De:</strong> <%= senderName %></p>
                                    <p><%= rs.getString("content") %></p>
                                </div>
                                <div class="message-actions">
                                    <% if (rs.getInt("is_read") == 0) { %>
                                        <form method="post" style="margin: 0;">
                                            <input type="hidden" name="message_id" value="<%= rs.getInt("id") %>">
                                            <button type="submit" name="mark_as_read" class="btn btn-primary">
                                                <i class="fas fa-check"></i> Marquer comme lu
                                            </button>
                                        </form>
                                    <% } %>
                                    
                                    <% if (rs.getInt("related_payment_id") != 0) { %>
                                        <a href="payment_details.jsp?id=<%= rs.getInt("related_payment_id") %>" class="btn btn-success">
                                            <i class="fas fa-receipt"></i> Voir paiement
                                        </a>
                                    <% } %>
                                </div>
                            </div>
            <%
                            }
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            %>
        </div>
    </div>

    <script>
        // Animation pour les messages
        document.querySelectorAll('.message').forEach(message => {
            message.addEventListener('mouseenter', () => {
                message.style.transform = 'translateX(5px)';
            });
            
            message.addEventListener('mouseleave', () => {
                message.style.transform = '';
            });
        });
    </script>
</body>
</html>