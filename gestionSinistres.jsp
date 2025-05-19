<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.math.BigDecimal" %>

<%@ page session="true" %>

<%
// Vérifier si l'utilisateur est connecté et est admin
Integer memberId = (Integer) session.getAttribute("memberId");
String memberRole = (String) session.getAttribute("role");
if (memberId == null || !"ADMIN".equals(memberRole)) {
    response.sendRedirect("login.jsp");
    return;
}

// Formatage des nombres et dates
NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Sinistres | Tontine GO-FAR</title>
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
            margin-bottom: 40px;
            animation: fadeInDown 0.6s;
        }
        
        .header h1 {
            color: var(--primary-dark);
            font-size: 32px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .card {
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
            padding: 30px;
            margin-bottom: 40px;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
            animation: fadeInUp 0.6s;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.15);
        }
        
        .card-title {
            font-size: 24px;
            color: var(--dark-text);
            font-weight: 600;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .card-title i {
            color: var(--primary-color);
            font-size: 28px;
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
            padding: 15px;
            text-align: left;
            font-weight: 500;
            font-size: 14px;
        }
        
        .table td {
            padding: 12px 15px;
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
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            font-size: 14px;
        }
        
        .btn i {
            margin-right: 8px;
        }
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 13px;
        }
        
        .btn-primary {
            background: linear-gradient(to right, var(--primary-color), var(--primary-light));
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
        }
        
        .btn-success {
            background: linear-gradient(to right, #27ae60, #2ecc71);
            color: white;
        }
        
        .btn-success:hover {
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
            max-width: 800px;
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
        
        /* Document preview */
        .document-preview {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 20px;
        }
        
        .document-item {
            width: 150px;
            height: 150px;
            border: 1px solid #eee;
            border-radius: 8px;
            overflow: hidden;
            position: relative;
            box-shadow: 0 3px 10px rgba(0,0,0,0.1);
        }
        
        .document-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .document-item .doc-icon {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            background: #f5f5f5;
            color: var(--dark-text);
        }
        
        .document-item .doc-icon i {
            font-size: 40px;
            margin-bottom: 10px;
        }
        
        .document-item .doc-name {
            text-align: center;
            padding: 0 5px;
            font-size: 12px;
            word-break: break-all;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        @keyframes fadeInUp {
            from { 
                opacity: 0;
                transform: translateY(20px);
            }
            to { 
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes fadeInDown {
            from { 
                opacity: 0;
                transform: translateY(-20px);
            }
            to { 
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 30px 15px;
            }
            
            .header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .header h1 {
                font-size: 28px;
            }
            
            .card {
                padding: 25px;
            }
            
            .document-item {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp"%>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-file-medical"></i> Gestion des Sinistres</h1>
            <button class="btn btn-primary" id="openStatsModalBtn">
                <i class="fas fa-chart-bar"></i> Statistiques
            </button>
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
        
        <!-- Filtres -->
        <div class="card">
            <div class="card-title"><i class="fas fa-filter"></i> Filtres</div>
            <form id="filterForm" method="GET" action="gestionSinistres.jsp">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px;">
                    <div class="form-group">
                        <label class="form-label">Statut</label>
                        <select class="form-control" name="statut">
                            <option value="">Tous</option>
                            <option value="EN_COURS">En cours</option>
                            <option value="PAYE">Payé</option>
                            <option value="REJETE">Rejeté</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Type de sinistre</label>
                        <select class="form-control" name="type_sinistre">
                            <option value="">Tous</option>
                            <option value="DECES">Décès</option>
                            <option value="DEFAULT_EMPRUNT">Défaut emprunt</option>
                            <option value="MALADIE">Maladie</option>
                            <option value="ACCIDENT">Accident</option>
                            <option value="AUTRE">Autre</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date de début</label>
                        <input type="date" class="form-control" name="date_debut">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Date de fin</label>
                        <input type="date" class="form-control" name="date_fin">
                    </div>
                </div>
                
                <div style="margin-top: 20px; display: flex; gap: 15px;">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-search"></i> Appliquer les filtres
                    </button>
                    <button type="reset" class="btn btn-outline">
                        <i class="fas fa-undo"></i> Réinitialiser
                    </button>
                </div>
            </form>
        </div>
        
        <!-- Liste des sinistres -->
        <div class="card">
            <div class="card-title"><i class="fas fa-list-ul"></i> Liste des Sinistres</div>
            
            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Membre</th>
                            <th>Type</th>
                            <th>Montant</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String statutFilter = request.getParameter("statut");
                            String typeFilter = request.getParameter("type_sinistre");
                            String dateDebutFilter = request.getParameter("date_debut");
                            String dateFinFilter = request.getParameter("date_fin");
                            
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT s.*, m.nom, m.prenom, a.type_assurance " +
                                           "FROM sinistres_mutuelle s " +
                                           "JOIN members m ON s.member_id = m.member_id " +
                                           "JOIN assurances a ON s.assurance_id = a.id " +
                                           "WHERE 1=1 ";
                                
                                if (statutFilter != null && !statutFilter.isEmpty()) {
                                    sql += " AND s.statut = '" + statutFilter + "'";
                                }
                                
                                if (typeFilter != null && !typeFilter.isEmpty()) {
                                    sql += " AND s.type_sinistre = '" + typeFilter + "'";
                                }
                                
                                if (dateDebutFilter != null && !dateDebutFilter.isEmpty()) {
                                    sql += " AND s.date_sinistre >= '" + dateDebutFilter + "'";
                                }
                                
                                if (dateFinFilter != null && !dateFinFilter.isEmpty()) {
                                    sql += " AND s.date_sinistre <= '" + dateFinFilter + "'";
                                }
                                
                                sql += " ORDER BY s.date_sinistre DESC";
                                
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                        %>
                                        <tr>
                                            <td colspan="6" style="text-align: center; padding: 40px;">
                                                <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                <h4>Aucun sinistre trouvé</h4>
                                            </td>
                                        </tr>
                        <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = "";
                                                if ("PAYE".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-success";
                                                } else if ("EN_COURS".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-warning";
                                                } else if ("REJETE".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-danger";
                                                }
                        %>
                                        <tr>
                                            <td><%= sdf.format(rs.getTimestamp("date_sinistre")) %></td>
                                            <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                            <td><%= rs.getString("type_sinistre") %></td>
                                            <td><%= nf.format(rs.getBigDecimal("montant_indemnisation")) %> FCFA</td>
                                            <td>
                                                <span class="badge <%= statutClass %>">
                                                    <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                </span>
                                            </td>
                                            <td>
                                                <button class="btn btn-info btn-sm" onclick="viewSinistreDetails(<%= rs.getInt("id") %>)">
                                                    <i class="fas fa-eye"></i> Détails
                                                </button>
                                                <% if ("EN_COURS".equals(rs.getString("statut"))) { %>
                                                <button class="btn btn-success btn-sm" onclick="payerSinistre(<%= rs.getInt("id") %>)">
                                                    <i class="fas fa-check"></i> Payer
                                                </button>
                                                <button class="btn btn-danger btn-sm" onclick="rejeterSinistre(<%= rs.getInt("id") %>)">
                                                    <i class="fas fa-times"></i> Rejeter
                                                </button>
                                                <% } %>
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
    
    <!-- Modal Détails Sinistre -->
    <div class="modal" id="sinistreDetailsModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-file-medical"></i> Détails du Sinistre
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body" id="sinistreDetailsContent">
                <!-- Le contenu sera chargé via AJAX -->
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" id="closeDetailsModalBtn">Fermer</button>
            </div>
        </div>
    </div>
    
    <!-- Modal Statistiques -->
    <div class="modal" id="statsModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-chart-bar"></i> Statistiques des Sinistres
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <div class="modal-body">
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-bottom: 30px;">
                    <%
                        int totalSinistres = 0;
                        int sinistresEnCours = 0;
                        int sinistresPayes = 0;
                        int sinistresRejetes = 0;
                        BigDecimal totalIndemnisation = BigDecimal.ZERO;
                        
                        try (Connection conn = DBConnection.getConnection()) {
                            // Total sinistres
                            String sql = "SELECT COUNT(*) as total FROM sinistres_mutuelle";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        totalSinistres = rs.getInt("total");
                                    }
                                }
                            }
                            
                            // Sinistres par statut
                            sql = "SELECT statut, COUNT(*) as count FROM sinistres_mutuelle GROUP BY statut";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                                        if ("EN_COURS".equals(rs.getString("statut"))) {
                                            sinistresEnCours = rs.getInt("count");
                                        } else if ("PAYE".equals(rs.getString("statut"))) {
                                            sinistresPayes = rs.getInt("count");
                                        } else if ("REJETE".equals(rs.getString("statut"))) {
                                            sinistresRejetes = rs.getInt("count");
                                        }
                                    }
                                }
                            }
                            
                            // Total indemnisation
                            sql = "SELECT SUM(montant_indemnisation) as total FROM sinistres_mutuelle WHERE statut = 'PAYE'";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    if (rs.next()) {
                                        totalIndemnisation = rs.getBigDecimal("total");
                                        if (totalIndemnisation == null) totalIndemnisation = BigDecimal.ZERO;
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    %>
                    
                    <div style="background: rgba(39, 174, 96, 0.1); padding: 20px; border-radius: 10px; border-left: 4px solid var(--success);">
                        <div style="font-size: 14px; color: var(--light-text); margin-bottom: 5px;">Total Sinistres</div>
                        <div style="font-size: 28px; font-weight: 700; color: var(--success);"><%= totalSinistres %></div>
                    </div>
                    
                    <div style="background: rgba(243, 156, 18, 0.1); padding: 20px; border-radius: 10px; border-left: 4px solid var(--warning);">
                        <div style="font-size: 14px; color: var(--light-text); margin-bottom: 5px;">En Cours</div>
                        <div style="font-size: 28px; font-weight: 700; color: var(--warning);"><%= sinistresEnCours %></div>
                    </div>
                    
                    <div style="background: rgba(39, 174, 96, 0.1); padding: 20px; border-radius: 10px; border-left: 4px solid var(--success);">
                        <div style="font-size: 14px; color: var(--light-text); margin-bottom: 5px;">Payés</div>
                        <div style="font-size: 28px; font-weight: 700; color: var(--success);"><%= sinistresPayes %></div>
                    </div>
                    
                    <div style="background: rgba(231, 76, 60, 0.1); padding: 20px; border-radius: 10px; border-left: 4px solid var(--danger);">
                        <div style="font-size: 14px; color: var(--light-text); margin-bottom: 5px;">Rejetés</div>
                        <div style="font-size: 28px; font-weight: 700; color: var(--danger);"><%= sinistresRejetes %></div>
                    </div>
                    
                    <div style="background: rgba(52, 152, 219, 0.1); padding: 20px; border-radius: 10px; border-left: 4px solid var(--info); grid-column: 1 / -1;">
                        <div style="font-size: 14px; color: var(--light-text); margin-bottom: 5px;">Total Indemnisations</div>
                        <div style="font-size: 28px; font-weight: 700; color: var(--info);"><%= nf.format(totalIndemnisation) %> FCFA</div>
                    </div>
                </div>
                
                <h3 style="margin-bottom: 15px; color: var(--primary-dark);">Répartition par type</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                    <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT type_sinistre, COUNT(*) as count FROM sinistres_mutuelle GROUP BY type_sinistre";
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                try (ResultSet rs = ps.executeQuery()) {
                                    while (rs.next()) {
                                        String type = rs.getString("type_sinistre");
                                        int count = rs.getInt("count");
                    %>
                                    <div style="background: rgba(155, 89, 182, 0.1); padding: 15px; border-radius: 8px;">
                                        <div style="font-size: 13px; color: var(--light-text);"><%= type %></div>
                                        <div style="font-size: 22px; font-weight: 700; color: #9b59b6;"><%= count %></div>
                                    </div>
                    <%
                                    }
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    %>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline" id="closeStatsModalBtn">Fermer</button>
            </div>
        </div>
    </div>

    <script>
        // Gestion des modals
        const sinistreDetailsModal = document.getElementById('sinistreDetailsModal');
        const statsModal = document.getElementById('statsModal');
        const openStatsModalBtn = document.getElementById('openStatsModalBtn');
        const closeDetailsModalBtn = document.getElementById('closeDetailsModalBtn');
        const closeStatsModalBtn = document.getElementById('closeStatsModalBtn');
        
        // Ouvrir le modal des statistiques
        if (openStatsModalBtn) {
            openStatsModalBtn.addEventListener('click', () => {
                statsModal.style.display = 'flex';
            });
        }
        
        // Fermer les modals
        if (closeDetailsModalBtn) {
            closeDetailsModalBtn.addEventListener('click', () => {
                sinistreDetailsModal.style.display = 'none';
            });
        }
        
        if (closeStatsModalBtn) {
            closeStatsModalBtn.addEventListener('click', () => {
                statsModal.style.display = 'none';
            });
        }
        
        // Fermer en cliquant à l'extérieur
        window.addEventListener('click', (e) => {
            if (e.target === sinistreDetailsModal) {
                sinistreDetailsModal.style.display = 'none';
            }
            if (e.target === statsModal) {
                statsModal.style.display = 'none';
            }
        });
        
        // Fonction pour afficher les détails d'un sinistre
        function viewSinistreDetails(id) {
            fetch('getSinistreDetails.jsp?id=' + id)
                .then(response => response.text())
                .then(data => {
                    document.getElementById('sinistreDetailsContent').innerHTML = data;
                    sinistreDetailsModal.style.display = 'flex';
                })
                .catch(error => {
                    console.error('Error:', error);
                    document.getElementById('sinistreDetailsContent').innerHTML = 
                        '<div style="color: var(--danger); text-align: center; padding: 20px;">' +
                        '   <i class="fas fa-exclamation-triangle" style="font-size: 40px; margin-bottom: 15px;"></i>' +
                        '   <p>Une erreur est survenue lors du chargement des détails du sinistre.</p>' +
                        '</div>';
                    sinistreDetailsModal.style.display = 'flex';
                });
        }
        
        // Fonction pour payer un sinistre
        function payerSinistre(id) {
            if (confirm('Confirmez-vous le paiement de ce sinistre ? Cette action est irréversible.')) {
                window.location.href = 'payerSinistre.jsp?id=' + id;
            }
        }
        
        // Fonction pour rejeter un sinistre
        function rejeterSinistre(id) {
            const raison = prompt('Veuillez indiquer la raison du rejet :');
            if (raison !== null && raison.trim() !== '') {
                window.location.href = 'rejeterSinistre.jsp?id=' + id + '&raison=' + encodeURIComponent(raison);
            }
        }
        
        // Animation au chargement
        document.addEventListener('DOMContentLoaded', function() {
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, index) => {
                card.style.animationDelay = `${index * 0.1}s`;
            });
        });
    </script>
</body>
</html>