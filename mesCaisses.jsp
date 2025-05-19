<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.Calendar" %>
<%@ page session="true" %>

<%
    // Vérification connexion
    Integer memberId = (Integer) session.getAttribute("memberId");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Formats
    NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    SimpleDateFormat monthYearFormat = new SimpleDateFormat("MM/yyyy");
    
    // Récupération des données membre
    String memberName = "";
    BigDecimal soldeScolaire = BigDecimal.ZERO;
    int pendingSanctions = 0;
    boolean hasPaidCurrentMonth = false;
    String nextPaymentDate = "01/06/2025";
    BigDecimal mutuelleAmount = new BigDecimal("5000");
    int currentMonth = 5; // Mai
    int currentYear = 2025;
    
    try (Connection conn = DBConnection.getConnection()) {
        // Nom du membre
        String sql = "SELECT nom, prenom FROM members WHERE member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    memberName = rs.getString("prenom") + " " + rs.getString("nom");
                }
            }
        }
        
        // Vérification paiement mutuelle du mois courant
        sql = "SELECT COUNT(*) as count FROM versements " +
              "WHERE member_id = ? AND caisse_id = 1 AND statut = 'VALIDATED' " +
              "AND MONTH(date_versement) = ? AND YEAR(date_versement) = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.setInt(2, currentMonth);
            ps.setInt(3, currentYear);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    hasPaidCurrentMonth = rs.getInt("count") > 0;
                }
            }
        }
        
        // Solde scolaire
       // Solde scolaire - Version corrigée
