<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, utils.DBConnection, java.math.BigDecimal, java.text.NumberFormat, 
                 java.text.SimpleDateFormat, java.util.Locale, jakarta.servlet.http.HttpSession, 
                 java.util.Calendar" %>
<%@ page session="true" %>

<%
    // Vérification de la session utilisateur
    Integer memberId = (Integer) session.getAttribute("memberId");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Initialisation des formats avec devise FCFA
    final Locale FRENCH_LOCALE = new Locale("fr", "FR");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(FRENCH_LOCALE);
    // Modification pour afficher FCFA au lieu de €
    currencyFormat.setCurrency(java.util.Currency.getInstance("XOF"));
    
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy", FRENCH_LOCALE);
    SimpleDateFormat monthYearFormat = new SimpleDateFormat("MM/yyyy", FRENCH_LOCALE);
    
    // Données membre
    String memberName = "";
    BigDecimal soldeScolaire = BigDecimal.ZERO;
    int pendingSanctions = 0;
    boolean hasPaidCurrentMonth = false;
    final String CURRENT_MONTH_YEAR = "05/2025";
    final String NEXT_PAYMENT_DATE = "01/06/2025";
    final BigDecimal MUTUELLE_AMOUNT = new BigDecimal("5000");
    
    // Récupération des données depuis la base
    try (Connection conn = DBConnection.getConnection()) {
        // 1. Informations du membre
        String query = "SELECT nom, prenom FROM members WHERE member_id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, memberId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    memberName = rs.getString("prenom") + " " + rs.getString("nom");
                }
            }
        }
        
        // 2. Vérification paiement mutuelle du mois courant
        query = "SELECT COUNT(*) FROM versements WHERE member_id = ? AND caisse_id = 1 " +
                "AND statut = 'VALIDATED' AND MONTH(date_versement) = 5 AND YEAR(date_versement) = 2025";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, memberId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    hasPaidCurrentMonth = rs.getInt(1) > 0;
                }
            }
        }
        
        // 3. Calcul du solde scolaire
       query = "SELECT ("
      + "IFNULL((SELECT SUM(montant) FROM versements WHERE member_id = ? AND caisse_id = 2 AND statut = 'VALIDATED'), 0)"
      + " - "
      + "IFNULL((SELECT SUM(montant_interet) FROM interets_scolaires WHERE member_id = ? AND statut = 'PAID'), 0)"
      + ") AS solde";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, memberId);
            stmt.setInt(2, memberId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    soldeScolaire = rs.getBigDecimal("solde");
                    if (soldeScolaire == null) soldeScolaire = BigDecimal.ZERO;
                }
            }
        }
        
        // 4. Sanctions en attente
        query = "SELECT COUNT(*) FROM sanctions WHERE member_id = ? AND statut = 'PENDING'";
        try (PreparedStatement stmt = conn.prepareStatement(query)) {
            stmt.setInt(1, memberId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    pendingSanctions = rs.getInt(1);
                }
            }
        }
    } catch (SQLException e) {
        System.err.println("Erreur SQL: " + e.getMessage());
        System.err.println("Code d'erreur SQL: " + e.getErrorCode());
        System.err.println("État SQL: " + e.getSQLState());
        e.printStackTrace(); // Affiche la stack trace complète
        session.setAttribute("errorMessage", "Une erreur est survenue lors de la récupération des données.");
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Caisses | <%= memberName %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #27ae60;
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
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
            --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
            --shadow-lg: 0 10px 25px rgba(0,0,0,0.1);
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 16px;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        
        body {
            background-color: var(--light-bg);
            color: var(--dark-text);
            min-height: 100vh;
            line-height: 1.6;
        }
        
        /* Layout */
        .app-container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, #2c3e50, #1a252f);
            color: white;
            position: fixed;
            height: 100vh;
            z-index: 100;
        }
        
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 2rem;
        }
        
        /* Header */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .page-title {
            font-size: 1.75rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        .page-title::after {
            content: "";
            display: block;
            width: 60px;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--primary-light));
            margin-top: 0.5rem;
            border-radius: 2px;
        }
        
        /* Cards */
        .card {
            background: white;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-md);
            padding: 1.5rem;
            margin-bottom: 1.5rem;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }
        
        .card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(to bottom, var(--primary), var(--primary-light));
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.25rem;
        }
        
        .card-title {
            font-size: 1.25rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.25rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            border-radius: var(--radius-sm);
            padding: 1.25rem;
            display: flex;
            align-items: center;
            gap: 1rem;
            box-shadow: var(--shadow-sm);
            transition: all 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--shadow-md);
        }
        
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
            color: white;
            flex-shrink: 0;
        }
        
        .icon-mutuelle { background: linear-gradient(135deg, #3498db, #2980b9); }
        .icon-scolaire { background: linear-gradient(135deg, #9b59b6, #8e44ad); }
        .icon-sanctions { background: linear-gradient(135deg, #e74c3c, #c0392b); }
        
        .stat-content h3 {
            font-size: 0.875rem;
            color: var(--light-text);
            margin-bottom: 0.25rem;
            font-weight: 500;
        }
        
        .stat-content p {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--dark-text);
        }
        
        /* Tabs */
        .tabs {
            display: flex;
            border-bottom: 1px solid #ddd;
            margin-bottom: 1.5rem;
        }
        
        .tab {
            padding: 0.75rem 1.25rem;
            cursor: pointer;
            font-weight: 500;
            border-bottom: 3px solid transparent;
            transition: all 0.2s ease;
        }
        
        .tab.active {
            border-bottom-color: var(--primary);
            color: var(--primary);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
        }
        
        /* Tables */
        .table-responsive {
            overflow-x: auto;
            border-radius: var(--radius-sm);
            box-shadow: var(--shadow-sm);
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        
        .table th {
            background: linear-gradient(to right, var(--primary), var(--primary-light));
            color: white;
            padding: 1rem;
            text-align: left;
            font-weight: 500;
        }
        
        .table td {
            padding: 0.875rem 1rem;
            border-bottom: 1px solid #eee;
        }
        
        .table tr:last-child td {
            border-bottom: none;
        }
        
        .table tr:hover {
            background: rgba(39, 174, 96, 0.05);
        }
        
        /* Badges */
        .badge {
            display: inline-flex;
            align-items: center;
            padding: 0.375rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            gap: 0.25rem;
        }
        
        .badge-success { background: rgba(39, 174, 96, 0.1); color: var(--success); }
        .badge-warning { background: rgba(243, 156, 18, 0.1); color: var(--warning); }
        .badge-danger { background: rgba(231, 76, 60, 0.1); color: var(--danger); }
        .badge-info { background: rgba(52, 152, 219, 0.1); color: var(--info); }
        .badge-purple { background: rgba(155, 89, 182, 0.1); color: var(--purple); }
        
        /* Buttons */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 0.625rem 1.25rem;
            border-radius: var(--radius-sm);
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
            gap: 0.5rem;
        }
        
        .btn-sm {
            padding: 0.375rem 0.75rem;
            font-size: 0.875rem;
        }
        
        .btn-primary {
            background: linear-gradient(to right, var(--primary), var(--primary-light));
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.2);
        }
        
        .btn-danger {
            background: linear-gradient(to right, #e74c3c, #c0392b);
            color: white;
        }
        
        .btn-outline {
            background: transparent;
            border: 1px solid #ddd;
            color: var(--dark-text);
        }
        
        /* Alerts */
        .alert {
            padding: 1rem;
            border-radius: var(--radius-sm);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            border-left: 4px solid;
        }
        
        .alert-success {
            background: rgba(39, 174, 96, 0.1);
            border-left-color: var(--success);
            color: var(--success);
        }
        
        .alert-error {
            background: rgba(231, 76, 60, 0.1);
            border-left-color: var(--danger);
            color: var(--danger);
        }
        
        /* Payment Block */
        .payment-block {
            background: linear-gradient(135deg, #ff6b6b, #ff8e8e);
            color: white;
            padding: 1.5rem;
            border-radius: var(--radius-sm);
            margin-bottom: 1.5rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 5px 15px rgba(255, 107, 107, 0.2);
        }
        
        .payment-block h3 {
            font-size: 1.25rem;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        /* Modals */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal-content {
            background: white;
            border-radius: var(--radius-md);
            width: 90%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: var(--shadow-lg);
            animation: modalFadeIn 0.3s ease;
        }
        
        .modal-header {
            padding: 1.25rem;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .modal-title {
            font-size: 1.25rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .modal-body {
            padding: 1.25rem;
        }
        
        .modal-footer {
            padding: 1.25rem;
            border-top: 1px solid #eee;
            display: flex;
            justify-content: flex-end;
            gap: 0.75rem;
        }
        
        /* Form Elements */
        .form-group {
            margin-bottom: 1rem;
        }
        
        .form-label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border: 1px solid #ddd;
            border-radius: var(--radius-sm);
            transition: all 0.2s ease;
        }
        
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.1);
            outline: none;
        }
        
        /* Utility Classes */
        .notification-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: var(--danger);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: bold;
        }
        
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>
    <div class="app-container">
        <%@ include file="sidebars.jsp" %>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fas fa-piggy-bank"></i> Mes Caisses
                </h1>
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
            
            <!-- Bloc de paiement obligatoire -->
            <% if (!hasPaidCurrentMonth) { %>
            <div class="payment-block">
                <div>
                    <h3><i class="fas fa-exclamation-triangle"></i> Paiement obligatoire</h3>
                    <p>Vous devez payer votre cotisation mutuelle pour le mois de mai 2025 (<%= currencyFormat.format(MUTUELLE_AMOUNT) %>) pour continuer à utiliser les services.</p>
                    <p>Prochain paiement le <%= NEXT_PAYMENT_DATE %></p>
                </div>
                <button class="btn btn-primary" id="payMutuelleBtn">
                    <i class="fas fa-credit-card"></i> Payer maintenant
                </button>
            </div>
            <% } %>
            
            <!-- Statistiques -->
            <div class="stats-grid">
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
                        <p><%= currencyFormat.format(soldeScolaire) %></p>
                    </div>
                </div>
                
                <div class="stat-card" style="position: relative;">
                    <% if (pendingSanctions > 0) { %>
                    <div class="notification-badge"><%= pendingSanctions %></div>
                    <% } %>
                    <div class="stat-icon icon-sanctions">
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
                <div class="tab" data-tab="sanctions">Sanctions</div>
                <div class="tab" data-tab="sinistres">Sinistres</div>
            </div>
            
            <!-- Contenu des onglets -->
            <div class="tab-content active" id="mutuelle">
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <i class="fas fa-heartbeat"></i> Ma Mutuelle
                        </h2>
                        <% if (!hasPaidCurrentMonth) { %>
                        <button class="btn btn-danger" id="payMutuelleBtn2">
                            <i class="fas fa-credit-card"></i> Payer la cotisation
                        </button>
                        <% } %>
                    </div>
                    
                    <div class="card-body">
                        <% if (hasPaidCurrentMonth) { %>
                            <p>Votre cotisation mutuelle pour le mois de mai 2025 est payée. Merci pour votre contribution.</p>
                            <p>Prochaine échéance le <strong><%= NEXT_PAYMENT_DATE %></strong>.</p>
                        <% } else { %>
                            <p>Votre cotisation mutuelle pour le mois de mai 2025 (<%= currencyFormat.format(MUTUELLE_AMOUNT) %>) est en attente de paiement.</p>
                            <p>Vous devez régler cette cotisation pour continuer à bénéficier des services.</p>
                        <% } %>
                        
                        <h3 style="margin-top: 1.5rem;">Historique des paiements</h3>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Mois/Année</th>
                                        <th>Montant (FCFA)</th>
                                        <th>Date Paiement</th>
                                        <th>Méthode</th>
                                        <th>Statut</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection conn = DBConnection.getConnection()) {
                                            String query = "SELECT * FROM versements WHERE member_id = ? AND caisse_id = 1 ORDER BY date_versement DESC";
                                            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                                                stmt.setInt(1, memberId);
                                                try (ResultSet rs = stmt.executeQuery()) {
                                                    while (rs.next()) {
                                                        String status = rs.getString("statut");
                                                        String badgeClass = "badge-" + 
                                                            (status.equals("VALIDATED") ? "success" : 
                                                             status.equals("PENDING") ? "warning" : "danger");
                                                        
                                                        Calendar cal = Calendar.getInstance();
                                                        cal.setTime(rs.getDate("date_versement"));
                                                        String monthYear = monthYearFormat.format(cal.getTime());
                                    %>
                                    <tr>
                                        <td><%= monthYear %></td>
                                        <td><%= currencyFormat.format(rs.getBigDecimal("montant")) %></td>
                                        <td><%= dateFormat.format(rs.getDate("date_versement")) %></td>
                                        <td><%= rs.getString("methode_paiement") %></td>
                                        <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                    </tr>
                                    <%
                                                    }
                                                }
                                            }
                                        } catch (SQLException e) {
                                            System.err.println("Erreur lors de la récupération de l'historique mutuelle: " + e.getMessage());
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
                        <h2 class="card-title">
                            <i class="fas fa-graduation-cap"></i> Mon Épargne Scolaire
                        </h2>
                        <button class="btn btn-primary" id="addVersementScolaireBtn">
                            <i class="fas fa-plus"></i> Nouveau Versement
                        </button>
                    </div>
                    
                    <div class="card-body">
                        <div class="alert alert-success">
                            <i class="fas fa-info-circle"></i> Votre solde scolaire actuel est de <strong><%= currencyFormat.format(soldeScolaire) %></strong>.
                        </div>

                        <h3 style="margin-top: 1.5rem;">Historique des versements</h3>
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Montant (FCFA)</th>
                                        <th>Méthode</th>
                                        <th>Statut</th>
                                        <th>Preuve</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        try (Connection conn = DBConnection.getConnection()) {
                                            String query = "SELECT * FROM versements WHERE member_id = ? AND caisse_id = 2 ORDER BY date_versement DESC";
                                            try (PreparedStatement stmt = conn.prepareStatement(query)) {
                                                stmt.setInt(1, memberId);
                                                try (ResultSet rs = stmt.executeQuery()) {
                                                    while (rs.next()) {
                                                        String status = rs.getString("statut");
                                                        String badgeClass = "badge-" + 
                                                            (status.equals("VALIDATED") ? "success" : 
                                                             status.equals("PENDING") ? "warning" : "danger");
                                    %>
                                    <tr>
                                        <td><%= dateFormat.format(rs.getDate("date_versement")) %></td>
                                        <td><%= currencyFormat.format(rs.getBigDecimal("montant")) %></td>
                                        <td><%= rs.getString("methode_paiement") %></td>
                                        <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                        <td>
                                            <% if (rs.getString("preuve") != null) { %>
                                            <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-sm btn-primary">
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
                                            System.err.println("Erreur lors de la récupération de l'historique scolaire: " + e.getMessage());
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
                        <h2 class="card-title">
                            <i class="fas fa-gavel"></i> Mes Sanctions
                        </h2>
                    </div>
                    
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Type</th>
                                    <th>Montant (FCFA)</th>
                                    <th>Date</th>
                                    <th>Raison</th>
                                    <th>Statut</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    try (Connection conn = DBConnection.getConnection()) {
                                        String query = "SELECT * FROM sanctions WHERE member_id = ? ORDER BY date_sanction DESC";
                                        try (PreparedStatement stmt = conn.prepareStatement(query)) {
                                            stmt.setInt(1, memberId);
                                            try (ResultSet rs = stmt.executeQuery()) {
                                                while (rs.next()) {
                                                    String status = rs.getString("statut");
                                                    String badgeClass = status.equals("PAID") ? "badge-success" : "badge-warning";
                                %>
                                <tr>
                                    <td><%= rs.getString("type_sanction") %></td>
                                    <td><%= currencyFormat.format(rs.getBigDecimal("montant")) %></td>
                                    <td><%= dateFormat.format(rs.getDate("date_sanction")) %></td>
                                    <td><%= rs.getString("raison") %></td>
                                    <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                    <td>
                                        <% if (status.equals("PENDING")) { %>
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
                                        System.err.println("Erreur lors de la récupération des sanctions: " + e.getMessage());
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
                        <h2 class="card-title">
                            <i class="fas fa-file-medical"></i> Mes Sinistres
                        </h2>
                        <button class="btn btn-primary" id="declareSinistreBtn">
                            <i class="fas fa-plus"></i> Déclarer un sinistre
                        </button>
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
                                            <th>Montant (FCFA)</th>
                                            <th>Statut</th>
                                            <th>Preuve</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            try (Connection conn = DBConnection.getConnection()) {
                                                String query = "SELECT * FROM sinistres_mutuelle WHERE member_id = ? ORDER BY date_sinistre DESC";
                                                try (PreparedStatement stmt = conn.prepareStatement(query)) {
                                                    stmt.setInt(1, memberId);
                                                    try (ResultSet rs = stmt.executeQuery()) {
                                                        while (rs.next()) {
                                                            String status = rs.getString("statut");
                                                            String badgeClass = 
                                                                status.equals("APPROVED") ? "badge-success" : 
                                                                status.equals("PENDING") ? "badge-warning" : "badge-danger";
                                        %>
                                        <tr>
                                            <td><%= dateFormat.format(rs.getDate("date_sinistre")) %></td>
                                            <td><%= rs.getString("type_sinistre") %></td>
                                            <td><%= rs.getString("description") %></td>
                                            <td>
                                                <% if (rs.getBigDecimal("montant_demande") != null) { %>
                                                    <%= currencyFormat.format(rs.getBigDecimal("montant_demande")) %>
                                                <% } else { %>
                                                    En évaluation
                                                <% } %>
                                            </td>
                                            <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                                            <td>
                                                <% if (rs.getString("preuve") != null) { %>
                                                <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-sm btn-primary">
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
                                                System.err.println("Erreur lors de la récupération des sinistres: " + e.getMessage());
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
        </main>
    </div>
    
    <!-- Modals -->
    <!-- Modal Paiement Mutuelle -->
    <div class="modal" id="payMutuelleModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">
                    <i class="fas fa-heartbeat"></i> Paiement de la Mutuelle
                </h3>
                <button class="modal-close">&times;</button>
            </div>
            <form id="payMutuelleForm" action="PayMutuelleServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <input type="hidden" name="montant" value="<%= MUTUELLE_AMOUNT %>">
                <input type="hidden" name="mois" value="5">
                <input type="hidden" name="annee" value="2025">
                
                <div class="modal-body">
                    <div class="form-group">
                        <label>Mois/Année</label>
                        <input type="text" class="form-control" value="<%= CURRENT_MONTH_YEAR %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Montant à payer</label>
                        <input type="text" class="form-control" value="<%= currencyFormat.format(MUTUELLE_AMOUNT) %>" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="">Sélectionnez une méthode</option>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                        <small class="text-muted">Format acceptés: JPG, PNG, PDF (max 2MB)</small>
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
                <h3 class="modal-title">
                    <i class="fas fa-money-bill-wave"></i> Paiement d'une Sanction
                </h3>
                <button class="modal-close">&times;</button>
            </div>
            <form id="paySanctionForm" action="PaySanctionServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" id="sanctionId" name="sanction_id">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Montant à payer (FCFA)</label>
                        <input type="text" class="form-control" id="sanctionAmount" readonly>
                    </div>
                    
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="">Sélectionnez une méthode</option>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                        <small class="text-muted">Format acceptés: JPG, PNG, PDF (max 2MB)</small>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closePaySanctionModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Valider Paiement</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Déclaration Sinistre -->
    <div class="modal" id="declareSinistreModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">
                    <i class="fas fa-file-medical"></i> Déclarer un Sinistre
                </h3>
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
                        <input type="number" class="form-control" name="montant" min="0" step="1000">
                    </div>
                    
                    <div class="form-group">
                        <label>Preuve/document</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                        <small class="text-muted">Format acceptés: JPG, PNG, PDF (max 5MB)</small>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeDeclareSinistreModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Déclarer</button>
                </div>
            </form>
        </div>
    </div>
    
    <!-- Modal Nouveau Versement Scolaire -->
    <div class="modal" id="versementScolaireModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title">
                    <i class="fas fa-graduation-cap"></i> Nouveau Versement Scolaire
                </h3>
                <button class="modal-close">&times;</button>
            </div>
            <form id="versementScolaireForm" action="AddVersementScolaireServlet" method="POST" enctype="multipart/form-data">
                <input type="hidden" name="member_id" value="<%= memberId %>">
                <input type="hidden" name="caisse_id" value="2">
                
                <div class="modal-body">
                    <div class="form-group">
                        <label>Montant (FCFA)</label>
                        <input type="number" class="form-control" name="montant" min="1000" step="500" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" class="form-control" name="date_versement" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Méthode de paiement</label>
                        <select class="form-control" name="methode_paiement" required>
                            <option value="">Sélectionnez une méthode</option>
                            <option value="CASH">Espèces</option>
                            <option value="MTNMONEY">MTN Money</option>
                            <option value="ORANGEMONEY">Orange Money</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Preuve de paiement</label>
                        <input type="file" class="form-control" name="preuve" accept="image/*,.pdf" required>
                        <small class="text-muted">Format acceptés: JPG, PNG, PDF (max 2MB)</small>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeVersementScolaireModal">Annuler</button>
                    <button type="submit" class="btn btn-primary">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Gestion des onglets
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                const tabId = tab.getAttribute('data-tab');
                
                // Désactiver tous les onglets et contenus
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                // Activer l'onglet et le contenu sélectionnés
                tab.classList.add('active');
                document.getElementById(tabId).classList.add('active');
            });
        });
        
        // Gestion des modals
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Paiement mutuelle
        document.getElementById('payMutuelleBtn')?.addEventListener('click', () => openModal('payMutuelleModal'));
        document.getElementById('payMutuelleBtn2')?.addEventListener('click', () => openModal('payMutuelleModal'));
        document.getElementById('closePayMutuelleModal')?.addEventListener('click', () => closeModal('payMutuelleModal'));
        
        // Déclaration sinistre
        document.getElementById('declareSinistreBtn')?.addEventListener('click', () => {
            <% if (hasPaidCurrentMonth) { %>
                openModal('declareSinistreModal');
            <% } else { %>
                alert("Vous devez d'abord payer votre cotisation mutuelle pour déclarer un sinistre.");
            <% } %>
        });
        document.getElementById('closeDeclareSinistreModal')?.addEventListener('click', () => closeModal('declareSinistreModal'));
        
        // Versement scolaire
        document.getElementById('addVersementScolaireBtn')?.addEventListener('click', () => openModal('versementScolaireModal'));
        document.getElementById('closeVersementScolaireModal')?.addEventListener('click', () => closeModal('versementScolaireModal'));
        
        // Paiement sanction
        function paySanction(id, amount) {
            document.getElementById('sanctionId').value = id;
            document.getElementById('sanctionAmount').value = new Intl.NumberFormat('fr-FR', {
                style: 'currency',
                currency: 'XOF'
            }).format(amount);
            openModal('paySanctionModal');
        }
        document.getElementById('closePaySanctionModal')?.addEventListener('click', () => closeModal('paySanctionModal'));
        
        // Fermer les modals en cliquant à l'extérieur
        window.addEventListener('click', (e) => {
            if (e.target.classList.contains('modal')) {
                closeModal(e.target.id);
            }
        });
        
        // Bloquer l'accès aux autres onglets si mutuelle non payée
        <% if (!hasPaidCurrentMonth) { %>
        document.querySelectorAll('.tab:not([data-tab="mutuelle"])').forEach(tab => {
            tab.addEventListener('click', (e) => {
                e.preventDefault();
                alert("Vous devez d'abord payer votre cotisation mutuelle pour accéder à cette section.");
                document.querySelector('.tab[data-tab="mutuelle"]').click();
            });
        });
        <% } %>
    </script>
</body>
</html>