<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page session="true" %>
<%
    // Vérifier si l'utilisateur est connecté
    Integer memberId = (Integer) session.getAttribute("memberId");
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Récupérer l'ID du paiement depuis l'URL
    int paymentId = 0;
    try {
        paymentId = Integer.parseInt(request.getParameter("id"));
    } catch (NumberFormatException e) {
        response.sendRedirect("messages.jsp");
        return;
    }
    
    // Variables pour stocker les détails du paiement
    double montant = 0;
    String paymentDate = "";
    String paymentMethod = "";
    String status = "";
    String description = "";
    int relatedMemberId = 0;
    String memberName = "";
    
    try (Connection conn = DBConnection.getConnection()) {
        // Récupérer les détails du paiement
        String sql = "SELECT p.*, m.prenom, m.nom FROM paiements p " +
                     "LEFT JOIN members m ON p.member_id = m.id " +
                     "WHERE p.id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, paymentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                	montant = rs.getDouble("montant");
                    paymentDate = rs.getTimestamp("date_paiement").toString();
                    paymentMethod = rs.getString("methode_paiement");
                    status = rs.getString("statut");
                   
                    relatedMemberId = rs.getInt("member_id");
                    memberName = rs.getString("prenom") + " " + rs.getString("nom");
                } else {
                    // Paiement non trouvé
                    session.setAttribute("errorMessage", "Paiement introuvable.");
                    response.sendRedirect("messages.jsp");
                    return;
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur: " + e.getMessage());
    }
%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Détails du paiement - Tontine GO-FAR</title>
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
        
        .payment-details {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 30px;
            max-width: 800px;
            margin: 0 auto;
        }
        
        .detail-row {
            display: flex;
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        .detail-label {
            width: 200px;
            font-weight: 500;
            color: #7f8c8d;
        }
        
        .detail-value {
            flex: 1;
            color: #2c3e50;
        }
        
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
        }
        
        .status-pending {
            background: #fff4e5;
            color: #f39c12;
        }
        
        .status-completed {
            background: #e8f5e9;
            color: #27ae60;
        }
        
        .status-failed {
            background: #ffebee;
            color: #e74c3c;
        }
        
        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            text-decoration: none;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-primary:hover {
            background: #2980b9;
        }
        
        .btn-back {
            background: #95a5a6;
            color: white;
            margin-bottom: 20px;
        }
        
        .btn-back:hover {
            background: #7f8c8d;
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
        
        @media (max-width: 768px) {
            .content {
                margin-left: 0;
                width: 100%;
            }
            
            .detail-row {
                flex-direction: column;
            }
            
            .detail-label {
                width: 100%;
                margin-bottom: 5px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <a href="messages.jsp" class="btn btn-back">
            <i class="fas fa-arrow-left"></i> Retour aux paiements
        </a>
        
        <h2><i class="fas fa-receipt"></i> Détails du paiement</h2>
        
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
        
        <div class="payment-details">
            <div class="detail-row">
                <div class="detail-label">ID du paiement:</div>
                <div class="detail-value">#<%= paymentId %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Membre:</div>
                <div class="detail-value"><%= memberName %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Montant:</div>
                <div class="detail-value"><%= String.format("%,.2f", montant) %> FCFA</div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Date du paiement:</div>
                <div class="detail-value"><%= paymentDate %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Méthode de paiement:</div>
                <div class="detail-value"><%= paymentMethod %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Statut:</div>
                <div class="detail-value">
                    <span class="status status-<%= status.toLowerCase() %>">
                        <%= status %>
                    </span>
                </div>
            </div>
          
            
            <% if (isAdmin != null && isAdmin) { %>
                <div class="detail-row" style="border-bottom: none; padding-bottom: 0;">
                    <div class="detail-label">Actions:</div>
                    <div class="detail-value">
                        <a href="edit_payment.jsp?id=<%= paymentId %>" class="btn btn-primary">
                            <i class="fas fa-edit"></i> Modifier
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <script>
        // Formater la date pour un meilleur affichage
        document.addEventListener('DOMContentLoaded', function() {
            const dateElements = document.querySelectorAll('.detail-value');
            dateElements.forEach(el => {
                if (el.textContent.match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)) {
                    const date = new Date(el.textContent);
                    el.textContent = date.toLocaleString('fr-FR', {
                        day: '2-digit',
                        month: '2-digit',
                        year: 'numeric',
                        hour: '2-digit',
                        minute: '2-digit'
                    });
                }
            });
        });
    </script>
</body>
</html>