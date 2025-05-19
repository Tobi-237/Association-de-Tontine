<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="utils.DBConnection" %>

<%
// Initialisation des variables
String tableName = "members";
String tableName1 = "tontines";
String paymentsTable = "paiements";
String tontineAdherentsTable = "tontine_adherents1";
int activeMembers = 0;
int activeTontines = 0;
int totalContributions = 0;
int totalSubscribers = 0;

// Récupération des données pour les statistiques
try {
    Connection conn = DBConnection.getConnection();
    
    // Nombre total de membres
    String sql = "SELECT COUNT(*) AS active_members FROM " + tableName;
    PreparedStatement stmt = conn.prepareStatement(sql);
    ResultSet rs = stmt.executeQuery();
    if (rs.next()) activeMembers = rs.getInt("active_members");
    rs.close();
    stmt.close();
    
    // Nombre total de tontines
    sql = "SELECT COUNT(*) AS active_tontines FROM " + tableName1;
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) activeTontines = rs.getInt("active_tontines");
    rs.close();
    stmt.close();
    
    // Total des cotisations
    sql = "SELECT SUM(montant) AS total_cotisations FROM " + paymentsTable + 
          " WHERE type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) totalContributions = rs.getInt("total_cotisations");
    rs.close();
    stmt.close();
    
    // Nombre total de souscripteurs
    sql = "SELECT COUNT(DISTINCT member_id) AS total_souscripteurs FROM " + tontineAdherentsTable;
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) totalSubscribers = rs.getInt("total_souscripteurs");
    rs.close();
    stmt.close();
    
    conn.close();
} catch (SQLException e) {
    e.printStackTrace();
}

// Vérification de la session utilisateur
HttpSession userSession = request.getSession(false);
if (userSession == null || userSession.getAttribute("email") == null) {
    response.sendRedirect("login.jsp");
    return;
}

