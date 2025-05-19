<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
    // Vérifier si l'utilisateur est connecté
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("memberId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int memberId = (int) userSession.getAttribute("memberId");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        String sql = "SELECT nom, prenom, email, inscription, numero, localisation, statut FROM members WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, memberId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mon Profil - GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;600;700&family=Playfair+Display:wght@400;600&display=swap" rel="stylesheet">
    <style>
    :root {
        --primary-color: #2e7d32;
        --secondary-color: #81c784;
        --light-color: #f1f8e9;
        --dark-color: #1b5e20;
        --white: #ffffff;
        --shadow: 0 4px 20px rgba(46, 125, 50, 0.15);
    }

    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: 'Montserrat', sans-serif;
        background: linear-gradient(135deg, #f5faf5, #e0f2e1);
        color: #333;
        min-height: 100vh;
        overflow-x: hidden;
    }

    /* Animation d'entrée */
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }

    @keyframes float {
        0% { transform: translateY(0px); }
        50% { transform: translateY(-10px); }
        100% { transform: translateY(0px); }
    }

    @keyframes pulse {
        0% { transform: scale(1); }
        50% { transform: scale(1.05); }
        100% { transform: scale(1); }
    }

    .main-container {
        display: flex;
        min-height: 100vh;
        animation: fadeIn 1s ease-out;
    }

    /* Sidebar stylisée */
    .sidebar {
        width: 280px;
        background: var(--white);
        padding: 30px 20px;
        box-shadow: var(--shadow);
        position: relative;
        z-index: 10;
    }

    .sidebar::before {
        content: '';
        position: absolute;
        top: 0;
        right: -10px;
        width: 20px;
        height: 100%;
        background: linear-gradient(to right, rgba(255,255,255,0.8), rgba(255,255,255,0));
    }

    /* Contenu principal */
    .content {
        flex: 1;
        padding: 40px;
        display: flex;
        justify-content: center;
        align-items: center;
        position: relative;
        overflow: hidden;
    }

    /* Éléments décoratifs */
    .leaf-decoration {
        position: absolute;
        font-size: 10rem;
        color: rgba(46, 125, 50, 0.05);
        z-index: -1;
        animation: float 6s ease-in-out infinite;
    }

    .leaf-1 {
        top: 10%;
        right: 5%;
        transform: rotate(30deg);
    }

    .leaf-2 {
        bottom: 10%;
        left: 5%;
        transform: rotate(-15deg);
        animation-delay: 0.5s;
    }

    .leaf-3 {
        top: 50%;
        left: 30%;
        font-size: 8rem;
        transform: rotate(45deg);
        animation-delay: 1s;
    }

    /* Carte de profil */
    .profile-card {
        width: 100%;
        max-width: 800px;
        background: var(--white);
        border-radius: 20px;
        padding: 40px;
        box-shadow: var(--shadow);
        transition: all 0.4s ease;
        position: relative;
        overflow: hidden;
    }

    .profile-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 15px 30px rgba(46, 125, 50, 0.2);
    }

    .profile-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 8px;
        height: 100%;
        background: linear-gradient(to bottom, var(--primary-color), var(--secondary-color));
    }

    h2 {
        font-family: 'Playfair Display', serif;
        font-size: 2.5rem;
        color: var(--primary-color);
        margin-bottom: 30px;
        position: relative;
        display: inline-block;
    }

    h2::after {
        content: '';
        position: absolute;
        bottom: -10px;
        left: 0;
        width: 60%;
        height: 3px;
        background: linear-gradient(to right, var(--primary-color), var(--secondary-color));
        border-radius: 3px;
    }

    /* Tableau d'informations */
    .info-table {
        width: 100%;
        border-collapse: separate;
        border-spacing: 0 15px;
        margin: 30px 0;
    }

    .info-table th, .info-table td {
        padding: 18px 25px;
        text-align: left;
    }

    .info-table th {
        background-color: var(--primary-color);
        color: var(--white);
        font-weight: 600;
        border-radius: 8px 0 0 8px;
        position: relative;
        font-size: 0.9rem;
    }

    .info-table th i {
        margin-right: 10px;
    }

    .info-table td {
        background-color: var(--light-color);
        border-radius: 0 8px 8px 0;
        font-weight: 500;
        position: relative;
    }

    .info-table tr:hover td {
        background-color: #e8f5e9;
    }

    /* Boutons d'action */
    .action-links {
        display: flex;
        justify-content: center;
        gap: 20px;
        margin-top: 40px;
        flex-wrap: wrap;
    }

    .action-btn {
        display: inline-flex;
        align-items: center;
        padding: 12px 25px;
        text-decoration: none;
        color: var(--white);
        background: linear-gradient(135deg, var(--primary-color), var(--dark-color));
        border-radius: 50px;
        font-weight: 600;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(46, 125, 50, 0.3);
        position: relative;
        overflow: hidden;
    }

    .action-btn i {
        margin-right: 10px;
        font-size: 1.1rem;
    }

    .action-btn:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(46, 125, 50, 0.4);
    }

    .action-btn:active {
        transform: translateY(1px);
    }

    .action-btn::after {
        content: '';
        position: absolute;
        top: -50%;
        left: -50%;
        width: 200%;
        height: 200%;
        background: rgba(255, 255, 255, 0.1);
        transform: rotate(45deg);
        transition: all 0.3s ease;
    }

    .action-btn:hover::after {
        left: 100%;
    }

    .logout-btn {
        background: linear-gradient(135deg, #d32f2f, #b71c1c);
        box-shadow: 0 4px 15px rgba(211, 47, 47, 0.3);
    }

    .logout-btn:hover {
        box-shadow: 0 8px 25px rgba(211, 47, 47, 0.4);
    }

    /* Badge de statut */
    .status-badge {
        display: inline-block;
        padding: 5px 12px;
        border-radius: 50px;
        font-size: 0.8rem;
        font-weight: 600;
        text-transform: uppercase;
    }

    .status-active {
        background-color: #e8f5e9;
        color: var(--dark-color);
    }

    .status-pending {
        background-color: #fff8e1;
        color: #ff8f00;
    }

    /* Animation des icônes */
    .fa-spin-slow {
        animation: fa-spin 6s infinite linear;
    }

    /* Responsive */
    @media (max-width: 992px) {
        .main-container {
            flex-direction: column;
        }
        
        .sidebar {
            width: 100%;
            padding: 20px;
        }
        
        .content {
            padding: 30px 20px;
        }
        
        .profile-card {
            padding: 30px;
        }
        
        h2 {
            font-size: 2rem;
        }
    }

    @media (max-width: 576px) {
        .action-links {
            flex-direction: column;
            gap: 15px;
        }
        
        .action-btn {
            width: 100%;
            justify-content: center;
        }
        
        .info-table th, .info-table td {
            padding: 12px 15px;
        }
    }
    </style>
</head>
<body>
    <div class="main-container">
        <%@ include file="sidebars.jsp" %>
        
        <div class="content">
            <!-- Éléments décoratifs -->
            <i class="fas fa-leaf leaf-decoration leaf-1"></i>
            <i class="fas fa-seedling leaf-decoration leaf-2"></i>
            <i class="fas fa-spa leaf-decoration leaf-3"></i>
            
            <div class="profile-card">
                <h2><i class="fas fa-user-circle fa-spin-slow" style="color: var(--secondary-color);"></i> Mon Profil</h2>
                
                <table class="info-table">
                    <tr>
                        <th><i class="fas fa-id-card"></i> Nom</th>
                        <td><%= rs.getString("nom") %></td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-signature"></i> Prénom</th>
                        <td><%= rs.getString("prenom") %></td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-envelope"></i> Email</th>
                        <td><%= rs.getString("email") %></td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-coins"></i> Montant d'inscription</th>
                        <td><%= rs.getString("inscription") %> FCFA</td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-chart-pie"></i> numero</th>
                        <td><%= rs.getString("numero") %></td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-map-marker-alt"></i> Localisation</th>
                        <td><%= rs.getString("localisation") %></td>
                    </tr>
                    <tr>
                        <th><i class="fas fa-badge-check"></i> Statut</th>
                        <td>
                            <span class="status-badge <%= rs.getString("statut").equalsIgnoreCase("actif") ? "status-active" : "status-pending" %>">
                                <i class="fas fa-<%= rs.getString("statut").equalsIgnoreCase("actif") ? "check-circle" : "clock" %>"></i>
                                <%= rs.getString("statut") %>
                            </span>
                        </td>
                    </tr>
                </table>
                
                <div class="action-links">
                    <a href="editProfile.jsp" class="action-btn">
                        <i class="fas fa-user-edit"></i> Modifier mon profil
                    </a>
                    <a href="LogoutServlet" class="action-btn logout-btn">
                        <i class="fas fa-sign-out-alt"></i> Déconnexion
                    </a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Animation au chargement
        document.addEventListener('DOMContentLoaded', function() {
            // Animation des éléments de la carte
            const profileCard = document.querySelector('.profile-card');
            if (profileCard) {
                setTimeout(() => {
                    profileCard.style.animation = 'pulse 2s ease-in-out';
                }, 500);
            }

            // Effet de vague sur les boutons
            const buttons = document.querySelectorAll('.action-btn');
            buttons.forEach(button => {
                button.addEventListener('mouseenter', function() {
                    this.style.animation = 'pulse 0.5s ease';
                });
                
                button.addEventListener('mouseleave', function() {
                    this.style.animation = '';
                });
            });
        });
    </script>
</body>
</html>

<%
        } else {
            out.println("<p>Erreur : Informations introuvables.</p>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<p>Une erreur est survenue.</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignored) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
    }
%>