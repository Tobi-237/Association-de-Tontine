<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page session="true" %>

<%
    // Vérification du rôle admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Formats
		    Locale frenchLocale = Locale.forLanguageTag("fr-FR");
		NumberFormat nf = NumberFormat.getInstance(frenchLocale);
		nf.setMinimumFractionDigits(2);
		nf.setMaximumFractionDigits(2);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    // Récupération des montants totaux des versements par type de caisse
    BigDecimal soldeMutuelle = BigDecimal.ZERO;
    BigDecimal soldeScolaire = BigDecimal.ZERO;
    BigDecimal soldePunition = BigDecimal.ZERO;
    
    try (Connection conn = DBConnection.getConnection()) {
        // Requête pour sommer les montants des versements validés par type de caisse
        String sql = "SELECT c.type_caisse, SUM(v.montant) as total " +
                     "FROM versements v " +
                     "JOIN caisses c ON v.caisse_id = c.id " +
                     "WHERE v.statut = 'VALIDATED' " +
                     "GROUP BY c.type_caisse";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String type = rs.getString("type_caisse");
                    BigDecimal total = rs.getBigDecimal("total");
                    if (total != null) {
                        if ("MUTUELLE".equals(type)) soldeMutuelle = total;
                        else if ("SCOLAIRE".equals(type)) soldeScolaire = total;
                        else if ("PUNITION".equals(type)) soldePunition = total;
                    }
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        // Gérer l'erreur (optionnel)
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Caisses | Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #27ae60;
            --primary-light: #2ecc71;
            --primary-dark: #219653;
            --white: #ffffff;
            --light-bg: #f5f7fa;
            --dark-text: #2c3e50;
            --light-text: #7f8c8d;
            --success: #27ae60;
            --warning: #f39c12;
            --danger: #e74c3c;
            --info: #3498db;
            --purple: #9b59b6;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, var(--light-bg) 0%, #e4efe9 100%);
            min-height: 100vh;
            overflow-x: hidden;
            color: var(--dark-text);
        }
        
        .sidebar {
            width: 280px;
            background: linear-gradient(to bottom, #2c3e50, #1a252f);
            color: var(--white);
            height: 100vh;
            position: fixed;
            z-index: 1000;
            box-shadow: 5px 0 25px rgba(0,0,0,0.1);
        }
        
        .content {
            margin-left: 280px;
            padding: 40px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .header h2 {
            font-size: 32px;
            font-weight: 600;
            position: relative;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .header h2:after {
            content: "";
            position: absolute;
            bottom: -12px;
            left: 0;
            width: 80px;
            height: 5px;
            background: linear-gradient(to right, var(--primary-color), var(--primary-light));
            border-radius: 3px;
        }
        
         .card {
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 40px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
            position: relative;
            overflow: hidden;
        }
        
        .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.15);
        }
        
        .card:before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(to bottom, var(--primary-color), var(--primary-light));
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }
        
        .card-title {
            font-size: 24px;
            color: var(--dark-text);
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .card-title i {
            color: var(--primary-color);
            font-size: 28px;
        }
        
        /* Stats Cards */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .stat-card {
            background: var(--white);
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: all 0.3s;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.12);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: var(--white);
            flex-shrink: 0;
        }
        
        .icon-mutuelle {
            background: linear-gradient(135deg, #3498db, #2980b9);
        }
        
        .icon-scolaire {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
        }
        
        .icon-punition {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
        }
        
        .stat-content h3 {
            font-size: 16px;
            color: var(--light-text);
            margin-bottom: 5px;
            font-weight: 500;
        }
        
        .stat-content p {
            font-size: 28px;
            font-weight: 700;
            color: var(--dark-text);
        }
        
        /* Table Styles */
        .table-responsive {
            overflow-x: auto;
            margin-top: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 25px rgba(0,0,0,0.05);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            background: var(--white);
            border-radius: 12px;
            overflow: hidden;
        }
        
        .table th {
            background: linear-gradient(to right, var(--primary-color), var(--primary-light));
            color: var(--white);
            padding: 18px;
            text-align: left;
            font-weight: 500;
            font-size: 15px;
        }
        
        .table td {
            padding: 15px 18px;
            border-bottom: 1px solid #eee;
            color: var(--dark-text);
            font-size: 14px;
        }
        
        .table tr:last-child td {
            border-bottom: none;
        }
        
        .table tr:hover {
            background: rgba(39, 174, 96, 0.05);
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 5px;
        }
        
        .badge-success {
            background: rgba(39, 174, 96, 0.1);
            color: var(--success);
        }
        
        .badge-warning {
            background: rgba(243, 156, 18, 0.1);
            color: var(--warning);
        }
        
        .badge-danger {
            background: rgba(231, 76, 60, 0.1);
            color: var(--danger);
        }
        
        .badge-info {
            background: rgba(52, 152, 219, 0.1);
            color: var(--info);
        }
        
        .badge-purple {
            background: rgba(155, 89, 182, 0.1);
            color: var(--purple);
        }
        
        /* Form Styles */
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark-text);
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 15px;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
            outline: none;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            font-size: 15px;
        }
        
        .btn i {
            margin-right: 8px;
        }
        
        .btn-primary {
            background: linear-gradient(to right, var(--primary-color), var(--primary-light));
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
        }
        
        .btn-danger {
            background: linear-gradient(to right, #e74c3c, #c0392b);
            color: white;
        }
        
        .btn-danger:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(231, 76, 60, 0.3);
        }
        
        .btn-info {
            background: linear-gradient(to right, #3498db, #2980b9);
            color: white;
        }
        
        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3);
        }
        
        .btn-purple {
            background: linear-gradient(to right, #9b59b6, #8e44ad);
            color: white;
        }
        
        .btn-purple:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(155, 89, 182, 0.3);
        }
        
        .tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 25px;
        }
        
        .tab {
            padding: 12px 20px;
            cursor: pointer;
            font-weight: 500;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }
        
        .tab.active {
            border-bottom-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .tab:hover:not(.active) {
            border-bottom-color: #ddd;
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 2000;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: white;
            border-radius: 12px;
            width: 90%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 50px rgba(0,0,0,0.2);
            animation: modalFadeIn 0.3s;
        }
        
        .modal-header {
            padding: 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-title {
            font-size: 20px;
            font-weight: 600;
            color: var(--dark-text);
        }
        
        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            cursor: pointer;
            color: var(--light-text);
        }
        
        .modal-body {
            padding: 20px;
        }
        
        .modal-footer {
            padding: 20px;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* File Input */
        .file-input {
            display: none;
        }
        
        .file-label {
            display: block;
            padding: 12px;
            border: 2px dashed #ddd;
            border-radius: 8px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .file-label:hover {
            border-color: var(--primary-color);
            background: rgba(39, 174, 96, 0.05);
        }
        
        .file-name {
            margin-top: 8px;
            font-size: 14px;
            color: var(--light-text);
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes float {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-10px); }
            100% { transform: translateY(0px); }
        }
        
        .animated {
            animation: fadeIn 0.8s ease-out forwards;
        }
        
        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }
        
        .floating {
            animation: float 6s ease-in-out infinite;
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
            
            .stats-container {
                grid-template-columns: 1fr;
            }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="header">
            <h2><i class="fas fa-piggy-bank"></i> Gestion des Caisses</h2>
        </div>
        
        <!-- Affichage des messages -->
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
        
        <!-- Cartes de statistiques -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon icon-mutuelle">
                    <i class="fas fa-heartbeat"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Mutuelle</h3>
                    <p><%= nf.format(soldeMutuelle) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon icon-scolaire">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Scolaire</h3>
                    <p><%= nf.format(soldeScolaire) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon icon-punition">
                    <i class="fas fa-gavel"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Punition</h3>
                    <p><%= nf.format(soldePunition) %> FCFA</p>
                </div>
            </div>
        </div>
        
        <!-- Onglets -->
        <div class="tabs">
            <div class="tab active" data-tab="mutuelle">Mutuelle</div>
            <div class="tab" data-tab="scolaire">Scolaire</div>
            <div class="tab" data-tab="punition">Punition</div>
            <div class="tab" data-tab="sinistres">Sinistres</div>
        </div>
        
        <!-- Contenu des onglets -->
        <div class="tab-content active" id="mutuelle">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-heartbeat"></i> Caisse Mutuelle
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Statut</th>
                                <th>Preuve</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                                  <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT v.*, m.nom, m.prenom " +
                                               "FROM versements v " +
                                               "JOIN members m ON v.member_id = m.member_id " +
                                               "WHERE v.caisse_id = (SELECT id FROM caisses WHERE type_caisse = 'MUTUELLE') " +
                                               "ORDER BY v.date_versement DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="7" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun versement trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                                                    String statutClass = "";
                                                    if ("VALIDATED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-success";
                                                    } else if ("PENDING".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-warning";
                                                    } else if ("REJECTED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-danger";
                                                    }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                                <td><%= rs.getString("methode_paiement") %></td>
                                                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (rs.getString("preuve") != null) { %>
                                                    <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-outline btn-sm">
                                                        <i class="fas fa-eye"></i> Voir
                                                    </a>
                                                    <% } else { %>
                                                    -
                                                    <% } %>
                                                </td>
                                            </tr>
                            <%
                                                }
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
        
        <!-- Onglet Scolaire -->
        <div class="tab-content" id="scolaire">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-graduation-cap"></i> Caisse Scolaire
                    </div>
                    <button class="btn btn-purple" type="button" id="calculInteretsBtn">
                        <i class="fas fa-calculator"></i> Calculer Intérêts
                    </button>
                </div>
                
                               <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Méthode</th>
                                <th>Référence</th>
                                <th>Statut</th>
                                <th>Preuve</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT v.*, m.nom, m.prenom " +
                                               "FROM versements v " +
                                               "JOIN members m ON v.member_id = m.member_id " +
                                               "WHERE v.caisse_id = (SELECT id FROM caisses WHERE type_caisse = 'SCOLAIRE') " +
                                               "ORDER BY v.date_versement DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="7" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun versement trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                                                    String statutClass = "";
                                                    if ("VALIDATED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-success";
                                                    } else if ("PENDING".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-warning";
                                                    } else if ("REJECTED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-danger";
                                                    }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                                <td><%= rs.getString("methode_paiement") %></td>
                                                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (rs.getString("preuve") != null) { %>
                                                    <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-outline btn-sm">
                                                        <i class="fas fa-eye"></i> Voir
                                                    </a>
                                                    <% } else { %>
                                                    -
                                                    <% } %>
                                                </td>
                                            </tr>
                            <%
                                                }
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
              <!-- Intérêts scolaires -->
                <div class="card-header" style="margin-top: 40px;">
                    <div class="card-title">
                        <i class="fas fa-percentage"></i> Intérêts Scolaires
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Année</th>
                                <th>Montant Initial</th>
                                <th>Taux</th>
                                <th>Intérêts</th>
                                <th>Date Calcul</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT i.*, m.nom, m.prenom " +
                                               "FROM interets_scolaires i " +
                                               "JOIN members m ON i.member_id = m.member_id " +
                                               "ORDER BY i.annee DESC, i.date_calcul DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="8" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun intérêt calculé</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                                                    String statutClass = "PENDING".equals(rs.getString("statut")) ? "badge-warning" : "badge-success";
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= rs.getString("annee") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_initial")) %> FCFA</td>
                                                <td><%= rs.getBigDecimal("taux_interet") %>%</td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_interet")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_calcul")) %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if ("PENDING".equals(rs.getString("statut"))) { %>
                                                    <button class="btn btn-success btn-sm" onclick="payerInteret(<%= rs.getInt("i.id") %>)">
                                                        <i class="fas fa-check"></i> Payer
                                                    </button>
                                                    <% } else { %>
                                                    <span class="badge badge-success">
                                                        <i class="fas fa-check"></i> Payé le <%= sdf.format(rs.getDate("date_paiement")) %>
                                                    </span>
                                                    <% } %>
                                                </td>
                                            </tr>
                            <%
                                                }
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
        
        <!-- Onglet Punition -->
        <div class="tab-content" id="punition">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-gavel"></i> Caisse Punition
                    </div>
                    <button class="btn btn-danger" id="addSanctionBtn">
                        <i class="fas fa-plus"></i> Nouvelle Sanction
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Type</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT s.*, m.nom, m.prenom FROM sanctions s " +
               "JOIN members m ON s.member_id = m.member_id " +
               "ORDER BY s.date_sanction DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.isBeforeFirst()) {
