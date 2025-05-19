<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page session="true" %>

<%
    // Vérifier si l'utilisateur est admin et connecté
    Integer memberId = (Integer) session.getAttribute("memberId");
    String memberRole = (String) session.getAttribute("role");
    if (memberId == null || !"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Traitement des actions admin
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        int paymentId = 0;
        try {
            paymentId = Integer.parseInt(request.getParameter("payment_id"));
        } catch (NumberFormatException e) {
            // Ignorer
        }
        
        try (Connection conn = DBConnection.getConnection()) {
            if ("validate".equals(action) && paymentId > 0) {
                String sql = "UPDATE paiements SET statut = 'COMPLETED' WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, paymentId);
                    ps.executeUpdate();
                    session.setAttribute("successMessage", "Paiement validé avec succès.");
                }
            } else if ("reject".equals(action) && paymentId > 0) {
                String sql = "UPDATE paiements SET statut = 'REJECTED' WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, paymentId);
                    ps.executeUpdate();
                    session.setAttribute("successMessage", "Paiement rejeté avec succès.");
                }
            } else if ("remind".equals(action)) {
                int tontineId = Integer.parseInt(request.getParameter("tontine_id"));
                String moisAnnee = request.getParameter("mois_annee");
                
                // Ici, vous pourriez implémenter un système d'envoi de rappels
                // Par exemple, enregistrer dans une table de notifications
                session.setAttribute("successMessage", "Rappels envoyés aux membres pour " + moisAnnee);
            }
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
        }
        
        response.sendRedirect("gerecotisation.jsp");
        return;
    }
    
    // Récupérer le mois/année courant pour les filtres
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM");
    String currentMonthYear = sdf.format(new java.util.Date());
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Cotisations - Admin - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* (Conserver les styles CSS existants) */
         * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }
    
    :root {
        --primary-color: #27ae60;
        --primary-light: #2ecc71;
        --primary-dark: #219653;
        --secondary-color: #f1f8e9;
        --white: #ffffff;
        --light-gray: #f5f5f5;
        --dark-gray: #333333;
        --gold-accent: #f1c40f;
        --shadow: 0 10px 30px rgba(39, 174, 96, 0.15);
    }
    
 body {
    background: url('OIP (9).jpeg') no-repeat center center/cover;
    margin: 0;
    display: flex;
    min-height: 100vh;
    width: 100vw;
    overflow: hidden;
}
    /* Sidebar - Menu latéral élégant */
    .sidebar {
        width: 280px;
        background: linear-gradient(165deg, var(--primary-dark), var(--primary-color));
        color: var(--white);
        height: 100vh;
        position: fixed;
        z-index: 1000;
        box-shadow: 5px 0 25px rgba(0,0,0,0.1);
        padding-top: 30px;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    
    .sidebar-header {
        text-align: center;
        padding: 0 20px 30px;
        border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    
    .sidebar-header h3 {
        font-weight: 600;
        font-size: 20px;
        margin-top: 15px;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px;
    }
    
    .sidebar-header h3 i {
        color: var(--gold-accent);
        font-size: 24px;
    }
    
    /* ===== CONTENT AREA ===== */
.content {
    flex: 1;
    padding: 40px;
    overflow-y: auto;
    background: rgba(255, 255, 255, 0.95);
    border-top-left-radius: 20px;
    height: 100vh;
    width: 100%;
     transition: all 0.4s ease;
}

    
    /* En-tête */
    .header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 40px;
        padding-bottom: 20px;
        border-bottom: 1px solid rgba(0,0,0,0.08);
    }
    
    .header h2 {
        color: var(--primary-dark);
        font-size: 28px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 15px;
    }
    
    .header h2 i {
        color: var(--primary-color);
        font-size: 32px;
        text-shadow: 0 3px 10px rgba(39, 174, 96, 0.3);
    }
    
    /* Cartes élégantes */
    .card {
        background: var(--white);
        border-radius: 16px;
        box-shadow: var(--shadow);
        padding: 30px;
        margin-bottom: 30px;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
        position: relative;
        overflow: hidden;
        border: none;
    }
    
    .card:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(39, 174, 96, 0.2);
    }
    
    .card:before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 5px;
        height: 100%;
        background: linear-gradient(to bottom, var(--primary-light), var(--primary-dark));
    }
    
    .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 25px;
        padding-bottom: 15px;
        border-bottom: 1px solid rgba(0,0,0,0.05);
    }
    
    .card-title {
        font-size: 22px;
        color: var(--primary-dark);
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .card-title i {
        color: var(--primary-color);
        font-size: 28px;
        width: 50px;
        height: 50px;
        background: rgba(39, 174, 96, 0.1);
        border-radius: 50%;
        display: inline-flex;
        align-items: center;
        justify-content: center;
    }
    
    /* Badges stylisés */
    .badge {
        padding: 8px 18px;
        border-radius: 50px;
        font-size: 14px;
        font-weight: 500;
        letter-spacing: 0.5px;
        text-transform: uppercase;
    }
    
    .badge-success {
        background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
        color: var(--white);
        box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
    }
    
    .badge-warning {
        background: linear-gradient(135deg, #f39c12, #f1c40f);
        color: var(--white);
        box-shadow: 0 4px 15px rgba(243, 156, 18, 0.3);
    }
    
    .badge-danger {
        background: linear-gradient(135deg, #e74c3c, #c0392b);
        color: var(--white);
        box-shadow: 0 4px 15px rgba(231, 76, 60, 0.3);
    }
    
    .badge-info {
        background: linear-gradient(135deg, #3498db, #2980b9);
        color: var(--white);
        box-shadow: 0 4px 15px rgba(52, 152, 219, 0.3);
    }
    
    /* Boutons luxueux */
    .btn {
        padding: 12px 25px;
        border-radius: 8px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.4s;
        border: none;
        display: inline-flex;
        align-items: center;
        gap: 12px;
        font-size: 15px;
        letter-spacing: 0.5px;
        position: relative;
        overflow: hidden;
        z-index: 1;
    }
    
    .btn:before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 0;
        height: 100%;
        background-color: rgba(255,255,255,0.2);
        transition: all 0.4s;
        z-index: -1;
    }
    
    .btn:hover:before {
        width: 100%;
    }
    
    .btn i {
        font-size: 18px;
    }
    
    .btn-sm {
        padding: 8px 16px;
        font-size: 14px;
    }
    
    .btn-success {
        background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
        color: var(--white);
        box-shadow: 0 5px 20px rgba(39, 174, 96, 0.3);
    }
    
    .btn-success:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(39, 174, 96, 0.4);
    }
    
    .btn-warning {
        background: linear-gradient(135deg, #f39c12, #f1c40f);
        color: var(--white);
        box-shadow: 0 5px 20px rgba(243, 156, 18, 0.3);
    }
    
    .btn-warning:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(243, 156, 18, 0.4);
    }
    
    .btn-danger {
        background: linear-gradient(135deg, #e74c3c, #c0392b);
        color: var(--white);
        box-shadow: 0 5px 20px rgba(231, 76, 60, 0.3);
    }
    
    .btn-danger:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(231, 76, 60, 0.4);
    }
    
    .btn-info {
        background: linear-gradient(135deg, #3498db, #2980b9);
        color: var(--white);
        box-shadow: 0 5px 20px rgba(52, 152, 219, 0.3);
    }
    
    .btn-info:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(52, 152, 219, 0.4);
    }
    
    /* Tableaux élégants */
    .table-responsive {
        overflow-x: auto;
        margin-top: 25px;
        border-radius: 12px;
        box-shadow: 0 2px 30px rgba(0,0,0,0.05);
    }
    
    .table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0;
        background: var(--white);
        border-radius: 12px;
        overflow: hidden;
    }
    
    .table th {
        background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
        color: var(--white);
        padding: 18px;
        text-align: left;
        font-weight: 500;
        font-size: 15px;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .table th:first-child {
        border-top-left-radius: 12px;
    }
    
    .table th:last-child {
        border-top-right-radius: 12px;
    }
    
    .table td {
        padding: 16px 18px;
        border-bottom: 1px solid rgba(0,0,0,0.05);
        color: var(--dark-gray);
        vertical-align: middle;
    }
    
    .table tr:last-child td {
        border-bottom: none;
    }
    
    .table tr:hover {
        background: rgba(39, 174, 96, 0.03);
    }
    
    .table tr:hover td {
        transform: translateX(5px);
        transition: all 0.3s ease;
    }
    
    /* Statuts avec icônes FA */
    .status {
        display: flex;
        align-items: center;
        gap: 8px;
        font-weight: 500;
    }
    
    .status i {
        font-size: 18px;
    }
    
    .status-paid {
        color: var(--primary-dark);
    }
    
    .status-pending {
        color: #f39c12;
    }
    
    .status-rejected {
        color: #e74c3c;
    }
    
    /* Alertes stylisées */
    .alert {
        padding: 18px 25px;
        border-radius: 12px;
        margin-bottom: 30px;
        display: flex;
        align-items: center;
        gap: 18px;
        background: var(--white);
        box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        border-left: 5px solid;
        animation: slideIn 0.6s ease-out;
    }
    
    .alert i {
        font-size: 28px;
    }
    
    .alert-success {
        border-left-color: var(--primary-dark);
        color: var(--primary-dark);
        background: rgba(39, 174, 96, 0.1);
    }
    
    .alert-error {
        border-left-color: #e74c3c;
        color: #e74c3c;
        background: rgba(231, 76, 60, 0.1);
    }
    
    .alert-info {
        border-left-color: #3498db;
        color: #3498db;
        background: rgba(52, 152, 219, 0.1);
    }
    
    /* Cartes de synthèse */
    .summary-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 25px;
        margin-bottom: 30px;
    }
    
    .summary-card {
        background: var(--white);
        border-radius: 14px;
        padding: 25px;
        box-shadow: var(--shadow);
        display: flex;
        align-items: center;
        gap: 20px;
        transition: all 0.4s;
        border: 1px solid rgba(0,0,0,0.03);
    }
    
    .summary-card:hover {
        transform: translateY(-8px);
        box-shadow: 0 15px 35px rgba(39, 174, 96, 0.2);
    }
    
    .summary-icon {
        width: 70px;
        height: 70px;
        border-radius: 18px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 30px;
        color: var(--white);
        flex-shrink: 0;
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }
    
    .icon-success {
        background: linear-gradient(135deg, var(--primary-light), var(--primary-dark));
    }
    
    .icon-warning {
        background: linear-gradient(135deg, #f39c12, #f1c40f);
    }
    
    .icon-danger {
        background: linear-gradient(135deg, #e74c3c, #c0392b);
    }
    
    .icon-info {
        background: linear-gradient(135deg, #3498db, #2980b9);
    }
    
    .summary-content h3 {
        font-size: 16px;
        color: #7f8c8d;
        margin-bottom: 8px;
        font-weight: 500;
    }
    
    .summary-content p {
        font-size: 26px;
        font-weight: 600;
        color: var(--dark-gray);
        line-height: 1.2;
    }
    
    .summary-content .subtext {
        font-size: 14px;
        color: #95a5a6;
        margin-top: 5px;
        font-weight: 400;
    }
    
    /* État vide */
    .empty-state {
        text-align: center;
        padding: 50px 30px;
        color: #95a5a6;
        background: var(--white);
        border-radius: 14px;
        box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        margin: 20px 0;
    }
    
    .empty-state i {
        font-size: 70px;
        margin-bottom: 20px;
        color: #bdc3c7;
        opacity: 0.7;
    }
    
    .empty-state h4 {
        font-size: 22px;
        margin-bottom: 15px;
        color: var(--dark-gray);
    }
    
    .empty-state p {
        font-size: 16px;
        max-width: 500px;
        margin: 0 auto;
        line-height: 1.6;
    }
    
    /* Filtres */
    .filter-container {
        display: flex;
        gap: 15px;
        margin-bottom: 25px;
        align-items: center;
        flex-wrap: wrap;
    }
    
    .filter-container select, 
    .filter-container input {
        padding: 12px 18px;
        border-radius: 8px;
        border: 1px solid rgba(0,0,0,0.1);
        background: var(--white);
        font-size: 15px;
        min-width: 200px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.03);
        transition: all 0.3s;
    }
    
    .filter-container select:focus, 
    .filter-container input:focus {
        outline: none;
        border-color: var(--primary-light);
        box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
    }
    
    /* Animations */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
    }
    
    .animated {
        animation: fadeIn 0.8s ease-out forwards;
        opacity: 0;
    }
    
    .delay-1 { animation-delay: 0.2s; }
    .delay-2 { animation-delay: 0.4s; }
    .delay-3 { animation-delay: 0.6s; }
    
    /* Effet de vague sur les boutons */
    .wave-effect {
        position: relative;
        overflow: hidden;
    }
    
    .wave-effect:after {
        content: "";
        position: absolute;
        top: 50%;
        left: 50%;
        width: 5px;
        height: 5px;
        background: rgba(255, 255, 255, 0.5);
        opacity: 0;
        border-radius: 100%;
        transform: scale(1, 1) translate(-50%);
        transform-origin: 50% 50%;
    }
    
    .wave-effect:focus:after {
        animation: wave-effect 0.6s ease-out;
    }
    
    @keyframes wave-effect {
        0% {
            transform: scale(0, 0);
            opacity: 0.5;
        }
        100% {
            transform: scale(50, 50);
            opacity: 0;
        }
    }
    
    /* Responsive */
    @media (max-width: 992px) {
        .sidebar {
            transform: translateX(-100%);
        }
        
        .sidebar.active {
            transform: translateX(0);
        }
        
        .content {
            margin-left: 0;
            padding: 25px;
        }
        
        .summary-cards {
            grid-template-columns: 1fr 1fr;
        }
    }
    
    @media (max-width: 768px) {
        .summary-cards {
            grid-template-columns: 1fr;
        }
        
        .filter-container {
            flex-direction: column;
            align-items: flex-start;
        }
        
        .filter-container select, 
        .filter-container input {
            width: 100%;
        }
    }
        
        .filter-container {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: center;
        }
        
        .filter-container select, .filter-container input {
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px solid #ddd;
            background: white;
        }
        
        .filter-container button {
            padding: 8px 15px;
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="header animated">
            <h2><i class="fas fa-user-shield"></i> Gestion des Cotisations - Admin</h2>
        </div>
        
        <!-- Affichage des messages -->
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success animated">
                <i class="fas fa-check-circle"></i>
                <div><%= session.getAttribute("successMessage") %></div>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error animated">
                <i class="fas fa-exclamation-circle"></i>
                <div><%= session.getAttribute("errorMessage") %></div>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <!-- Statistiques -->
        <div class="card animated delay-1">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-chart-bar"></i> Statistiques des Cotisations
                </div>
            </div>
            
            <div class="summary-cards">
                <div class="summary-card">
                    <div class="summary-icon icon-success">
                        <i class="fas fa-check"></i>
                    </div>
                    <div class="summary-content">
                        <h3>Dernières Cotisations Payées</h3>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT p.mois_annee, m.prenom, m.nom " +
                                         "FROM paiements p " +
                                         "JOIN users m ON p.member_id = m.id " +
                                         "WHERE p.type_paiement = 'COTISATION' AND p.statut = 'COMPLETED' " +
                                         "ORDER BY p.date_paiement DESC LIMIT 5";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        out.print("<p>" + rs.getString("prenom") + " " + rs.getString("nom") + 
                                                 " (" + rs.getString("mois_annee") + ")</p>");
                                        while (rs.next()) {
                                            out.print("<p style='margin-top:5px;font-size:14px;'>" + 
                                                     rs.getString("prenom") + " " + rs.getString("nom") + 
                                                     " (" + rs.getString("mois_annee") + ")</p>");
                                        }
                                    } else {
                                        out.print("<p>Aucune cotisation</p>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.print("<p>Erreur</p>");
                        }
                        %>
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-icon icon-warning">
                        <i class="fas fa-clock"></i>
                    </div>
                    <div class="summary-content">
                        <h3>En Attente</h3>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT COUNT(*) as count FROM paiements WHERE type_paiement = 'COTISATION' AND statut = 'PENDING'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        out.print("<p>" + rs.getInt("count") + "</p>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.print("<p>0</p>");
                        }
                        %>
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-icon icon-danger">
                        <i class="fas fa-times"></i>
                    </div>
                    <div class="summary-content">
                        <h3>Membres en Retard (<%= currentMonthYear %>)</h3>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT m.prenom, m.nom, t.nom as tontine " +
                                        "FROM tontine_adherents1 ta " +
                                        "JOIN users m ON ta.member_id = m.id " +
                                        "JOIN tontines t ON ta.tontine_id = t.id " +
                                        "WHERE NOT EXISTS (" +
                                        "  SELECT 1 FROM paiements p " +
                                        "  WHERE p.member_id = ta.member_id AND p.tontine_id = ta.tontine_id " +
                                        "  AND p.type_paiement = 'COTISATION' " +
                                        "  AND p.mois_annee = ? AND p.statut = 'COMPLETED') " +
                                        "LIMIT 3";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                ps.setString(1, currentMonthYear);
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        out.print("<p>" + rs.getString("prenom") + " " + rs.getString("nom") + 
                                                 " (" + rs.getString("tontine") + ")</p>");
                                        while (rs.next()) {
                                            out.print("<p style='margin-top:5px;font-size:14px;'>" + 
                                                     rs.getString("prenom") + " " + rs.getString("nom") + 
                                                     " (" + rs.getString("tontine") + ")</p>");
                                        }
                                    } else {
                                        out.print("<p>Tous à jour</p>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.print("<p>Erreur</p>");
                        }
                        %>
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-icon icon-info">
                        <i class="fas fa-money-bill-wave"></i>
                    </div>
                    <div class="summary-content">
                        <h3>Montant Total</h3>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT SUM(montant) as total FROM paiements WHERE type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        out.print("<p>" + (rs.getBigDecimal("total") != null ? 
                                            String.format("%,d", rs.getBigDecimal("total").intValue()) : "0") + " FCFA</p>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            out.print("<p>0 FCFA</p>");
                        }
                        %>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Envoyer des rappels -->
        <div class="card animated delay-2">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-bell"></i> Envoyer des Rappels
                </div>
            </div>
            
            <form method="post" style="margin-top: 15px;">
                <input type="hidden" name="action" value="remind">
                
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                    <div>
                        <label for="tontine_id" style="display: block; margin-bottom: 8px; color: #2c3e50; font-weight: 500;">Tontine</label>
                        <select id="tontine_id" name="tontine_id" class="form-control" required>
                            <option value="">Sélectionnez une tontine</option>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT id, nom FROM tontines WHERE etat = 'ACTIVE'";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                                            out.print("<option value='" + rs.getInt("id") + "'>" + rs.getString("nom") + "</option>");
                                        }
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                            %>
                        </select>
                    </div>
                    
                    <div>
                        <label for="mois_annee" style="display: block; margin-bottom: 8px; color: #2c3e50; font-weight: 500;">Mois/Année</label>
                        <input type="month" id="mois_annee" name="mois_annee" class="form-control" required 
                               value="<%= currentMonthYear %>">
                    </div>
                </div>
                
                <button type="submit" class="btn btn-info" style="margin-top: 20px;">
                    <i class="fas fa-paper-plane"></i> Envoyer les rappels
                </button>
            </form>
        </div>
        
        <!-- Cotisations en attente de validation -->
        <div class="card animated delay-3">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-clock"></i> Cotisations en Attente
                </div>
            </div>
            
            <%
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT p.*, m.prenom, m.nom, t.nom as tontine_nom FROM paiements p " +
                            "JOIN users m ON p.member_id = m.id " +
                            "JOIN tontines t ON p.tontine_id = t.id " +
                            "WHERE p.type_paiement = 'COTISATION' AND p.statut = 'PENDING' " +
                            "ORDER BY p.date_paiement DESC";
                
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.isBeforeFirst()) {
            %>
                            <div class="empty-state">
                                <i class="fas fa-check-circle"></i>
                                <h4>Aucune cotisation en attente</h4>
                                <p>Toutes les cotisations ont été traitées.</p>
                            </div>
            <%
                        } else {
            %>
                            <div class="table-responsive">
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Membre</th>
                                            <th>Tontine</th>
                                            <th>Mois/Année</th>
                                            <th>Montant</th>
                                            <th>Date Paiement</th>
                                            <th>Mode</th>
                                            <th>Référence</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
            <%
                                    while (rs.next()) {
            %>
                                        <tr>
                                            <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                                            <td><%= rs.getString("tontine_nom") %></td>
                                            <td><%= rs.getString("mois_annee") %></td>
                                            <td><%= String.format("%,d", rs.getBigDecimal("montant").intValue()) %> FCFA</td>
                                            <td><%= rs.getDate("date_paiement") %></td>
                                            <td><%= rs.getString("mode_paiement") %></td>
                                            <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                            <td>
                                                <form method="post" style="display: inline;">
                                                    <input type="hidden" name="action" value="validate">
                                                    <input type="hidden" name="payment_id" value="<%= rs.getInt("id") %>">
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        <i class="fas fa-check"></i> Valider
                                                    </button>
                                                </form>
                                                <form method="post" style="display: inline; margin-left: 5px;">
                                                    <input type="hidden" name="action" value="reject">
                                                    <input type="hidden" name="payment_id" value="<%= rs.getInt("id") %>">
                                                    <button type="submit" class="btn btn-danger btn-sm">
                                                        <i class="fas fa-times"></i> Rejeter
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
            <%
                                    }
            %>
                                    </tbody>
                                </table>
                            </div>
            <%
                        }
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            %>
        </div>
        
        <!-- Liste complète des cotisations -->
        <div class="card animated delay-3">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-list"></i> Toutes les Cotisations
                </div>
                <div class="filter-container">
                    <select id="filter-tontine">
                        <option value="">Toutes les tontines</option>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT id, nom FROM tontines WHERE etat = 'ACTIVE'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                                        out.print("<option value='" + rs.getInt("id") + "'>" + rs.getString("nom") + "</option>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                    <input type="month" id="filter-month" value="<%= currentMonthYear %>">
                    <button class="btn btn-info" onclick="filterPayments()">
                        <i class="fas fa-filter"></i> Filtrer
                    </button>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Membre</th>
                            <th>Tontine</th>
                            <th>Mois/Année</th>
                            <th>Montant</th>
                            <th>Date Paiement</th>
                            <th>Mode</th>
                            <th>Référence</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        // Afficher d'abord les cotisations existantes
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT p.*, m.prenom, m.nom, t.nom as tontine_nom FROM paiements p " +
                                        "JOIN users m ON p.member_id = m.id " +
                                        "JOIN tontines t ON p.tontine_id = t.id " +
                                        "WHERE p.type_paiement = 'COTISATION' " +
                                        "ORDER BY p.date_paiement DESC LIMIT 50";
                            
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                                        String statusClass = "status-paid";
                                        if ("PENDING".equals(rs.getString("statut"))) {
                                            statusClass = "status-pending";
                                        } else if ("REJECTED".equals(rs.getString("statut"))) {
                                            statusClass = "status-rejected";
                                        }
                        %>
                                        <tr>
                                            <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                                            <td><%= rs.getString("tontine_nom") %></td>
                                            <td><%= rs.getString("mois_annee") %></td>
                                            <td><%= String.format("%,d", rs.getBigDecimal("montant").intValue()) %> FCFA</td>
                                            <td><%= rs.getDate("date_paiement") %></td>
                                            <td><%= rs.getString("mode_paiement") %></td>
                                            <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                            <td class="<%= statusClass %>">
                                                <i class="fas <%= "COMPLETED".equals(rs.getString("statut")) ? "fa-check-circle" : 
                                                               "PENDING".equals(rs.getString("statut")) ? "fa-clock" : "fa-times-circle" %>"></i>
                                                <%= rs.getString("statut") %>
                                            </td>
                                        </tr>
                        <%
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
        
        <!-- Membres n'ayant pas encore cotisé -->
        <div class="card animated delay-3">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-user-times"></i> Membres en Retard de Paiement
                </div>
                <div class="filter-container">
                    <select id="filter-tontine-retard">
                        <option value="">Toutes les tontines</option>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT id, nom FROM tontines WHERE etat = 'ACTIVE'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                                        out.print("<option value='" + rs.getInt("id") + "'>" + rs.getString("nom") + "</option>");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </select>
                    <input type="month" id="filter-month-retard" value="<%= currentMonthYear %>">
                    <button class="btn btn-info" onclick="filterRetards()">
                        <i class="fas fa-filter"></i> Filtrer
                    </button>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Membre</th>
                            <th>Tontine</th>
                            <th>Mois/Année</th>
                            <th>Statut</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT m.id as member_id, m.prenom, m.nom, t.id as tontine_id, t.nom as tontine_nom " +
                                       "FROM tontine_adherents1 ta " +
                                       "JOIN users m ON ta.member_id = m.id " +
                                       "JOIN tontines t ON ta.tontine_id = t.id " +
                                       "WHERE NOT EXISTS (" +
                                       "  SELECT 1 FROM paiements p " +
                                       "  WHERE p.member_id = ta.member_id AND p.tontine_id = ta.tontine_id " +
                                       "  AND p.type_paiement = 'COTISATION' " +
                                       "  AND p.mois_annee = ? AND p.statut = 'COMPLETED') " +
                                       "ORDER BY t.nom, m.nom";
                            
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                ps.setString(1, currentMonthYear);
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                        %>
                                        <tr>
                                            <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                                            <td><%= rs.getString("tontine_nom") %></td>
                                            <td><%= currentMonthYear %></td>
                                            <td class="status-rejected">
                                                <i class="fas fa-times-circle"></i> En retard
                                            </td>
                                            <td>
                                                <button class="btn btn-warning btn-sm" 
                                                        onclick="sendReminder(<%= rs.getInt("member_id") %>, <%= rs.getInt("tontine_id") %>, '<%= currentMonthYear %>')">
                                                    <i class="fas fa-bell"></i> Rappel
                                                </button>
                                            </td>
                                        </tr>
                        <%
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Menu toggle
        document.getElementById('menuToggle').addEventListener('click', function() {
            document.querySelector('.sidebar').classList.toggle('active');
        });
        
        // Confirmation avant actions admin
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                const action = this.querySelector('[name="action"]').value;
                let message = "";
                
                if (action === "validate") {
                    message = "Confirmez-vous la validation de cette cotisation ?";
                } else if (action === "reject") {
                    message = "Confirmez-vous le rejet de cette cotisation ?";
                } else if (action === "remind") {
                    message = "Confirmez-vous l'envoi des rappels aux membres ?";
                }
                
                if (message && !confirm(message)) {
                    e.preventDefault();
                }
            });
        });
        
        // Animation au chargement
        document.addEventListener('DOMContentLoaded', function() {
            const elements = document.querySelectorAll('.animated');
            elements.forEach((el, index) => {
                el.style.opacity = '0';
            });
            
            setTimeout(() => {
                elements.forEach((el, index) => {
                    el.style.opacity = '1';
                });
            }, 100);
        });
        
        // Gestion des sous-menus
        document.getElementById('tontineMenu').addEventListener('click', function(e) {
            e.preventDefault();
            this.classList.toggle('active');
            document.getElementById('tontineSubmenu').classList.toggle('active');
        });
        
        // Fonction de filtrage
        function filterPayments() {
            const tontineId = document.getElementById('filter-tontine').value;
            const month = document.getElementById('filter-month').value;
            // Implémenter la logique de filtrage ici (AJAX ou rechargement de la page)
            alert('Filtrage des cotisations - Tontine: ' + tontineId + ', Mois: ' + month);
        }
        
        function filterRetards() {
            const tontineId = document.getElementById('filter-tontine-retard').value;
            const month = document.getElementById('filter-month-retard').value;
            // Implémenter la logique de filtrage ici (AJAX ou rechargement de la page)
            alert('Filtrage des retards - Tontine: ' + tontineId + ', Mois: ' + month);
        }
        
        function sendReminder(memberId, tontineId, monthYear) {
            if (confirm('Envoyer un rappel à ce membre pour la cotisation du ' + monthYear + ' ?')) {
                // Implémenter l'envoi du rappel (AJAX)
                alert('Rappel envoyé au membre ID: ' + memberId + ' pour la tontine ID: ' + tontineId);
            }
        }
    </script>
</body>
</html>