<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page session="true" %>
<%@ page import="java.io.File" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import= "org.apache.commons.lang3.*" %>
<%@ page import= "servlets.SinistreServlet" %>
<%
// Vérifier si l'utilisateur est connecté
Integer memberId = (Integer) session.getAttribute("memberId");
String memberRole = (String) session.getAttribute("role");
if (memberId == null) {
    response.sendRedirect("login.jsp");
    return;
}

// Formatage des nombres et dates
NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
SimpleDateFormat monthFormat = new SimpleDateFormat("yyyy-MM");

// Variables pour les données
boolean isAdmin = "ADMIN".equals(memberRole);

// Chemin pour stocker les images
String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
File uploadDir = new File(uploadPath);
if (!uploadDir.exists()) {
    uploadDir.mkdir();
}
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Assurances | Tontine GO-FAR</title>
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
        
        .icon-info {
            background: linear-gradient(135deg, #3498db, #2980b9);
        }
        
        .icon-purple {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
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
             /* Ajout de styles pour l'affichage des images */
        .image-preview-container {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }
        
        .image-preview {
            position: relative;
            width: 100px;
            height: 100px;
            border: 1px dashed #ddd;
            border-radius: 5px;
            overflow: hidden;
        }
        
        .image-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .remove-image {
            position: absolute;
            top: 2px;
            right: 2px;
            background: rgba(0,0,0,0.5);
            color: white;
            border: none;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
        }
        
        .file-upload {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }
        
        .file-upload-label {
            display: inline-block;
            padding: 10px 15px;
            background: #f5f5f5;
            border: 1px dashed #ddd;
            border-radius: 5px;
            cursor: pointer;
            text-align: center;
            transition: all 0.3s;
        }
        
        .file-upload-label:hover {
            background: #e9e9e9;
            border-color: #ccc;
        }
        
        .file-upload-input {
            display: none;
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
        
        
/* ===== DROPDOWN MENU ===== */
.dropdown {
	position: relative;
	display: inline-block;
	margin-bottom: 1rem;
}

.dropdown-btn {
	background: #3498db;
	color: white;
	padding: 0.75rem 1.25rem;
	border: none;
	border-radius: 0.375rem;
	cursor: pointer;
	font-size: 0.9rem;
	display: flex;
	align-items: center;
	gap: 0.5rem;
}

.dropdown-content {
	display: none;
	position: absolute;
	background-color: white;
	min-width: 200px;
	box-shadow: 0px 8px 16px 0px rgba(0, 0, 0, 0.2);
	z-index: 1;
	border-radius: 0.375rem;
	overflow: hidden;
}

.dropdown-content a {
	color: #333;
	padding: 0.75rem 1rem;
	text-decoration: none;
	display: block;
	transition: background-color 0.3s;
	display: flex;
	align-items: center;
	gap: 0.5rem;
	font-size: 0.85rem;
}

.dropdown-content a:hover {
	background-color: #f1f1f1;
}

.dropdown:hover .dropdown-content {
	display: block;
}

.dropdown:hover .dropdown-btn {
	background-color: #2980b9;
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
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="header animated">
            <h2><i class="fas fa-shield-alt"></i> Gestion des Assurances</h2>
            <% if (isAdmin) { %>
            <button class="btn btn-primary" id="openModalBtn">
                <i class="fas fa-plus"></i> Nouvelle Assurance
            </button>
            <% } %>
            <div class="dropdown">
			<button class="dropdown-btn">
				<i class="fas fa-cog"></i> message Membre <i
					class="fas fa-chevron-down"></i>
			</button>
			<div class="dropdown-content">
				<a href="gestionSinistres.jsp"> <i class="fas fa-save"></i>
					membres en cours
				</a>
			</div>
		</div>
            
        </div>
        
        <!-- Affichage des messages -->
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success animated">
                <i class="fas fa-check-circle"></i>
                <div><%= session.getAttribute("successMessage") %></div>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error animated">
                <i class="fas fa-exclamation-circle"></i>
                <div><%= session.getAttribute("errorMessage") %></div>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <!-- Cartes de statistiques -->
        <div class="stats-container">
            <%
                BigDecimal totalPrimeAssurance = BigDecimal.ZERO;
                int nombreAssurances = 0;
                BigDecimal montantCagnotte = BigDecimal.ZERO;
                int nombreSinistres = 0;
                BigDecimal montantIndemnisation = BigDecimal.ZERO;
                
                try (Connection conn = DBConnection.getConnection()) {
                    // Récupérer les statistiques des assurances
                    String sql = "SELECT COUNT(*) as count, SUM(prime_mensuelle) as total FROM assurances WHERE statut = 'ACTIVE'";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                nombreAssurances = rs.getInt("count");
                                totalPrimeAssurance = rs.getBigDecimal("total");
                                if (totalPrimeAssurance == null) totalPrimeAssurance = BigDecimal.ZERO;
                            }
                        }
                    }
                    
                    // Récupérer le montant de la cagnotte assurance
                    sql = "SELECT SUM(montant) as total FROM versements_assurance";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                montantCagnotte = rs.getBigDecimal("total");
                                if (montantCagnotte == null) montantCagnotte = BigDecimal.ZERO;
                            }
                        }
                    }
                    
                    // Récupérer les statistiques des sinistres
                    sql = "SELECT COUNT(*) as count, SUM(montant_indemnisation) as total FROM sinistres";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                nombreSinistres = rs.getInt("count");
                                montantIndemnisation = rs.getBigDecimal("total");
                                if (montantIndemnisation == null) montantIndemnisation = BigDecimal.ZERO;
                            }
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            %>
            
            <div class="stat-card animated delay-1">
                <div class="stat-icon icon-primary floating">
                    <i class="fas fa-umbrella"></i>
                </div>
                <div class="stat-content">
                    <h3>Assurances Actives</h3>
                    <p><%= nombreAssurances %></p>
                </div>
            </div>
            
            <div class="stat-card animated delay-2">
                <div class="stat-icon icon-success floating" style="animation-delay: 0.3s;">
                    <i class="fas fa-hand-holding-usd"></i>
                </div>
                <div class="stat-content">
                    <h3>Total Primes</h3>
                    <p><%= nf.format(totalPrimeAssurance) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card animated delay-3">
                <div class="stat-icon icon-info floating" style="animation-delay: 0.6s;">
                    <i class="fas fa-piggy-bank"></i>
                </div>
                <div class="stat-content">
                    <h3>Cagnotte Assurance</h3>
                    <p><%= nf.format(montantCagnotte) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card animated delay-4">
                <div class="stat-icon icon-purple floating" style="animation-delay: 0.9s;">
                    <i class="fas fa-file-invoice-dollar"></i>
                </div>
                <div class="stat-content">
                    <h3>Indemnisations</h3>
                    <p><%= nf.format(montantIndemnisation) %> FCFA</p>
                </div>
            </div>
        </div>
        
        <!-- Onglets -->
        <div class="tabs">
            <div class="tab active" data-tab="assurances">Mes Assurances</div>
            <div class="tab" data-tab="versements">Versements Assurance</div>
            <% if (isAdmin) { %>
            
            <div class="tab" data-tab="compagnies">Compagnies d'Assurance</div>
            <% } %>
        </div>
        
        <!-- Contenu des onglets -->
        <div class="tab-content active" id="assurances">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-list-ul"></i> Mes Contrats d'Assurance
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Type Assurance</th>
                                <th>Montant Couverture</th>
                                <th>Prime Mensuelle</th>
                                <th>Date Début</th>
                                <th>Date Fin</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                	String sql = "SELECT a.*, m.nom, m.prenom " +
                                	           "FROM assurances a " +
                                	           "JOIN members m ON a.member_id = m.id " +
                                	            
                                	           "ORDER BY a.date_debut DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                       
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="7" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun contrat d'assurance trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                                                    String statutClass = "";
                                                    if ("ACTIVE".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-success";
                                                    } else if ("EXPIRED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-warning";
                                                    } else if ("CANCELLED".equals(rs.getString("statut"))) {
                                                        statutClass = "badge-danger";
                                                    }
                            %>
                                            <tr>
                                                <td><%= rs.getString("type_assurance") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_couverture")) %> FCFA</td>
                                                <td><%= nf.format(rs.getBigDecimal("prime_mensuelle")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getTimestamp("date_debut")) %></td>
                                                <td><%= rs.getDate("date_fin") != null ? sdf.format(rs.getTimestamp("date_fin")) : "Indéterminée" %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <button class="btn btn-outline btn-sm" onclick="viewAssuranceDetails(<%= rs.getInt("id") %>)">
                                                        <i class="fas fa-eye"></i> Détails
                                                    </button>
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
        
        <div class="tab-content" id="versements">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-money-bill-wave"></i> Mes Versements d'Assurance
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Date Versement</th>
                                <th>Montant</th>
                                <th>Type Assurance</th>
                                <th>Méthode Paiement</th>
                                <th>Référence</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                	String sql = "SELECT v.*, a.type_assurance " +
                                	           "FROM versements_assurance v " +
                                	           "JOIN assurances a ON v.assurance_id = a.id " +
                                	           "ORDER BY v.date_versement DESC";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="5" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun versement d'assurance trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                            %>
                                            <tr>
                                                <td><%= sdf.format(rs.getTimestamp("date_versement")) %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= rs.getString("type_assurance") %></td>
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
        </div>
        
        <% if (isAdmin) { %>
        
        <div class="tab-content" id="compagnies">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-building"></i> Compagnies d'Assurance Partenaires
                    </div>
                    <button class="btn btn-primary" id="openCompagnieModalBtn">
                        <i class="fas fa-plus"></i> Ajouter Compagnie
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Nom</th>
                                <th>Contact</th>
                                <th>Email</th>
                                <th>Téléphone</th>
                                <th>Type Contrat</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT * FROM compagnies_assurance ORDER BY nom";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="6" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucune compagnie enregistrée</h4>
                                                </td>
                                            </tr>
                            <%
                                            } else {
                                                while (rs.next()) {
                            %>
                                            <tr>
                                                <td><%= rs.getString("nom") %></td>
                                                <td><%= rs.getString("contact_personne") %></td>
                                                <td><%= rs.getString("email") %></td>
                                                <td><%= rs.getString("telephone") %></td>
                                                <td><%= rs.getString("type_contrat") %></td>
                                                <td>
                                                    <button class="btn btn-outline btn-sm" onclick="viewCompagnieDetails(<%= rs.getInt("id") %>)">
                                                        <i class="fas fa-eye"></i> Détails
                                                    </button>
                                                    <button class="btn btn-danger btn-sm" onclick="deleteCompagnie(<%= rs.getInt("id") %>)">
                                                        <i class="fas fa-trash"></i> Supprimer
                                                    </button>
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
        <% } %>
    </div>
    
    <!-- Modal Nouvelle Assurance -->
    <div class="modal" id="assuranceModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-plus"></i> Nouveau Contrat d'Assurance
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <form id="assuranceForm" action="saveAssurance.jsp" method="POST">
                    <div class="form-group">
                        <label class="form-label">Type d'Assurance</label>
                        <select class="form-control" name="type_assurance" required>
                            <option value="">Sélectionner un type</option>
                            <option value="DECES">Assurance Décès</option>
                            <option value="EMPRUNT">Assurance Emprunt</option>
                            <option value="PARTENARIAT">Assurance Partenariat</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Membre</label>
                        <select class="form-control" name="member_id" required>
                            <option value="">Sélectionner un membre</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT member_id, nom, prenom FROM members WHERE isMember = 0 ORDER BY nom";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            while (rs.next()) {
                            %>
                                            <option value="<%= rs.getInt("member_id") %>"><%= rs.getString("prenom") + " " + rs.getString("nom") %></option>
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
                        <label class="form-label">Montant de Couverture (FCFA)</label>
                        <input type="number" class="form-control" name="montant_couverture" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Prime Mensuelle (FCFA)</label>
                        <input type="number" class="form-control" name="prime_mensuelle" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date Début</label>
                        <input type="date" class="form-control" name="date_debut" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date Fin (optionnel)</label>
                        <input type="date" class="form-control" name="date_fin">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Compagnie d'Assurance (si partenaire)</label>
                        <select class="form-control" name="compagnie_id">
                            <option value="">Aucune (Assurance Interne)</option>
                            <%
                                try (Connection conn = DBConnection.getConnection()) {
                                    String sql = "SELECT id, nom FROM compagnies_assurance ORDER BY nom";
                                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                        try (ResultSet rs = ps.executeQuery()) {
                                            while (rs.next()) {
                            %>
                                            <option value="<%= rs.getInt("id") %>"><%= rs.getString("nom") %></option>
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
                        <label class="form-label">Notes</label>
                        <textarea class="form-control" name="notes" rows="3"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" id="closeModalBtn">Annuler</button>
                <button class="btn btn-primary" type="submit" form="assuranceForm">Enregistrer</button>
            </div>
        </div>
    </div>
    
      
    
    <!-- Modal Nouvelle Compagnie d'Assurance -->
    <div class="modal" id="compagnieModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-building"></i> Ajouter une Compagnie d'Assurance
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <form id="compagnieForm" action="saveCompagnies.jsp" method="POST">
                    <div class="form-group">
                        <label class="form-label">Nom de la Compagnie</label>
                        <input type="text" class="form-control" name="nom" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Personne de Contact</label>
                        <input type="text" class="form-control" name="contact_personne" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" name="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Téléphone</label>
                        <input type="tel" class="form-control" name="telephone" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Type de Contrat</label>
                        <select class="form-control" name="type_contrat" required>
                            <option value="DECES">Assurance Décès</option>
                            <option value="EMPRUNT">Assurance Emprunt</option>
                            <option value="MULTIRISQUE">Assurance Multirisque</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date Début Partenariat</label>
                        <input type="date" class="form-control" name="date_debut" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date Fin Partenariat</label>
                        <input type="date" class="form-control" name="date_fin">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Conditions Spéciales</label>
                        <textarea class="form-control" name="conditions" rows="3"></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" id="closeCompagnieModalBtn">Annuler</button>
                <button class="btn btn-primary" type="submit" form="compagnieForm">Enregistrer</button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Gestion des onglets
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => {
                tab.addEventListener('click', () => {
                    // Désactiver tous les onglets et contenus
                    document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                    document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                    
                    // Activer l'onglet cliqué
                    tab.classList.add('active');
                    const tabId = tab.getAttribute('data-tab');
                    document.getElementById(tabId).classList.add('active');
                });
            });
            
            // Gestion du modal assurance
            const assuranceModal = document.getElementById('assuranceModal');
            const openModalBtn = document.getElementById('openModalBtn');
            const closeModalBtn = document.getElementById('closeModalBtn');
            
            if (openModalBtn) {
                openModalBtn.addEventListener('click', () => {
                    assuranceModal.style.display = 'flex';
                });
            }
            
            closeModalBtn.addEventListener('click', () => {
                assuranceModal.style.display = 'none';
            });
            
         
            
            // Gestion du modal compagnie
            const compagnieModal = document.getElementById('compagnieModal');
            const openCompagnieModalBtn = document.getElementById('openCompagnieModalBtn');
            const closeCompagnieModalBtn = document.getElementById('closeCompagnieModalBtn');
            
            if (openCompagnieModalBtn) {
                openCompagnieModalBtn.addEventListener('click', () => {
                    compagnieModal.style.display = 'flex';
                });
            }
            
            closeCompagnieModalBtn.addEventListener('click', () => {
                compagnieModal.style.display = 'none';
            });
            
            // Fermer les modals en cliquant à l'extérieur
            window.addEventListener('click', (e) => {
                if (e.target === assuranceModal) {
                    assuranceModal.style.display = 'none';
                }
                if (e.target === sinistreModal) {
                    sinistreModal.style.display = 'none';
                }
                if (e.target === compagnieModal) {
                    compagnieModal.style.display = 'none';
                }
            });
        });
        
        function viewAssuranceDetails(id) {
            window.location.href = 'assuranceDetails.jsp?id=' + id;
        }
        
        function viewSinistreDetails(id) {
            window.location.href = 'sinistreDetails.jsp?id=' + id;
        }
        
        function viewCompagnieDetails(id) {
            window.location.href = 'compagnieDetails.jsp?id=' + id;
        }
        
        function payerSinistre(id) {
            if (confirm('Confirmez-vous le paiement de ce sinistre ?')) {
                window.location.href = 'payerSinistre.jsp?id=' + id;
            }
        }
        
        function deleteCompagnie(id) {
            if (confirm('Êtes-vous sûr de vouloir supprimer cette compagnie d\'assurance ?')) {
                window.location.href = 'deleteCompagnie.jsp?id=' + id;
            }
        }
        // Gestion de l'upload et prévisualisation des images
        document.getElementById('documents').addEventListener('change', function(e) {
            const container = document.getElementById('imagePreviewContainer');
            container.innerHTML = ''; // Vider le conteneur
            
            const files = e.target.files;
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                
                if (!file.type.match('image.*')) {
                    continue; // Ignorer les fichiers non-images
                }
                
                const reader = new FileReader();
                
                reader.onload = function(e) {
                    const previewDiv = document.createElement('div');
                    previewDiv.className = 'image-preview';
                    
                    const img = document.createElement('img');
                    img.src = e.target.result;
                    
                    const removeBtn = document.createElement('button');
                    removeBtn.className = 'remove-image';
                    removeBtn.innerHTML = '&times;';
                    removeBtn.onclick = function() {
                        previewDiv.remove();
                        // TODO: Supprimer le fichier de la liste des fichiers sélectionnés
                    };
                    
                    previewDiv.appendChild(img);
                    previewDiv.appendChild(removeBtn);
                    container.appendChild(previewDiv);
                }
                
                reader.readAsDataURL(file);
            }
        });
    </script>
</body>
</html>