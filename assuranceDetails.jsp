<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>

<%
// Vérifier si l'utilisateur est connecté
Integer memberId = (Integer) session.getAttribute("memberId");
if (memberId == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Récupérer l'ID de l'assurance
int assuranceId = Integer.parseInt(request.getParameter("id"));

// Formatage des nombres et dates
NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

// Variables pour les données
String typeAssurance = "";
String statut = "";
BigDecimal montantCouverture = BigDecimal.ZERO;
BigDecimal primeMensuelle = BigDecimal.ZERO;
java.util.Date dateDebut = null;
java.util.Date dateFin = null;
String notes = "";
String membreNom = "";
String membrePrenom = "";
String compagnieNom = "";

try (Connection conn = DBConnection.getConnection()) {
    // Récupérer les détails de l'assurance
    String sql = "SELECT a.*, m.nom, m.prenom, c.nom as compagnie_nom " +
               "FROM assurances a " +
               "JOIN members m ON a.member_id = m.member_id " +
               "LEFT JOIN compagnies_assurance c ON a.compagnie_id = c.id " +
               "WHERE a.id = ?";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, assuranceId);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                typeAssurance = rs.getString("type_assurance");
                statut = rs.getString("statut");
                montantCouverture = rs.getBigDecimal("montant_couverture");
                primeMensuelle = rs.getBigDecimal("prime_mensuelle");
                dateDebut = rs.getDate("date_debut");
                dateFin = rs.getDate("date_fin");
                notes = rs.getString("notes");
                membreNom = rs.getString("nom");
                membrePrenom = rs.getString("prenom");
                compagnieNom = rs.getString("compagnie_nom");
            } else {
                response.sendRedirect("assurances.jsp");
                return;
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
    <title>Détails Assurance | Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Reprendre le même style que assurances.jsp */
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
            background: var(--light-bg);
            color: var(--dark-text);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            font-size: 28px;
            color: var(--dark-text);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .card {
            background: var(--white);
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .card-title {
            font-size: 20px;
            margin-bottom: 20px;
            color: var(--dark-text);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .info-item {
            margin-bottom: 15px;
        }
        
        .info-label {
            font-size: 14px;
            color: var(--light-text);
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 16px;
            font-weight: 500;
            color: var(--dark-text);
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
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            font-size: 14px;
            text-decoration: none;
        }
        
        .btn i {
            margin-right: 8px;
        }
        
        .btn-primary {
            background: var(--primary-color);
            color: white;
        }
        
        .btn-primary:hover {
            background: var(--primary-light);
        }
        
        .btn-outline {
            background: transparent;
            border: 1px solid #ddd;
            color: var(--dark-text);
        }
        
        .btn-outline:hover {
            background: #f5f5f5;
        }
        
        .back-link {
            display: flex;
            align-items: center;
            gap: 5px;
            color: var(--light-text);
            margin-bottom: 20px;
            text-decoration: none;
        }
        
        .back-link:hover {
            color: var(--primary-color);
        }
        <style>
    :root {
        --primary-color: #2ecc71;
        --primary-dark: #27ae60;
        --primary-light: #58d68d;
        --white: #ffffff;
        --light-bg: #f5f9f7;
        --dark-text: #2c3e50;
        --light-text: #7f8c8d;
        --card-shadow: 0 15px 30px rgba(46, 204, 113, 0.15);
    }
    
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }
    
    body {
        background: linear-gradient(135deg, var(--light-bg) 0%, #e4f5ea 100%);
        min-height: 100vh;
        color: var(--dark-text);
        overflow-x: hidden;
    }
    
    .content {
        padding: 40px;
        animation: fadeIn 0.8s ease-out;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: var(--primary-dark);
        margin-bottom: 25px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.3s;
    }
    
    .back-link:hover {
        color: var(--primary-color);
        transform: translateX(-5px);
    }
    
    .back-link i {
        transition: all 0.3s;
    }
    
    .header {
        margin-bottom: 40px;
    }
    
    .header h1 {
        font-size: 2.5rem;
        color: var(--dark-text);
        position: relative;
        display: inline-block;
    }
    
    .header h1:after {
        content: "";
        position: absolute;
        bottom: -10px;
        left: 0;
        width: 80px;
        height: 4px;
        background: linear-gradient(to right, var(--primary-color), var(--primary-light));
        border-radius: 3px;
    }
    
    .header h1 i {
        color: var(--primary-color);
        margin-right: 15px;
    }
    
    .card {
        background: var(--white);
        border-radius: 16px;
        box-shadow: var(--card-shadow);
        padding: 30px;
        margin-bottom: 30px;
        position: relative;
        overflow: hidden;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
    }
    
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 40px rgba(46, 204, 113, 0.2);
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
    
    .card-title {
        font-size: 1.5rem;
        margin-bottom: 25px;
        color: var(--dark-text);
        display: flex;
        align-items: center;
        gap: 15px;
    }
    
    .card-title i {
        color: var(--primary-color);
        font-size: 1.8rem;
    }
    
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 25px;
    }
    
    .info-item {
        padding: 20px;
        background: rgba(255, 255, 255, 0.7);
        border-radius: 12px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.03);
        transition: all 0.3s;
        border: 1px solid rgba(46, 204, 113, 0.1);
    }
    
    .info-item:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(46, 204, 113, 0.1);
        border-color: rgba(46, 204, 113, 0.2);
    }
    
    .info-label {
        font-size: 0.9rem;
        color: var(--light-text);
        margin-bottom: 8px;
        font-weight: 500;
    }
    
    .info-value {
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--dark-text);
    }
    
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 12px 24px;
        border-radius: 50px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.4s;
        border: none;
        font-size: 1rem;
        text-decoration: none;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    }
    
    .btn i {
        margin-right: 10px;
        transition: all 0.3s;
    }
    
    .btn-danger {
        background: linear-gradient(135deg, #e74c3c, #c0392b);
        color: white;
    }
    
    .btn-danger:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(231, 76, 60, 0.3);
    }
    
    .btn-danger:active {
        transform: translateY(1px);
    }
    
    /* Animation pour les éléments d'information */
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
    }
    
    .info-item {
        animation: slideIn 0.6s ease-out forwards;
        opacity: 0;
    }
    
    .info-item:nth-child(1) { animation-delay: 0.1s; }
    .info-item:nth-child(2) { animation-delay: 0.2s; }
    .info-item:nth-child(3) { animation-delay: 0.3s; }
    .info-item:nth-child(4) { animation-delay: 0.4s; }
    .info-item:nth-child(5) { animation-delay: 0.5s; }
    .info-item:nth-child(6) { animation-delay: 0.6s; }
    .info-item:nth-child(7) { animation-delay: 0.7s; }
    
    /* Effet de vague décoratif */
    .card:after {
        content: "";
        position: absolute;
        bottom: -50px;
        right: -50px;
        width: 150px;
        height: 150px;
        background: radial-gradient(circle, rgba(46, 204, 113, 0.1) 0%, rgba(46, 204, 113, 0) 70%);
        border-radius: 50%;
        z-index: 0;
    }

    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <a href="assurance.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> Retour à la liste
        </a>
        
        <div class="header">
            <h1>
                <i class="fas fa-shield-alt"></i> Détails du Contrat d'Assurance
            </h1>
        </div>
        
        <div class="card">
            <h2 class="card-title">Informations de Base</h2>
            
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Type d'Assurance</div>
                    <div class="info-value"><%= typeAssurance %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Statut</div>
                    <div class="info-value">
                        <%
                            String statutClass = "";
                            if ("ACTIVE".equals(statut)) {
                                statutClass = "badge-success";
                            } else if ("EXPIRED".equals(statut)) {
                                statutClass = "badge-warning";
                            } else if ("CANCELLED".equals(statut)) {
                                statutClass = "badge-danger";
                            }
                        %>
                        <span class="badge <%= statutClass %>">
                            <i class="fas fa-circle"></i> <%= statut %>
                        </span>
                    </div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Montant Couverture</div>
                    <div class="info-value"><%= nf.format(montantCouverture) %> FCFA</div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Prime Mensuelle</div>
                    <div class="info-value"><%= nf.format(primeMensuelle) %> FCFA</div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Date Début</div>
                    <div class="info-value"><%= sdf.format(dateDebut) %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Date Fin</div>
                    <div class="info-value"><%= dateFin != null ? sdf.format(dateFin) : "Indéterminée" %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Membre</div>
                    <div class="info-value"><%= membrePrenom + " " + membreNom %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Compagnie</div>
                    <div class="info-value"><%= compagnieNom != null ? compagnieNom : "Assurance Interne" %></div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">Notes</h2>
            <p><%= notes != null && !notes.isEmpty() ? notes : "Aucune note disponible" %></p>
        </div>
        
        <div class="card">
            <h2 class="card-title">Historique des Versements</h2>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Montant</th>
                        <th>Méthode Paiement</th>
                        <th>Référence</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT * FROM versements_assurance WHERE assurance_id = ? ORDER BY date_versement DESC";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                ps.setInt(1, assuranceId);
                                
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (!rs.isBeforeFirst()) {
                    %>
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 20px;">
                                            Aucun versement enregistré pour ce contrat
                                        </td>
                                    </tr>
                    <%
                                    } else {
                                        while (rs.next()) {
                    %>
                                    <tr>
                                        <td><%= sdf.format(rs.getTimestamp("date_versement")) %></td>
                                        <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                        <td><%= rs.getString("methode_paiement") %></td>
                                        <td><%= rs.getString("reference") %></td>
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
</body>
</html>