%>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                        <h4>Aucune sanction enregistrée</h4>
                    </td>
                </tr>
<%
            } else {
                while (rs.next()) {
                    String statutClass = rs.getString("statut").equals("PAID") ? "badge-success" : "badge-warning";
                    String typeSanction = "";
                    switch(rs.getString("type_sanction")) {
                        case "RETARD": typeSanction = "Retard"; break;
                        case "BAGARRE": typeSanction = "Bagarre"; break;
                        case "INJURE": typeSanction = "Injure"; break;
                        default: typeSanction = rs.getString("type_sanction");
                    }
%>
                <tr>
                    <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                    <td><%= typeSanction %></td>
                    <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                    <td><%= sdf.format(rs.getDate("date_sanction")) %></td>
                    <td>
                        <span class="badge <%= statutClass %>">
                            <%= rs.getString("statut") %>
                        </span>
                    </td>
                    <td>
                        <% if (!rs.getString("statut").equals("PAID")) { %>
                        <button class="btn btn-sm btn-success" 
                                onclick="validatePayment(<%= rs.getInt("id") %>, 'sanction')">
                            Valider Paiement
                        </button>
                        <% } %>
                    </td>
                </tr>
<%
                }
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
        
        <!-- Onglet Sinistres -->
        <div class="tab-content" id="sinistres">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-file-medical"></i> Gestion des Sinistres
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Type</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                           <%
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT s.*, m.nom, m.prenom FROM sinistres_mutuelle s " +
               "JOIN members m ON s.member_id = m.member_id " +
               "ORDER BY s.date_sinistre DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        try (ResultSet rs = ps.executeQuery()) {
            if (!rs.isBeforeFirst()) {
%>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 40px;">
                        <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                        <h4>Aucun sinistre enregistré</h4>
                    </td>
                </tr>
<%
            } else {
                while (rs.next()) {
                    String statutClass = "";
                    if ("APPROVED".equals(rs.getString("statut"))) {
                        statutClass = "badge-success";
                    } else if ("PENDING".equals(rs.getString("statut"))) {
                        statutClass = "badge-warning";
                    } else if ("REJECTED".equals(rs.getString("statut"))) {
                        statutClass = "badge-danger";
                    } else if ("PAID".equals(rs.getString("statut"))) {
                        statutClass = "badge-info";
                    }
                    
                    String typeSinistre = "";
                    switch(rs.getString("type_sinistre")) {
                        case "HOSPITALISATION": typeSinistre = "Hospitalisation"; break;
                        case "DECES_MEMBRE": typeSinistre = "Décès Membre"; break;
                        case "DECES_CONJOINT": typeSinistre = "Décès Conjoint"; break;
                        case "DECES_PARENT": typeSinistre = "Décès Parent"; break;
                        case "DECES_ENFANT": typeSinistre = "Décès Enfant"; break;
                    }
%>
                <tr>
                    <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                    <td><%= typeSinistre %></td>
                    <td>
					    <% 
					    BigDecimal montant = rs.getBigDecimal("montant_demande");
					    if (montant != null) {
					        try {
					            out.print(nf.format(montant) + " FCFA");
					        } catch (IllegalArgumentException e) {
					            out.print("Format invalide");
					        }
					    } else {
					        out.print("N/A");
					    }
					    %>
					</td>
                    <td><%= sdf.format(rs.getDate("date_sinistre")) %></td>
                    <td>
                        <span class="badge <%= statutClass %>">
                            <%= rs.getString("statut") %>
                        </span>
                    </td>
                    <td>
                        <% if ("PENDING".equals(rs.getString("statut"))) { %>
                            <button class="btn btn-sm btn-success" 
                                    onclick="approuverSinistre(<%= rs.getInt("id") %>, 'APPROVED')">
                                Approuver
                            </button>
                            <button class="btn btn-sm btn-danger" 
                                    onclick="approuverSinistre(<%= rs.getInt("id") %>, 'REJECTED')">
                                Rejeter
                            </button>
                        <% } else if ("APPROVED".equals(rs.getString("statut"))) { %>
                            <button class="btn btn-sm btn-info" 
                                    onclick="payerSinistre(<%= rs.getInt("id") %>)">
                                Payer
                            </button>
                        <% } %>
                    </td>
                </tr>
<%
                }
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
    </div>
    
    <!-- Modal Nouvelle Sanction -->
    <div class="modal" id="sanctionModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-gavel"></i> Nouvelle Sanction
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="sanctionForm" action="saveSanction.jsp" method="POST">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Membre</label>
                        <select class="form-control" name="member_id" required>
                            <option value="">Sélectionner un membre</option>
                           <%
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT member_id, nom, prenom FROM members WHERE isMember = 0 ORDER BY nom";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
%>
                <option value="<%= rs.getInt("member_id") %>">
                    <%= rs.getString("prenom") %> <%= rs.getString("nom") %>
                </option>
<%
            }
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
}
%>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Type de Sanction</label>
                        <select class="form-control" name="type_sanction" required>
                            <option value="RETARD">Retard</option>
                            <option value="BAGARRE">Bagarre</option>
                            <option value="INJURE">Injure</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Montant (FCFA)</label>
                        <input type="number" class="form-control" name="montant" required>
                    </div>
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" class="form-control" name="date_sanction" required>
                    </div>
                    <div class="form-group">
                        <label>Raison</label>
                        <textarea class="form-control" name="raison" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeSanctionModal">Annuler</button>
                    <button type="submit" class="btn btn-danger">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>

    <script>
    document.getElementById('calculInteretsBtn').addEventListener('click', function() {
        // Demander confirmation avant de calculer les intérêts
        Swal.fire({
            title: 'Calcul des intérêts scolaires',
            text: 'Voulez-vous calculer les intérêts pour l\'année en cours?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Oui, calculer',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                // Afficher un loader pendant le traitement
                Swal.fire({
                    title: 'Calcul en cours',
                    html: 'Veuillez patienter pendant le calcul des intérêts...',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                // Envoyer la requête AJAX au serveur
                fetch('calculInteretsScolaires.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    }
                })
                .then(response => response.json())
                .then(data => {
                    Swal.close();
                    if (data.success) {
                        Swal.fire({
                            title: 'Succès!',
                            text: data.message,
                            icon: 'success'
                        }).then(() => {
                            // Recharger la page pour afficher les nouveaux calculs
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            title: 'Erreur!',
                            text: data.message,
                            icon: 'error'
                        });
                    }
                })
                .catch(error => {
                    Swal.close();
                    Swal.fire({
                        title: 'Erreur!',
                        text: 'Une erreur est survenue lors du calcul: ' + error,
                        icon: 'error'
                    });
                });
            }
        });
    });

    function payerInteret(id) {
        Swal.fire({
            title: 'Paiement des intérêts',
            text: 'Confirmez-vous le paiement de ces intérêts?',
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: 'Oui, payer',
            cancelButtonText: 'Annuler'
        }).then((result) => {
            if (result.isConfirmed) {
                fetch('payerInteretScolaire.jsp', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: 'id=' + id
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        Swal.fire({
                            title: 'Succès!',
                            text: data.message,
                            icon: 'success'
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            title: 'Erreur!',
                            text: data.message,
                            icon: 'error'
                        });
                    }
                })
                .catch(error => {
                    Swal.fire({
                        title: 'Erreur!',
                        text: 'Une erreur est survenue: ' + error,
                        icon: 'error'
                    });
                });
            }
        });
    }
 // Fonctions pour gérer les sinistres
    function approuverSinistre(id, action) {
        if (confirm("Confirmer cette action ?")) {
            window.location.href = "processSinistre.jsp?id="+id+",action="+action;
        }
    }

    function payerSinistre(id) {
        if (confirm("Confirmer le paiement de ce sinistre ?")) {
            window.location.href = "payerSinistre.jsp?id="+id;
        }
    }

    // Fonction pour payer les intérêts (si non présente)
    function payerInteret(id) {
        if (confirm("Confirmer le paiement de ces intérêts ?")) {
            window.location.href = "payerInteret.jsp?id="+id;
        }
    }
        // Gestion des onglets
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                tab.classList.add('active');
                document.getElementById(tab.getAttribute('data-tab')).classList.add('active');
            });
        });
        
        // Gestion de la modal sanction
        const sanctionModal = document.getElementById('sanctionModal');
        document.getElementById('addSanctionBtn').addEventListener('click', () => {
            sanctionModal.style.display = 'flex';
        });
        
        document.getElementById('closeSanctionModal').addEventListener('click', () => {
            sanctionModal.style.display = 'none';
        });
        
       
        
        // Fermer modal en cliquant à l'extérieur
        window.addEventListener('click', (e) => {
            if (e.target === sanctionModal) {
                sanctionModal.style.display = 'none';
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</body>
</html>