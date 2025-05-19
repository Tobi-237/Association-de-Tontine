<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="utils.DBConnection" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Liste des Adhérents - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2ecc71;
            --primary-dark: #27ae60;
            --primary-light: #d5f5e3;
            --white: #ffffff;
            --light-gray: #f8f9fa;
            --dark-gray: #343a40;
            --shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
            --magic-shadow: 0 5px 15px rgba(46, 204, 113, 0.4);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Montserrat', sans-serif;
            background-color: #f5f5f5;
            display: flex;
            min-height: 100vh;
            color: var(--dark-gray);
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

        .sidebar::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 70%);
            animation: magicPulse 8s infinite alternate;
        }

        @keyframes magicPulse {
            0% { transform: scale(0.8); opacity: 0.5; }
            100% { transform: scale(1.2); opacity: 0.8; }
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            z-index: 1;
        }

        .sidebar-header i {
            font-size: 28px;
            margin-right: 15px;
            color: var(--white);
            text-shadow: 0 0 10px rgba(255,255,255,0.3);
            transition: var(--transition);
        }

        .sidebar-header:hover i {
            transform: rotate(15deg) scale(1.1);
            text-shadow: 0 0 15px rgba(255,255,255,0.5);
        }

        .sidebar-header h2 {
            font-size: 22px;
            font-weight: 600;
            text-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }

        .sidebar-menu {
            flex: 1;
            position: relative;
            z-index: 1;
        }

        .sidebar a {
            display: flex;
            align-items: center;
            text-decoration: none;
            color: var(--white);
            padding: 15px;
            margin: 8px 0;
            border-radius: 8px;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .sidebar a::after {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
            transition: 0.5s;
        }

        .sidebar a:hover::after {
            left: 100%;
        }

        .sidebar a i {
            margin-right: 12px;
            font-size: 18px;
            width: 24px;
            text-align: center;
            transition: var(--transition);
        }

        .sidebar a:hover {
            background: rgba(255, 255, 255, 0.15);
            transform: translateX(5px);
        }

        .sidebar a:hover i {
            color: #f1c40f;
            transform: scale(1.2);
        }

        .sidebar a.active {
            background: var(--white);
            color: var(--primary-dark);
            font-weight: 500;
            box-shadow: var(--magic-shadow);
        }

        .content {
            flex: 1;
            padding: 40px;
             margin-left:280px;
            overflow-y: auto;
            background-color: var(--light-gray);
            animation: fadeIn 0.8s ease-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            animation: slideInDown 0.6s ease-out;
        }

        @keyframes slideInDown {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .header h1 {
            color: var(--primary-dark);
            font-size: 28px;
            font-weight: 700;
            display: flex;
            align-items: center;
            text-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .header h1 i {
            margin-right: 15px;
            color: var(--primary-color);
            animation: bounce 2s infinite;
        }

        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% { transform: translateY(0); }
            40% { transform: translateY(-10px); }
            60% { transform: translateY(-5px); }
        }

        .card-container {
            background: var(--white);
            border-radius: 12px;
            padding: 30px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
            transform: perspective(1000px) rotateX(5deg);
            transition: var(--transition);
            animation: cardAppear 0.8s ease-out;
        }

        .card-container:hover {
            transform: perspective(1000px) rotateX(0deg);
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
        }

        @keyframes cardAppear {
            from { opacity: 0; transform: perspective(1000px) rotateX(30deg); }
            to { opacity: 1; transform: perspective(1000px) rotateX(5deg); }
        }

        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            border-radius: 12px;
           
            overflow: hidden;
            animation: tableFadeIn 1s ease-out;
        }

        @keyframes tableFadeIn {
            from { opacity: 0; transform: scale(0.98); }
            to { opacity: 1; transform: scale(1); }
        }

        thead {
            background: linear-gradient(to right, var(--primary-color), var(--primary-dark));
            color: var(--white);
        }

        th {
            padding: 18px 15px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 0.5px;
            position: relative;
        }

        th:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: rgba(255,255,255,0.3);
        }

        th i {
            margin-right: 8px;
            transition: var(--transition);
        }

        th:hover i {
            transform: rotate(360deg);
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
            transition: var(--transition);
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background: var(--primary-light);
            transform: translateX(5px);
        }

        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #7f8c8d;
            animation: fadeIn 1s ease-out;
        }

        .empty-state i {
            font-size: 60px;
            color: #bdc3c7;
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        .empty-state h3 {
            font-size: 22px;
            margin-bottom: 15px;
            color: var(--dark-gray);
        }

        .status-badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            animation: badgePulse 2s infinite;
        }

        @keyframes badgePulse {
            0% { box-shadow: 0 0 0 0 rgba(46, 204, 113, 0.4); }
            70% { box-shadow: 0 0 0 10px rgba(46, 204, 113, 0); }
            100% { box-shadow: 0 0 0 0 rgba(46, 204, 113, 0); }
        }

        .status-active {
            background: #d5f5e3;
            color: var(--primary-dark);
        }

        .status-inactive {
            background: #fadbd8;
            color: #e74c3c;
        }

        .member-status {
            background: #eaf2f8;
            color: #2980b9;
        }

        .non-member-status {
            background: #f5eef8;
            color: #8e44ad;
        }

        .magic-hover {
            transition: var(--transition);
        }

        .magic-hover:hover {
            transform: translateY(-3px);
            box-shadow: var(--magic-shadow);
        }

        /* Responsive styles */
        @media (max-width: 992px) {
            .sidebar {
                width: 80px;
                padding: 20px 10px;
                align-items: center;
            }
            
            .sidebar-header h2, 
            .sidebar a span {
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
            
            .header {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .header h1 {
                margin-bottom: 15px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebars.jsp" %>

    <%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("email") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    %>

    <div class="content">
        <div class="header">
            <h1><i class="fas fa-users"></i> Liste des Adhérents</h1>
        </div>

        <div class="card-container magic-hover">
            <div class="table-responsive">
                <%
                boolean hasData = false;
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT * FROM members WHERE statut IS NOT NULL";
                    try (PreparedStatement ps = conn.prepareStatement(sql); 
                         ResultSet rs = ps.executeQuery()) {
                        
                        if (rs.next()) {
                            hasData = true;
                            rs.beforeFirst(); // Reset cursor to beginning
                %>
                <table>
                    <thead>
                        <tr>
                            <th><i class="fas fa-id-card"></i> ID</th>
                            <th><i class="fas fa-user-tie"></i> Nom</th>
                            <th><i class="fas fa-user"></i> Prénom</th>
                            <th><i class="fas fa-envelope"></i> Email</th>
                            <th><i class="fas fa-phone"></i> Téléphone</th>
                            <th><i class="fas fa-calendar-day"></i> Inscription</th>
                            <th><i class="fas fa-map-marked-alt"></i> Localisation</th>
                            <th><i class="fas fa-info-circle"></i> Statut</th>
                            <th><i class="fas fa-users"></i> Membre</th>
                        </tr>
                    </thead>
                 <tbody>
    <% while (rs.next()) { %>
    <tr>
        <td><%= rs.getInt("member_id") != 0 ? rs.getInt("member_id") : rs.getInt("id") %></td>
        <td><%= rs.getString("nom") %></td>
        <td><%= rs.getString("prenom") %></td>
        <td><%= rs.getString("email") %></td>
        <td><%= rs.getString("numero") != null ? rs.getString("numero") : "N/A" %></td>
        <td><%= rs.getString("inscription") %></td>
        <td><%= rs.getString("localisation") != null ? rs.getString("localisation") : "N/A" %></td>
        <td>
            <span class="status-badge <%= "actif".equalsIgnoreCase(rs.getString("statut")) ? "status-active" : "status-inactive" %>">
                <i class="fas fa-<%= "actif".equalsIgnoreCase(rs.getString("statut")) ? "check" : "times" %>"></i> 
                <%= rs.getString("statut") %>
            </span>
        </td>
        <td>
            <span class="status-badge <%= rs.getBoolean("isMember") ? "member-status" : "non-member-status" %>">
                <i class="fas fa-<%= rs.getBoolean("isMember") ? "user-check" : "user-times" %>"></i> 
                <%= rs.getBoolean("isMember") ? "Membre" : "Non-membre" %>
            </span>
        </td>
    </tr>
    <% } %>
</tbody>
                </table>
                <%
                        } else {
                %>
                <div class="empty-state">
                    <i class="fas fa-user-slash"></i>
                    <h3>Aucun adhérent trouvé</h3>
                    <p>Il n'y a actuellement aucun adhérent enregistré dans le système.</p>
                </div>
                <%
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                %>
            </div>
        </div>
    </div>

    <script>
        // Ajoute une animation magique au chargement
        document.addEventListener('DOMContentLoaded', function() {
            const rows = document.querySelectorAll('tbody tr');
            rows.forEach((row, index) => {
                row.style.animationDelay = `${index * 0.1}s`;
                row.classList.add('magic-hover');
            });
        });
    </script>
</body>
</html>