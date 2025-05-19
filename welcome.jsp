<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet, java.sql.SQLException" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.util.ArrayList" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tableau de Bord - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>
    <style>
        :root {
            --primary-color: #2ecc71;
            --primary-dark: #27ae60;
            --primary-light: #d5f5e3;
            --secondary-color: #34495e;
            --accent-color: #f1c40f;
            --light-color: #ffffff;
            --light-gray: #f5f5f5;
            --dark-gray: #95a5a6;
            --shadow: 0 10px 20px rgba(0,0,0,0.1);
            --transition: all 0.3s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--light-gray);
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--secondary-color), #2c3e50);
            color: var(--light-color);
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow);
            z-index: 10;
            position: relative;
            transition: var(--transition);
        }
        
        .sidebar h2 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 24px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .sidebar h2 i {
            margin-right: 10px;
            color: var(--primary-color);
        }
        
        .sidebar-nav {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .sidebar a {
            text-decoration: none;
            color: var(--light-color);
            padding: 15px 20px;
            margin: 5px 0;
            border-radius: 8px;
            font-size: 16px;
            display: flex;
            align-items: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .sidebar a i {
            width: 25px;
            font-size: 18px;
            margin-right: 15px;
            text-align: center;
        }
        
        .sidebar a:hover {
            background: rgba(255,255,255,0.1);
            transform: translateX(5px);
        }
        
        .sidebar a:hover::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: var(--primary-color);
        }
        
        .sidebar a.active {
            background: var(--primary-color);
            font-weight: 500;
        }
        
        .logout-btn {
            margin-top: auto;
            background: rgba(231, 76, 60, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .logout-btn:hover {
            background: rgba(231, 76, 60, 1);
        }
        
        /* Main Content Styles */
        .content {
            flex: 1;
            padding: 40px;
            overflow-y: auto;
            background-color: var(--light-gray);
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: var(--secondary-color);
            font-size: 28px;
            font-weight: 600;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            background: var(--light-color);
            padding: 10px 15px;
            border-radius: 30px;
            box-shadow: var(--shadow);
            cursor: pointer;
        }
        
        .user-profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }
        
        .user-profile span {
            font-weight: 500;
            color: var(--secondary-color);
        }
        
        /* Stats Cards */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .stat-box {
            background: var(--light-color);
            padding: 25px;
            border-radius: 12px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .stat-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }
        
        .stat-box::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, rgba(255,255,255,0.3), transparent);
            opacity: 0;
            transition: var(--transition);
        }
        
        .stat-box:hover::after {
            opacity: 1;
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            background: var(--primary-light);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            color: var(--primary-dark);
            font-size: 24px;
            transition: var(--transition);
        }
        
        .stat-box:hover .stat-icon {
            transform: scale(1.1);
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .stat-info h3 {
            font-size: 14px;
            color: var(--dark-gray);
            font-weight: 500;
            margin-bottom: 5px;
        }
        
        .stat-info h2 {
            font-size: 28px;
            color: var(--secondary-color);
            font-weight: 600;
        }
        
        /* Charts Container */
        .charts-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .chart-box {
            background: var(--light-color);
            border-radius: 12px;
            box-shadow: var(--shadow);
            padding: 25px;
            transition: var(--transition);
        }
        
        .chart-box:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }
        
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .chart-header h2 {
            color: var(--secondary-color);
            font-size: 18px;
            font-weight: 600;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            width: 100%;
        }
        
        /* Table Styles */
        .table-container {
            background: var(--light-color);
            border-radius: 12px;
            box-shadow: var(--shadow);
            padding: 25px;
            margin-top: 30px;
            transition: var(--transition);
        }
        
        .table-container:hover {
            box-shadow: 0 15px 30px rgba(0,0,0,0.15);
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .table-header h2 {
            color: var(--secondary-color);
            font-size: 22px;
            font-weight: 600;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            background: var(--primary-light);
            color: var(--secondary-color);
            font-weight: 600;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid var(--primary-color);
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            color: var(--secondary-color);
        }
        
        tr:hover td {
            background: var(--primary-light);
        }
        
        .validate-btn {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        
        .validate-btn i {
            margin-right: 5px;
        }
        
        .validate-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 5px 10px rgba(46, 204, 113, 0.3);
        }
        
        .reject-btn {
            background: #e74c3c;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        
        .reject-btn i {
            margin-right: 5px;
        }
        
        .reject-btn:hover {
            background: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 5px 10px rgba(231, 76, 60, 0.3);
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 0;
            color: var(--dark-gray);
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 20px;
            color: var(--primary-light);
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .animated {
            animation: fadeIn 0.8s ease-out forwards;
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
        
        /* Responsive Adjustments */
        @media (max-width: 1200px) {
            .charts-container {
                grid-template-columns: 1fr;
            }
        }
        
        @media (max-width: 992px) {
            .sidebar {
                width: 80px;
                padding: 20px 10px;
            }
            
            .sidebar h2 span, .sidebar a span {
                display: none;
            }
            
            .sidebar a {
                justify-content: center;
                padding: 15px 5px;
            }
            
            .sidebar a i {
                margin-right: 0;
                font-size: 20px;
            }
        }
        
        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }
            
            .stats-container {
                grid-template-columns: 1fr;
            }
            
            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2><i class="fas fa-hand-holding-usd"></i> <span>Tontine GO-FAR</span></h2>
        
        <div class="sidebar-nav">
            <a href="welcome.jsp" class="active"><i class="fas fa-home"></i> <span>ACCUEIL</span></a>
            <a href="adherents.jsp"><i class="fas fa-users"></i> <span>ADHERENTS</span></a>
            <a href="tontine.jsp"><i class="fas fa-piggy-bank"></i> <span>TONTINE</span></a>
            <a href="syntheseTontine.jsp"><i class="fas fa-chart-pie"></i> <span>SYNTHESE TONTINE</span></a>
            <a href="assurance.jsp"><i class="fas fa-shield-alt"></i> <span>ASSURANCE</span></a>
            <a href="messages.jsp"><i class="fas fa-envelope"></i> <span>MESSAGES</span></a>
            <a href="admin_discussion.jsp"><i class="fas fa-gavel"></i> <span>DISCUTION INFO</span></a>
            <a href="payecotisation.jsp"><i class="fas fa-graduation-cap"></i> <span>paye cotisation</span></a>
            <a href="caisse.jsp"><i class="fas fa-book"></i> <span>CAISSE</span></a>
            <a href="LogoutServlet" class="logout-btn"><i class="fas fa-sign-out-alt"></i> <span>DECONNEXION</span></a>
        </div>
    </div>

<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("email") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String role = (String) userSession.getAttribute("role");
    if (!"ADMIN".equals(role)) {
        response.sendRedirect("error.jsp");
        return;
    }

    int nombreAdherents = 0;
    int nombreTontines = 0;
    int nombreOperations = 0;
    List<Map<String, Object>> evolutionData = new ArrayList<>();
    Map<String, Integer> statsData = new HashMap<>();

    try (Connection conn = DBConnection.getConnection()) {
        // Compter le nombre total d'adhérents en attente
        String sqlCountAdherents = "SELECT COUNT(*) AS total FROM members WHERE isMember = 0";
        try (PreparedStatement psCount = conn.prepareStatement(sqlCountAdherents); ResultSet rsCount = psCount.executeQuery()) {
            if (rsCount.next()) {
                nombreAdherents = rsCount.getInt("total");
                statsData.put("Adhérents", nombreAdherents);
            }
        }

        // Compter le nombre total de tontines
        String sqlCountTontines = "SELECT COUNT(*) AS total FROM tontines";
        try (PreparedStatement psTontine = conn.prepareStatement(sqlCountTontines); ResultSet rsTontine = psTontine.executeQuery()) {
            if (rsTontine.next()) {
                nombreTontines = rsTontine.getInt("total");
                statsData.put("Tontines", nombreTontines);
            }
        }

        // Compter le nombre total d'opérations
        String sqlCountOperations = "SELECT COUNT(*) AS total FROM paiements";
        try (PreparedStatement psOperations = conn.prepareStatement(sqlCountOperations); ResultSet rsOperations = psOperations.executeQuery()) {
            if (rsOperations.next()) {
                nombreOperations = rsOperations.getInt("total");
                statsData.put("Opérations", nombreOperations);
            }
        }

        // Récupérer les données pour la courbe d'évolution (exemple: membres par mois)
        String sqlEvolution = "SELECT DATE_FORMAT(created_at, '%Y-%m') AS mois, COUNT(*) AS nombre " +
                             "FROM members WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) " +
                             "GROUP BY mois ORDER BY mois";
        try (PreparedStatement psEvolution = conn.prepareStatement(sqlEvolution); ResultSet rsEvolution = psEvolution.executeQuery()) {
            while (rsEvolution.next()) {
                Map<String, Object> dataPoint = new HashMap<>();
                dataPoint.put("mois", rsEvolution.getString("mois"));
                dataPoint.put("nombre", rsEvolution.getInt("nombre"));
                evolutionData.add(dataPoint);
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

    <div class="content">
        <div class="header">
            <h1 class="animated">Tableau de Bord Administrateur</h1>
            <div class="user-profile pulse">
                <img src="https://ui-avatars.com/api/?name=TOBIAS+VANEL&background=2ecc71&color=fff" alt="Profile">
                <span>TOBIAS VANEL</span>
            </div>
        </div>

        <div class="stats-container">
            <div class="stat-box animated" style="animation-delay: 0.1s;">
                <div class="stat-icon">
                    <i class="fas fa-users"></i>
                </div>
                <div class="stat-info">
                    <h3>Adhérents en attente</h3>
                    <h2><%= nombreAdherents %></h2>
                </div>
            </div>
            
            <div class="stat-box animated" style="animation-delay: 0.2s;">
                <div class="stat-icon">
                    <i class="fas fa-piggy-bank"></i>
                </div>
                <div class="stat-info">
                    <h3>Tontines actives</h3>
                    <h2><%= nombreTontines %></h2>
                </div>
            </div>
            
            <div class="stat-box animated" style="animation-delay: 0.3s;">
                <div class="stat-icon">
                    <i class="fas fa-exchange-alt"></i>
                </div>
                <div class="stat-info">
                    <h3>Opérations totales</h3>
                    <h2><%= nombreOperations %></h2>
                </div>
            </div>
        </div>

        <div class="charts-container">
            <div class="chart-box animated" style="animation-delay: 0.4s;">
                <div class="chart-header">
                    <h2><i class="fas fa-chart-line"></i> Évolution des adhésions</h2>
                </div>
                <div class="chart-container">
                    <canvas id="evolutionChart"></canvas>
                </div>
            </div>
            
            <div class="chart-box animated" style="animation-delay: 0.5s;">
                <div class="chart-header">
                    <h2><i class="fas fa-chart-pie"></i> Répartition des données</h2>
                </div>
                <div class="chart-container">
                    <canvas id="statsChart"></canvas>
                </div>
            </div>
        </div>

        <div class="table-container animated" style="animation-delay: 0.6s;">
            <div class="table-header">
                <h2><i class="fas fa-user-clock"></i> Candidats en attente de validation</h2>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nom</th>
                        <th>Prénom</th>
                        <th>Email</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        boolean hasData = false;
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT * FROM members WHERE statut IS NULL";
                            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                                while (rs.next()) {
                                    hasData = true;
                    %>
                    <tr>
                        <td><%= rs.getInt("id") %></td>
                        <td><%= rs.getString("nom") %></td>
                        <td><%= rs.getString("prenom") %></td>
                        <td><%= rs.getString("email") %></td>
                        <td>
                            <form action="ValidateUserServlet" method="post" style="display: inline-block; margin-right: 5px;">
                                <input type="hidden" name="userId" value="<%= rs.getInt("id") %>">
                                <input type="hidden" name="action" value="validate">
                                <button type="submit" class="validate-btn"><i class="fas fa-check"></i> Valider</button>
                            </form>
                            <form action="ValidateUserServlet" method="post" style="display: inline-block;">
                                <input type="hidden" name="userId" value="<%= rs.getInt("id") %>">
                                <input type="hidden" name="action" value="reject">
                                <button type="submit" class="reject-btn"><i class="fas fa-times"></i> Supprimer</button>
                            </form>
                        </td>
                    </tr>
                    <%
                                }
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        if (!hasData) {
                    %>
                    <tr>
                        <td colspan="5">
                            <div class="empty-state">
                                <i class="fas fa-user-slash"></i>
                                <h3>Aucun candidat en attente trouvé</h3>
                                <p>Tous les membres ont été validés ou aucun n'a encore postulé.</p>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        // Animation pour les éléments
        document.addEventListener('DOMContentLoaded', function() {
            const animatedElements = document.querySelectorAll('.animated');
            animatedElements.forEach((el, index) => {
                el.style.opacity = '0';
            });
            
            setTimeout(() => {
                animatedElements.forEach((el, index) => {
                    setTimeout(() => {
                        el.style.opacity = '1';
                    }, index * 100);
                });
            }, 300);
        });

        // Courbe d'évolution
        const evolutionCtx = document.getElementById('evolutionChart').getContext('2d');
        const evolutionChart = new Chart(evolutionCtx, {
            type: 'line',
            data: {
                labels: [<%
                    for (int i = 0; i < evolutionData.size(); i++) {
                        out.print("'" + evolutionData.get(i).get("mois") + "'");
                        if (i < evolutionData.size() - 1) out.print(", ");
                    }
                %>],
                datasets: [{
                    label: 'Nouveaux adhérents',
                    data: [<%
                        for (int i = 0; i < evolutionData.size(); i++) {
                            out.print(evolutionData.get(i).get("nombre"));
                            if (i < evolutionData.size() - 1) out.print(", ");
                        }
                    %>],
                    backgroundColor: 'rgba(46, 204, 113, 0.2)',
                    borderColor: 'rgba(46, 204, 113, 1)',
                    borderWidth: 3,
                    tension: 0.4,
                    fill: true,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: 'rgba(46, 204, 113, 1)',
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                },
                animation: {
                    duration: 2000,
                    easing: 'easeOutQuart'
                }
            }
        });

        // Diagramme semi-circulaire
        const statsCtx = document.getElementById('statsChart').getContext('2d');
        const statsChart = new Chart(statsCtx, {
            type: 'doughnut',
            data: {
                labels: ['Adhérents en attente', 'Tontines actives', 'Opérations totales'],
                datasets: [{
                    data: [<%= nombreAdherents %>, <%= nombreTontines %>, <%= nombreOperations %>],
                    backgroundColor: [
                        'rgba(52, 152, 219, 0.8)',
                        'rgba(155, 89, 182, 0.8)',
                        'rgba(46, 204, 113, 0.8)'
                    ],
                    borderColor: [
                        'rgba(52, 152, 219, 1)',
                        'rgba(155, 89, 182, 1)',
                        'rgba(46, 204, 113, 1)'
                    ],
                    borderWidth: 2,
                    hoverOffset: 20
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            padding: 20,
                            usePointStyle: true,
                            pointStyle: 'circle'
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let label = context.label || '';
                                if (label) {
                                    label += ': ';
                                }
                                label += context.raw;
                                return label;
                            }
                        }
                    }
                },
                animation: {
                    animateScale: true,
                    animateRotate: true,
                    duration: 2000
                }
            }
        });

        // Effet de survol sur les cartes
        const statBoxes = document.querySelectorAll('.stat-box');
        statBoxes.forEach(box => {
            box.addEventListener('mouseenter', function() {
                this.style.transform = 'translateY(-10px)';
                this.style.boxShadow = '0 20px 40px rgba(0,0,0,0.2)';
            });
            
            box.addEventListener('mouseleave', function() {
                this.style.transform = 'translateY(-5px)';
                this.style.boxShadow = '0 15px 30px rgba(0,0,0,0.15)';
            });
        });
    </script>
</body>
</html>