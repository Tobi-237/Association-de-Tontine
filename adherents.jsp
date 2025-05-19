<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="utils.DBConnection" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Adhérents - Tontine GO-FAR</title>
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
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        .titre {
        margin-left: -280px;
       
    text-align: center;
}
        

        body {
            font-family: 'Montserrat', sans-serif;
            background-color: #f5f5f5;
            display: flex;
            min-height: 100vh;
            color: var(--dark-gray);
        }

        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: var(--white);
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow);
            z-index: 10;
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            margin-bottom: 40px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
        }

        .sidebar-header i {
            font-size: 28px;
            margin-right: 15px;
            color: var(--white);
        }

        .sidebar-header h2 {
            font-size: 22px;
            font-weight: 600;
        }

        .sidebar-menu {
            flex: 1;
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
        }

        .sidebar a i {
            margin-right: 12px;
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        .sidebar a:hover {
            background: rgba(255, 255, 255, 0.15);
            transform: translateX(5px);
        }

        .sidebar a.active {
            background: var(--white);
            color: var(--primary-dark);
            font-weight: 500;
        }

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
            color: var(--primary-dark);
            font-size: 28px;
            font-weight: 700;
            display: flex;
            align-items: center;
        }

        .header h1 i {
            margin-right: 15px;
            color: var(--primary-color);
        }

        .add-btn {
            background: var(--primary-color);
            color: var(--white);
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            box-shadow: 0 4px 15px rgba(46, 204, 113, 0.3);
        }

        .add-btn i {
            margin-right: 10px;
        }

        .add-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(46, 204, 113, 0.4);
        }

        .card-container {
            background: var(--white);
            border-radius: 12px;
            padding: 30px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }

        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            margin-left:199px;
            border-collapse: separate;
            border-spacing: 0;
            border-radius: 12px;
            overflow: hidden;
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
        }

        th:first-child {
            border-top-left-radius: 12px;
        }

        th:last-child {
            border-top-right-radius: 12px;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            vertical-align: middle;
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background: var(--primary-light);
        }

        .action-btns {
            display: flex;
            gap: 10px;
        }

        .action-btn {
            padding: 8px 15px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: var(--transition);
            text-decoration: none;
            cursor: pointer;
        }

        .action-btn i {
            margin-right: 6px;
        }

        .edit-btn {
            background: #3498db;
            color: white;
            border: none;
        }

        .edit-btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(41, 128, 185, 0.2);
        }

        .delete-btn {
            background: #e74c3c;
            color: white;
            border: none;
        }

        .delete-btn:hover {
            background: #c0392b;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(192, 57, 43, 0.2);
        }

        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #7f8c8d;
        }

        .empty-state i {
            font-size: 60px;
            color: #bdc3c7;
            margin-bottom: 20px;
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
        }

        .status-active {
            background: #d5f5e3;
            color: var(--primary-dark);
        }

        .status-inactive {
            background: #fadbd8;
            color: #e74c3c;
        }

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
            .action-btns {
                flex-direction: column;
                gap: 5px;
            }
            
            .action-btn {
                width: 100%;
                padding: 6px 10px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

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
    %>

    <div class="content">
        <div class="header">
            <h1><i class="fas fa-users"></i> Gestion des Adhérents</h1>
            <a href="login.jsp" class="add-btn">
                <i class="fas fa-user-plus"></i> Nouvel Adhérent
            </a>
        </div>

        <div class="card-container">
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
                            <th><i class="fas fa-user"></i> Nom</th>
                            <th><i class="fas fa-user"></i> Prénom</th>
                            <th><i class="fas fa-envelope"></i> Email</th>
                            <th><i class="fas fa-calendar-alt"></i> Inscription</th>
                            <th><i class="fas fa-wallet"></i> numero</th>
                            <th><i class="fas fa-map-marker-alt"></i> Localisation</th>
                            <th><i class="fas fa-cog"></i> Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% while (rs.next()) { %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("nom") %></td>
                            <td><%= rs.getString("prenom") %></td>
                            <td><%= rs.getString("email") %></td>
                            <td><%= rs.getString("inscription") %></td>
                            <td><%= rs.getString("numero") %></td>
                            <td><%= rs.getString("localisation") %></td>
                            <td>
                                <div class="action-btns">
                                    <a href="modifier_adherent.jsp?id=<%= rs.getInt("id") %>" class="action-btn edit-btn">
                                        <i class="fas fa-edit"></i> Modifier
                                    </a>
                                    <form action="DeleteMemberServlet" method="post" style="display: inline;">
                                        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
                                        <button type="submit" class="action-btn delete-btn" 
                                                onclick="return confirm('Êtes-vous sûr de vouloir supprimer cet adhérent ?')">
                                            <i class="fas fa-trash-alt"></i> Supprimer
                                        </button>
                                    </form>
                                </div>
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
                    <a href="login.jsp" class="add-btn" style="margin-top: 20px;">
                        <i class="fas fa-user-plus"></i> Ajouter un adhérent
                    </a>
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
</body>
</html>