String role = (String) userSession.getAttribute("role");
if (!"MEMBER".equals(role)) {
    response.sendRedirect("error.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Admin - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/chart.js">
    <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%); 
            height: 100vh; 
            overflow-x: hidden; 
        }
        
        .sidebar {
           width: 260px;
           background: rgba(44, 62, 80, 0.9);
           color: white;
           padding: 20px;
           display: flex;
           flex-direction: column;
           align-items: center;
           height: 100vh;
           position: fixed;
           left: 0;
           top: 0;
           z-index: 1000;
        }

        .sidebar h2 {
            text-align: center;
            margin-bottom: 20px;
            font-size: 22px;
            color: #fff;
            width: 100%;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
        }

        .sidebar a {
            text-decoration: none;
            color: white;
            padding: 12px;
            width: 100%;
            text-align: left;
            display: block;
            margin: 8px 0;
            background: rgba(255,255,255,0.1);
            border-radius: 5px;
            font-size: 16px;
            transition: all 0.3s ease;
            box-sizing: border-box;
            border-left: 3px solid transparent;
        }

        .sidebar a:hover {
            background: rgba(255,255,255,0.2);
            transform: translateX(5px);
            border-left: 3px solid #4CAF50;
        }

        .sidebar a i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
            color: #4CAF50;
        }
        
        .dropdown {
            width: 100%;
            position: relative;
        }

        .dropdown-toggle {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .dropdown-content {
            display: none;
            margin-left: 15px;
            width: calc(100% - 15px);
            background: rgba(0,0,0,0.1);
            border-radius: 5px;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .dropdown:hover .dropdown-content {
            display: block;
        }

        .dropdown-content a {
            background: transparent;
            margin: 4px 0;
            padding: 10px 15px;
            font-size: 14px;
        }

        .dropdown-content a:hover {
            background: rgba(255,255,255,0.2);
        }
        
        .main-content {
            margin-left: 260px;
            padding: 30px;
            min-height: 100vh;
        }
        
        .welcome-container {
            background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
            position: relative;
            overflow: hidden;
        }
        
        .welcome-container::before {
            content: "";
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: rotate 15s linear infinite;
        }
        
        @keyframes rotate {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        .welcome-text {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 15px;
            position: relative;
            text-shadow: 0 2px 4px rgba(0,0,0,0.2);
            animation: fadeIn 1.5s ease-in-out;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .welcome-subtext {
            font-size: 1.2rem;
            opacity: 0.9;
            position: relative;
            animation: fadeIn 1.5s ease-in-out 0.3s both;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        
        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: #4CAF50;
            background: rgba(76, 175, 80, 0.1);
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #2E7D32;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 1rem;
            color: #666;
        }
        
        .charts-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .chart-card {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
        }
        
        .chart-title {
            font-size: 1.2rem;
            margin-bottom: 20px;
            color: #2E7D32;
            display: flex;
            align-items: center;
        }
        
        .chart-title i {
            margin-right: 10px;
            color: #4CAF50;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            
            .main-content {
                margin-left: 0;
            }
            
            .charts-container {
                grid-template-columns: 1fr;
            }
        }
        
        .sidebar {
           width: 260px;
           background: rgba(44, 62, 80, 0.9);
           color: white;
           padding: 20px;
           display: flex;
           flex-direction: column;
           align-items: center;
           height: 100vh;
           position: fixed;
           left: 0;
           top: 0;
           z-index: 1000;
        }

        /* ... (le reste du CSS reste inchangé) ... */
        
        .chart-container {
            height: 300px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2><i class="fas fa-users"></i> GO-FAR Utilisateur</h2>
        <a href="admin.jsp"><i class="fas fa-home"></i> ACCUEIL</a>
        <a href="adherentmember.jsp"><i class="fas fa-user-friends"></i> LES MEMBRES</a>
        
        <div class="dropdown">
            <a href="#" class="dropdown-toggle"><i class="fas fa-hand-holding-usd"></i> TONTINES <i class="fas fa-chevron-down"></i></a>
            <div class="dropdown-content">
                <a href="payementsouscription.jsp"><i class="fas fa-money-bill-wave"></i> Payé les frais de tontine</a>
                <a href="cotisation.jsp"><i class="fas fa-coins"></i> Cotisations</a>
                <a href="souscription.jsp"><i class="fas fa-list"></i> Liste des tontines</a>
            </div>
        </div>
        
        <a href="infopersonnelle.jsp"><i class="fas fa-user-circle"></i> INFORMATION PERSONNELLE</a>
        <a href="declarerSinistre.jsp"><i class="fas fa-user-circle"></i> Assurance</a>
        <a href="member_discussion.jsp"><i class="fas fa-user-circle"></i>DISCUTIONS INFO</a>
        <a href="rapport.jsp"><i class="fas fa-chart-bar"></i> RAPPORTS</a>
        <a href="propos.jsp"><i class="fas fa-info-circle"></i> A PROPOS</a>	
        <a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Deconnexion</a>
    </div>

    <div class="main-content">
        <div class="welcome-container">
           <h1 class="welcome-text">
    <i class="fas fa-sack-dollar" style="margin-right: 15px; animation: spin 2s ease-in-out infinite;"></i>
                      Bienvenue dans GO-FAR Association
                 </h1>
           
            <p class="welcome-subtext" style="margin-left: 100px;">
                Ensemble pour un avenir financier meilleur et solidaire
                <i class="fas fa-heart" style="margin-left: 10px; color: #FFD700; animation: pulse 1.5s ease-in-out infinite;"></i>
            </p>
        </div>
        
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-value"><%= activeMembers %></div>
                <div class="stat-label">Membres Actifs</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-hand-holding-usd"></i>
                </div>
               <div class="stat-value"><%= activeTontines %></div>
                <div class="stat-label">Tontines Actives</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-coins"></i>
                </div>
                <div class="stat-value"><%= totalContributions %>FCFA</div>
                <div class="stat-label">Total Cotisations</div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <div class="stat-value"><%= totalSubscribers %></div>
                <div class="stat-label">Nombre total de souscripteurs</div>
            </div>
        </div>
        
        <div class="charts-container">
            <div class="chart-card">
                <h3 class="chart-title"><i class="fas fa-chart-line"></i> Évolution des Paiements</h3>
                <div class="chart-container">
                    <canvas id="paymentsChart"></canvas>
                </div>
            </div>
            
            <div class="chart-card">
                <h3 class="chart-title"><i class="fas fa-chart-pie"></i> Répartition des Souscriptions</h3>
                <div class="chart-container">
                    <canvas id="subscriptionsChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // Animation keyframes
        const style = document.createElement('style');
        style.innerHTML = `
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            
            @keyframes pulse {
                0% { transform: scale(1); }
                50% { transform: scale(1.3); }
                100% { transform: scale(1); }
            }
        `;
        document.head.appendChild(style);
        
        // Données pour les graphiques (à remplacer par des données réelles si possible)
        const paymentData = {
            labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc'],
            datasets: [{
                label: 'Paiements (FCFA)',
                data: [45000, 58000, 62000, 75000, 82000, 93000, 105000, 98000, 110000, 125000, 140000, 160000],
                backgroundColor: 'rgba(76, 175, 80, 0.2)',
                borderColor: 'rgba(76, 175, 80, 1)',
                borderWidth: 2,
                tension: 0.4,
                fill: true
            }]
        };
        
        const subscriptionData = {
            labels: ['Souscriptions', 'Cotisations', 'Tontines', 'Membres'],
            datasets: [{
                data: [<%= totalSubscribers %>, <%= totalContributions/1000 %>, <%= activeTontines %>, <%= activeMembers %>],
                backgroundColor: [
                    'rgba(54, 162, 235, 0.7)',
                    'rgba(255, 99, 132, 0.7)',
                    'rgba(255, 206, 86, 0.7)',
                    'rgba(75, 192, 192, 0.7)'
                ],
                borderColor: [
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 99, 132, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)'
                ],
                borderWidth: 1
            }]
        };
        
        // Configuration des graphiques
        const paymentsCtx = document.getElementById('paymentsChart').getContext('2d');
        const paymentsChart = new Chart(paymentsCtx, {
            type: 'line',
            data: paymentData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return context.dataset.label + ': ' + context.parsed.y.toLocaleString() + ' FCFA';
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return value.toLocaleString() + ' FCFA';
                            }
                        }
                    }
                }
            }
        });

        const subscriptionsCtx = document.getElementById('subscriptionsChart').getContext('2d');
        const subscriptionsChart = new Chart(subscriptionsCtx, {
            type: 'doughnut',
            data: subscriptionData,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                const label = context.label || '';
                                const value = context.raw || 0;
                                const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                const percentage = Math.round((value / total) * 100);
                                return `${label}: ${value} (${percentage}%)`;
                            }
                        }
                    }
                },
                cutout: '60%',
            }
        });
    </script>
</body>
</html>