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
    // Vérifier si l'utilisateur est connecté et admin
    Integer memberId = (Integer) session.getAttribute("memberId");
    String memberRole = (String) session.getAttribute("role");
    if (memberId == null || !"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Formatage des nombres et dates
    NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    // Variables pour les totaux
    BigDecimal totalCagnotte = BigDecimal.ZERO;
    BigDecimal totalBenefices = BigDecimal.ZERO;
    int totalMembres = 0;
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Cagnottes & Bénéfices | Tontine GO-FAR</title>
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
            transition: all 0.3s ease;
            z-index: 1000;
            box-shadow: 5px 0 25px rgba(0,0,0,0.1);
        }
        
        .content {
            margin-left: 280px;
            padding: 40px;
            transition: all 0.3s ease;
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
            color: var(--dark-text);
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
        
        .icon-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
        }
        
        .icon-success {
            background: linear-gradient(135deg, #27ae60, #2ecc71);
        }
        
        .icon-warning {
            background: linear-gradient(135deg, #f39c12, #f1c40f);
        }
        
        .icon-danger {
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
        
        .badge-primary {
            background: rgba(39, 174, 96, 0.1);
            color: var(--primary-color);
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
        .delay-4 { animation-delay: 0.8s; }
        
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
        }
        
        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        
        ::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 10px;
        }
        
        ::-webkit-scrollbar-thumb {
            background: var(--primary-color);
            border-radius: 10px;
        }
        
        ::-webkit-scrollbar-thumb:hover {
            background: var(--primary-dark);
        }
        
        /* Progress Bar */
        .progress-container {
            width: 100%;
            background: #f1f1f1;
            border-radius: 10px;
            margin: 15px 0;
            height: 10px;
            overflow: hidden;
        }
        
        .progress-bar {
            height: 100%;
            border-radius: 10px;
            background: linear-gradient(to right, var(--primary-color), var(--primary-light));
            transition: width 0.5s ease;
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="header animated">
            <h2><i class="fas fa-coins"></i> Cagnottes & Bénéfices</h2>
        </div>
        
        <!-- Cartes de statistiques -->
        <div class="stats-container">
            <div class="stat-card animated delay-1">
                <div class="stat-icon icon-primary floating">
                    <i class="fas fa-hand-holding-usd"></i>
                </div>
                <div class="stat-content">
                    <h3>Total Cagnotte</h3>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT SUM(montant) as total FROM paiements WHERE type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        totalCagnotte = rs.getBigDecimal("total");
                                        if (totalCagnotte == null) totalCagnotte = BigDecimal.ZERO;
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    %>
                    <p><%= nf.format(totalCagnotte) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card animated delay-2">
                <div class="stat-icon icon-success floating" style="animation-delay: 0.3s;">
                    <i class="fas fa-chart-line"></i>
                </div>
                <div class="stat-content">
                    <h3>Total Bénéfices</h3>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            // Calcul simplifié des bénéfices (30% de la cagnotte totale)
                            totalBenefices = totalCagnotte.multiply(new BigDecimal("0.3"));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                    <p><%= nf.format(totalBenefices) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card animated delay-3">
                <div class="stat-icon icon-warning floating" style="animation-delay: 0.6s;">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-content">
                    <h3>Membres Actifs</h3>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT COUNT(*) as total FROM members WHERE isMember = 1";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        totalMembres = rs.getInt("total");
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    %>
                    <p><%= nf.format(totalMembres) %></p>
                </div>
            </div>
        </div>
        
        <!-- Carte des bénéfices par membre -->
        <div class="card animated delay-2">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-user-tie"></i> Répartition des Bénéfices
                </div>
                <span class="badge badge-primary">
                    <i class="fas fa-info-circle"></i> 30% de la cagnotte
                </span>
            </div>
            
            <div class="progress-container">
                <div class="progress-bar" style="width: 30%"></div>
            </div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Membre</th>
                            <th>Cotisations</th>
                            <th>Part (%)</th>
                            <th>Bénéfice</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                // Récupérer tous les membres actifs
                                String membersSql = "SELECT id, prenom, nom, numero FROM members WHERE isMember = 1";
                                try (PreparedStatement ps = conn.prepareStatement(membersSql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                                            int mId = rs.getInt("id");
                                            String prenom = rs.getString("prenom");
                                            String nom = rs.getString("nom");
                                            BigDecimal fondCaisse = new BigDecimal(rs.getString("numero"));
                                            
                                            // Calculer le total des cotisations du membre
                                            BigDecimal cotisations = BigDecimal.ZERO;
                                            String cotisationSql = "SELECT SUM(montant) as total FROM paiements WHERE member_id = ? AND type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
                                            try (PreparedStatement cotisationPs = conn.prepareStatement(cotisationSql)) {
                                                cotisationPs.setInt(1, mId);
                                                try (ResultSet cotisationRs = cotisationPs.executeQuery()) {
                                                    if (cotisationRs.next()) {
                                                        cotisations = cotisationRs.getBigDecimal("total");
                                                        if (cotisations == null) cotisations = BigDecimal.ZERO;
                                                    }
                                                }
                                            }
                                            
                                            // Calculer la part et le bénéfice
                                            BigDecimal part = BigDecimal.ZERO;
                                            BigDecimal benefice = BigDecimal.ZERO;
                                            
                                            if (totalCagnotte.compareTo(BigDecimal.ZERO) > 0) {
                                                part = cotisations.multiply(new BigDecimal(100)).divide(totalCagnotte, 2, BigDecimal.ROUND_HALF_UP);
                                                benefice = totalBenefices.multiply(part).divide(new BigDecimal(100), 2, BigDecimal.ROUND_HALF_UP);
                                            }
                        %>
                        <tr>
                            <td><%= prenom %> <%= nom %></td>
                            <td><%= nf.format(cotisations) %> FCFA</td>
                            <td><%= part %> %</td>
                            <td><strong><%= nf.format(benefice) %> FCFA</strong></td>
                            <td>
                                <span class="badge <%= benefice.compareTo(BigDecimal.ZERO) > 0 ? "badge-success" : "badge-warning" %>">
                                    <i class="fas <%= benefice.compareTo(BigDecimal.ZERO) > 0 ? "fa-check-circle" : "fa-clock" %>"></i>
                                    <%= benefice.compareTo(BigDecimal.ZERO) > 0 ? "Éligible" : "En attente" %>
                                </span>
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
        
        <!-- Carte des dernières transactions -->
        <div class="card animated delay-3">
            <div class="card-header">
                <div class="card-title">
                    <i class="fas fa-history"></i> Dernières Cotisations
                </div>
                <span class="badge badge-primary">
                    <i class="fas fa-sync-alt"></i> Mise à jour en temps réel
                </span>
            </div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Membre</th>
                            <th>Montant</th>
                            <th>Date</th>
                            <th>Mois</th>
                            <th>Mode</th>
                            <th>Statut</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT p.*, m.prenom, m.nom FROM paiements p " +
                                           "JOIN members m ON p.member_id = m.id " +
                                           "WHERE p.type_paiement = 'COTISATION' " +
                                           "ORDER BY p.date_paiement DESC LIMIT 10";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                            <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                            <td><%= sdf.format(rs.getDate("date_paiement")) %></td>
                            <td><%= rs.getString("mois_annee") %></td>
                            <td><%= rs.getString("methode_paiement") %></td>
                            <td>
                                <span class="badge <%= "COMPLETED".equals(rs.getString("statut")) ? "badge-success" : 
                                                   "PENDING".equals(rs.getString("statut")) ? "badge-warning" : "badge-danger" %>">
                                    <i class="fas <%= "COMPLETED".equals(rs.getString("statut")) ? "fa-check-circle" : 
                                                   "PENDING".equals(rs.getString("statut")) ? "fa-clock" : "fa-times-circle" %>"></i>
                                    <%= rs.getString("statut") %>
                                </span>
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
        document.addEventListener('DOMContentLoaded', function() {
            // Animation au chargement
            const elements = document.querySelectorAll('.animated');
            elements.forEach((el, index) => {
                el.style.opacity = '0';
            });
            
            setTimeout(() => {
                elements.forEach((el, index) => {
                    el.style.opacity = '1';
                });
            }, 100);
            
            // Effet de flottement aléatoire
            const floaters = document.querySelectorAll('.floating');
            floaters.forEach((el, index) => {
                el.style.animationDelay = `${index * 0.3}s`;
            });
            
            // Menu toggle pour mobile
            const menuToggle = document.getElementById('menuToggle');
            if (menuToggle) {
                menuToggle.addEventListener('click', function() {
                    document.querySelector('.sidebar').classList.toggle('active');
                });
            }
        });
    </script>
</body>
</html>