// Version CORRIGEE et TESTEE
sql = "SELECT (" +
      "(SELECT COALESCE(SUM(montant), 0) FROM versements WHERE member_id = ? AND caisse_id = 2 AND statut = 'VALIDATED') + " +
      "(SELECT COALESCE(SUM(montant_interet), 0) FROM interets_scolaires WHERE member_id = ? AND statut = 'PAID')" +
      ") AS solde";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ps.setInt(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    soldeScolaire = rs.getBigDecimal("solde");
                }
            }
        }
        
        // Sanctions en attente
        sql = "SELECT COUNT(*) as count FROM sanctions WHERE member_id = ? AND statut = 'PENDING'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    pendingSanctions = rs.getInt("count");
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Caisses | Membre</title>
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
        
        .payment-block {
            background: linear-gradient(135deg, #ff6b6b, #ff8e8e);
            color: white;
            padding: 25px;
            border-radius: 12px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(255, 107, 107, 0.2);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .payment-block h3 {
            font-size: 22px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .payment-block p {
            margin-bottom: 0;
            font-size: 16px;
        }
        
        .payment-block .btn-white {
            background: white;
            color: #ff6b6b;
            font-weight: 600;
        }
        
        .payment-block .btn-white:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(255, 255, 255, 0.3);
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .alert-success {
            background: rgba(39, 174, 96, 0.1);
            color: var(--success);
            border-left: 4px solid var(--success);
        }
        
        .alert-error {
            background: rgba(231, 76, 60, 0.1);
            color: var(--danger);
            border-left: 4px solid var(--danger);
        }
        
        .notification-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background-color: var(--danger);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
        }
        
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
        }
    </style>
</head>
<body>
    <%@ include file="sidebars.jsp" %>

    <div class="content">
        <div class="header">
            <h2><i class="fas fa-piggy-bank"></i> Mes Caisses</h2>
            <div class="user-info">
                <span><%= memberName %></span>
            </div>
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
        
        <!-- Bloc de paiement obligatoire si non payé -->
        <% if (!hasPaidCurrentMonth) { %>
        <div class="payment-block">
            <div>
                <h3><i class="fas fa-exclamation-triangle"></i> Paiement obligatoire</h3>
                <p>Vous devez payer votre cotisation mutuelle pour le mois de <%= String.format("%02d", currentMonth) %>/<%= currentYear %> (<%= nf.format(mutuelleAmount) %> FCFA) pour continuer à utiliser les services.</p>
                <p>Prochain paiement le <%= nextPaymentDate %></p>
            </div>
            <button class="btn btn-white" id="payMutuelleBtn">
                <i class="fas fa-credit-card"></i> Payer maintenant
            </button>
        </div>
        <% } %>
        
        <!-- Cartes de statistiques -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon icon-mutuelle">
                    <i class="fas fa-heartbeat"></i>
                </div>
                <div class="stat-content">
                    <h3>Mutuelle</h3>
                    <p><%= hasPaidCurrentMonth ? "Payée" : "En attente" %></p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon icon-scolaire">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <div class="stat-content">
                    <h3>Épargne Scolaire</h3>
                    <p><%= nf.format(soldeScolaire) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card" style="position: relative;">
                <% if (pendingSanctions > 0) { %>
                <div class="notification-badge"><%= pendingSanctions %></div>
                <% } %>
                <div class="stat-icon icon-punition">
                    <i class="fas fa-gavel"></i>
                </div>
                <div class="stat-content">
                    <h3>Sanctions</h3>
                    <p><%= pendingSanctions %> en attente</p>
                </div>
            </div>
        </div>
        
        <!-- Onglets -->
        <div class="tabs">
            <div class="tab active" data-tab="mutuelle">Mutuelle</div>
            <div class="tab" data-tab="scolaire">Scolaire</div>
            <div class="tab" data-tab="sanctions">Mes Sanctions</div>
            <div class="tab" data-tab="sinistres">Mes Sinistres</div>
        </div>
        
        <!-- Onglet Mutuelle -->
        <div class="tab-content active" id="mutuelle">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-heartbeat"></i> Ma Mutuelle
                    </div>
                    <% if (!hasPaidCurrentMonth) { %>
                    <button class="btn btn-danger" id="payMutuelleBtn2">
                        <i class="fas fa-credit-card"></i> Payer la cotisation
                    </button>
                    <% } %>
                </div>
                
                <div class="card-body">
                    <% if (hasPaidCurrentMonth) { %>
                        <p>Votre cotisation mutuelle pour le mois de <%= String.format("%02d", currentMonth) %>/<%= currentYear %> est payée. Merci pour votre contribution.</p>
                        <p>Prochaine échéance le <strong><%= nextPaymentDate %></strong>.</p>
                    <% } else { %>
                        <p>Votre cotisation mutuelle pour le mois de <%= String.format("%02d", currentMonth) %>/<%= currentYear %> (<%= nf.format(mutuelleAmount) %> FCFA) est en attente de paiement.</p>
                        <p>Vous devez régler cette cotisation pour continuer à bénéficier des services.</p>
                    <% } %>
                    
                    <h3 style="margin-top: 20px;">Historique des paiements</h3>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Mois/Année</th>
                                    <th>Montant</th>
                                    <th>Date Paiement</th>
                                    <th>Méthode</th>
                                    <th>Statut</th>
                                    <th>Preuve</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        String sql = "SELECT * FROM versements WHERE member_id = ? AND caisse_id = 1 ORDER BY date_versement DESC";
                                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                            ps.setInt(1, memberId);
                                            try (ResultSet rs = ps.executeQuery()) {
                                                while (rs.next()) {
                                                    String statutClass = rs.getString("statut").equals("VALIDATED") ? "badge-success" : 
                                                                       rs.getString("statut").equals("PENDING") ? "badge-warning" : "badge-danger";
                                                    Calendar cal = Calendar.getInstance();
                                                    cal.setTime(rs.getDate("date_versement"));
                                                    String monthYear = monthYearFormat.format(cal.getTime());
                                %>
                                <tr>
                                    <td><%= monthYear %></td>
                                    <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                    <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                    <td><%= rs.getString("methode_paiement") %></td>
                                    <td><span class="badge <%= statutClass %>"><%= rs.getString("statut") %></span></td>
                                    <td>
                                        <% if (rs.getString("preuve") != null) { %>
                                        <a href="uploads/<%= rs.getString("preuve") %>" target="_blank" class="btn btn-sm btn-info">
                                            <i class="fas fa-eye"></i> Voir
                                        </a>
                                        <% } %>
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
        </div>
        
        <!-- Onglet Scolaire -->
        <div class="tab-content" id="scolaire">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-graduation-cap"></i> Mon Épargne Scolaire
                    </div>
                    <button class="btn btn-purple" id="addVersementScolaireBtn">
                        <i class="fas fa-plus"></i> Nouveau Versement
                    </button>
                </div>
                
                <div class="card-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle"></i> Votre solde scolaire actuel est de <strong><%= nf.format(soldeScolaire) %> FCFA</strong>.
                    </div>

                    <h3 style="margin-top: 20px;">Historique des versements</h3>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Montant</th>
                                    <th>Méthode</th>
                                    <th>Statut</th>
                                    <th>Preuve</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        String sql = "SELECT * FROM versements WHERE member_id = ? AND caisse_id = 2 ORDER BY date_versement DESC";
                                        try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                            ps.setInt(1, memberId);
                                            try (ResultSet rs = ps.executeQuery()) {
                                                while (rs.next()) {
                                                    String statutClass = rs.getString("statut").equals("VALIDATED") ? "badge-success" : 
                                                                       rs.getString("statut").equals("PENDING") ? "badge-warning" : "badge-danger";
                                %>
                                <tr>
                                    <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                    <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                    <td><%= rs.getString("methode_paiement") %></td>
                                    <td><span class="badge <%= statutClass %>"><%= rs.getString("statut") %></span></td>
                                    <td>
                                        <% if (rs.getString("preuve") != null) { %>
                                        <a href="uploads/<%= rs.getString("preuve") %>" target="_blank" class="btn btn-sm btn-info">
                                            <i class="fas fa-eye"></i> Voir
                                        </a>
                                        <% } %>
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
        </div>
        
        <!-- Onglet Sanctions -->
        <div class="tab-content" id="sanctions">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-gavel"></i> Mes Sanctions
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Raison</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT * FROM sanctions WHERE member_id = ? ORDER BY date_sanction DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        ps.setInt(1, memberId);
                                        try (ResultSet rs = ps.executeQuery()) {
                                            while (rs.next()) {
                                                String statutClass = rs.getString("statut").equals("PAID") ? "badge-success" : "badge-warning";
                            %>
                            <tr>
                                <td><%= rs.getString("type_sanction") %></td>
                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                <td><%= sdf.format(rs.getDate("date_sanction")) %></td>
                                <td><%= rs.getString("raison") %></td>
                                <td><span class="badge <%= statutClass %>"><%= rs.getString("statut") %></span></td>
                                <td>
                                    <% if (rs.getString("statut").equals("PENDING")) { %>
                                    <button class="btn btn-sm btn-primary" 
                                            onclick="paySanction(<%= rs.getInt("id") %>, <%= rs.getBigDecimal("montant") %>)">
                                        <i class="fas fa-money-bill-wave"></i> Payer
                                    </button>
                                    <% } %>
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
        
        <!-- Onglet Sinistres -->
        <div class="tab-content" id="sinistres">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-file-medical"></i> Mes Sinistres
                    </div>
                    <% if (hasPaidCurrentMonth) { %>
                    <button class="btn btn-primary" id="declareSinistreBtn">
                        <i class="fas fa-plus"></i> Déclarer un sinistre
                    </button>
                    <% } %>
                </div>
                
                <div class="card-body">
                    <% if (hasPaidCurrentMonth) { %>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Type</th>
                                        <th>Description</th>
                                        <th>Montant</th>
                                        <th>Statut</th>
                                        <th>Preuve</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection conn = DBConnection.getConnection()) {
                                            String sql = "SELECT * FROM  sinistres_mutuelle WHERE member_id = ? ORDER BY date_sinistre DESC";
                                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                                ps.setInt(1, memberId);
                                                try (ResultSet rs = ps.executeQuery()) {
                                                    while (rs.next()) {
                                                        String statutClass = rs.getString("statut").equals("APPROVED") ? "badge-success" : 
                                                                           rs.getString("statut").equals("PENDING") ? "badge-warning" : "badge-danger";
                                    %>
                                    <tr>
                                        <td><%= sdf.format(rs.getDate("date_sinistre")) %></td>
                                        <td><%= rs.getString("type_sinistre") %></td>
                                        <td><%= rs.getString("description") %></td>
                                        <td>
                                            <% if (rs.getBigDecimal("montant_demande") != null) { %>
                                                <%= nf.format(rs.getBigDecimal("montant_demande")) %> FCFA
                                            <% } else { %>
                                                En évaluation
                                            <% } %>
                                        </td>
                                        <td><span class="badge <%= statutClass %>"><%= rs.getString("statut") %></span></td>
                                        <td>
                                            <% if (rs.getString("preuve") != null) { %>
                                            <a href="uploads/<%= rs.getString("preuve") %>" target="_blank" class="btn btn-sm btn-info">
                                                <i class="fas fa-eye"></i> Voir
                                            </a>
                                            <% } %>
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
                    <% } else { %>
                        <div class="alert alert-error">
                            <i class="fas fa-exclamation-circle"></i> Vous devez payer votre cotisation mutuelle pour déclarer ou voir vos sinistres.
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Modal Paiement Mutuelle -->
    <div class="modal" id="payMutuelleModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-heartbeat"></i> Paiement de la Mutuelle
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="payMutuelleForm" action="PayMutuelleServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <input type="hidden" name="montant" value="<%= mutuelleAmount %>">
                <input type="hidden" name="mois" value="<%= currentMonth %>">
                <input type="hidden" name="annee" value="<%= currentYear %>">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Mois/Année</label>
                        <input type="text" class="form-control" value="<%= String.format("%02d", currentMonth) %>/<%= currentYear %>" readonly>
                    </div>
                    <div class="form-group">
                        <label>Montant à payer</label>
                        <input type="text" class="form-control" value="<%= nf.format(mutuelleAmount) %> FCFA" readonly>
                    </div>
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closePayMutuelleModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Valider Paiement</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Paiement Sanction -->
    <div class="modal" id="paySanctionModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-money-bill-wave"></i> Paiement d'une Sanction
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="paySanctionForm" action="PaySanctionServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" id="sanctionId" name="sanction_id">
                <input type="hidden" id="sanctionMontant" name="montant">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Montant à payer</label>
                        <input type="text" class="form-control" id="sanctionAmount" readonly>
                    </div>
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closePaySanctionModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Valider Paiement</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Nouveau Versement Scolaire -->
    <div class="modal" id="versementScolaireModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-graduation-cap"></i> Nouveau Versement Scolaire
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="versementScolaireForm" action="AddVersementScolaireServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <input type="hidden" name="caisse_id" value="2">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Montant</label>
                        <input type="number" class="form-control" name="montant" min="1000" step="500" required>
                    </div>
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" class="form-control" name="date_versement" required>
                    </div>
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeVersementScolaireModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Déclaration Sinistre -->
    <div class="modal" id="declareSinistreModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-file-medical"></i> Déclarer un Sinistre
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="declareSinistreForm" action="DeclareSinistreServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Type de sinistre</label>
                        <select class="form-control" name="type_sinistre" required>
                            <option value="">Sélectionnez un type</option>
						    <option value="HOSPITALISATION">Hospitalisation</option>
						    <option value="DECES_MEMBRE">Décès du membre</option>
						    <option value="DECES_CONJOINT">Décès du conjoint</option>
						    <option value="DECES_PARENT">Décès d'un parent</option>
						    <option value="DECES_ENFANT">Décès d'un enfant</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Date du sinistre</label>
                        <input type="date" class="form-control" name="date_sinistre" required>
                    </div>
                    <div class="form-group">
                        <label>Description détaillée</label>
                        <textarea class="form-control" name="description" rows="4" required></textarea>
                    </div>
                    <div class="form-group">
                        <label>Montant estimé (FCFA)</label>
                        <input type="number" class="form-control" name="montant" min="0">
                    </div>
                    <div class="form-group">
                        <label>Preuve/document</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeDeclareSinistreModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Déclarer</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Gestion des onglets
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                tab.classList.add('active');
                document.getElementById(tab.getAttribute('data-tab')).classList.add('active');
            });
        });
        
        // Ouverture modale paiement mutuelle
        document.getElementById('payMutuelleBtn')?.addEventListener('click', openMutuelleModal);
        document.getElementById('payMutuelleBtn2')?.addEventListener('click', openMutuelleModal);
        
        function openMutuelleModal() {
            document.getElementById('payMutuelleModal').style.display = 'flex';
        }
        
        // Paiement d'une sanction
        function paySanction(id, montant) {
            document.getElementById('sanctionId').value = id;
            document.getElementById('sanctionMontant').value = montant;
            document.getElementById('sanctionAmount').value = montant + ' FCFA';
            document.getElementById('paySanctionModal').style.display = 'flex';
        }
        
        // Ouverture modale versement scolaire
        document.getElementById('addVersementScolaireBtn')?.addEventListener('click', () => {
            document.getElementById('versementScolaireModal').style.display = 'flex';
        });
        
        // Ouverture modale déclaration sinistre
        document.getElementById('declareSinistreBtn')?.addEventListener('click', () => {
            document.getElementById('declareSinistreModal').style.display = 'flex';
        });
        
        // Fermeture modals
        document.getElementById('closePayMutuelleModal')?.addEventListener('click', () => {
            document.getElementById('payMutuelleModal').style.display = 'none';
        });
        
        document.getElementById('closePaySanctionModal')?.addEventListener('click', () => {
            document.getElementById('paySanctionModal').style.display = 'none';
        });
        
        document.getElementById('closeVersementScolaireModal')?.addEventListener('click', () => {
            document.getElementById('versementScolaireModal').style.display = 'none';
        });
        
        document.getElementById('closeDeclareSinistreModal')?.addEventListener('click', () => {
            document.getElementById('declareSinistreModal').style.display = 'none';
        });
        
        // Fermer en cliquant à l'extérieur
        window.addEventListener('click', (e) => {
            if (e.target === document.getElementById('payMutuelleModal')) {
                document.getElementById('payMutuelleModal').style.display = 'none';
            }
            if (e.target === document.getElementById('paySanctionModal')) {
                document.getElementById('paySanctionModal').style.display = 'none';
            }
            if (e.target === document.getElementById('versementScolaireModal')) {
                document.getElementById('versementScolaireModal').style.display = 'none';
            }
            if (e.target === document.getElementById('declareSinistreModal')) {
                document.getElementById('declareSinistreModal').style.display = 'none';
            }
        });
        
        // Bloquer l'accès aux autres onglets si mutuelle non payée
        <% if (!hasPaidCurrentMonth) { %>
        document.querySelectorAll('.tab:not(:first-child)').forEach(tab => {
            tab.addEventListener('click', (e) => {
                e.preventDefault();
                alert("Vous devez d'abord payer votre cotisation mutuelle pour accéder à cette section.");
                document.querySelector('.tab.active').click();
            });
        });
        <% } %>
        
        // Définir la date du jour comme valeur par défaut pour les formulaires
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.querySelector('input[name="date_versement"]').value = today;
            document.querySelector('input[name="date_sinistre"]').value = today;
        });
    </script>
</body>
</html>