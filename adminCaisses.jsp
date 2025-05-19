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
    // Vérification du rôle admin
    String memberRole = (String) session.getAttribute("role");
    if (!"ADMIN".equals(memberRole)) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Formats
    NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    // Récupération des montants totaux des versements par type de caisse
    BigDecimal soldeMutuelle = BigDecimal.ZERO;
    BigDecimal soldeScolaire = BigDecimal.ZERO;
    BigDecimal soldePunition = BigDecimal.ZERO;
    
    try (Connection conn = DBConnection.getConnection()) {
        // Requête pour sommer les montants des versements validés par type de caisse
        String sql = "SELECT c.type_caisse, SUM(v.montant) as total " +
                     "FROM versements v " +
                     "JOIN caisses c ON v.caisse_id = c.id " +
                     "WHERE v.statut = 'VALIDATED' " +
                     "GROUP BY c.type_caisse";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String type = rs.getString("type_caisse");
                    BigDecimal total = rs.getBigDecimal("total");
                    if (total != null) {
                        if ("MUTUELLE".equals(type)) soldeMutuelle = total;
                        else if ("SCOLAIRE".equals(type)) soldeScolaire = total;
                        else if ("PUNITION".equals(type)) soldePunition = total;
                    }
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors de la récupération des soldes: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Caisses | Admin</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Styles CSS identiques à ceux que vous avez fournis */
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
        
        /* ... (le reste de votre CSS existant) ... */
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <div class="header">
            <h2><i class="fas fa-piggy-bank"></i> Gestion des Caisses</h2>
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
        
        <!-- Cartes de statistiques -->
        <div class="stats-container">
            <div class="stat-card">
                <div class="stat-icon icon-mutuelle">
                    <i class="fas fa-heartbeat"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Mutuelle</h3>
                    <p><%= nf.format(soldeMutuelle) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon icon-scolaire">
                    <i class="fas fa-graduation-cap"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Scolaire</h3>
                    <p><%= nf.format(soldeScolaire) %> FCFA</p>
                </div>
            </div>
            
            <div class="stat-card">
                <div class="stat-icon icon-punition">
                    <i class="fas fa-gavel"></i>
                </div>
                <div class="stat-content">
                    <h3>Caisse Punition</h3>
                    <p><%= nf.format(soldePunition) %> FCFA</p>
                </div>
            </div>
        </div>
        
        <!-- Onglets -->
        <div class="tabs">
            <div class="tab active" data-tab="mutuelle">Mutuelle</div>
            <div class="tab" data-tab="scolaire">Scolaire</div>
            <div class="tab" data-tab="punition">Punition</div>
            <div class="tab" data-tab="sinistres">Sinistres</div>
        </div>
        
        <!-- Contenu des onglets -->
        <div class="tab-content active" id="mutuelle">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-heartbeat"></i> Caisse Mutuelle
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Méthode</th>
                                <th>Référence</th>
                                <th>Statut</th>
                                <th>Preuve</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT v.*, m.nom, m.prenom " +
                                           "FROM versements v " +
                                           "JOIN members m ON v.member_id = m.member_id " +
                                           "WHERE v.caisse_id = (SELECT id FROM caisses WHERE type_caisse = 'MUTUELLE') " +
                                           "ORDER BY v.date_versement DESC";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="7" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun versement trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = "";
                                                if ("VALIDATED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-success";
                                                } else if ("PENDING".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-warning";
                                                } else if ("REJECTED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-danger";
                                                }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                                <td><%= rs.getString("methode_paiement") %></td>
                                                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (rs.getString("preuve") != null) { %>
                                                    <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-outline btn-sm">
                                                        <i class="fas fa-eye"></i> Voir
                                                    </a>
                                                    <% } else { %>
                                                    -
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
                                session.setAttribute("errorMessage", "Erreur lors de la récupération des versements mutuelle: " + e.getMessage());
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Onglet Scolaire -->
        <div class="tab-content" id="scolaire">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-graduation-cap"></i> Caisse Scolaire
                    </div>
                    <button class="btn btn-purple" type="button" id="calculInteretsBtn">
                        <i class="fas fa-calculator"></i> Calculer Intérêts
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Méthode</th>
                                <th>Référence</th>
                                <th>Statut</th>
                                <th>Preuve</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT v.*, m.nom, m.prenom " +
                                           "FROM versements v " +
                                           "JOIN members m ON v.member_id = m.member_id " +
                                           "WHERE v.caisse_id = (SELECT id FROM caisses WHERE type_caisse = 'SCOLAIRE') " +
                                           "ORDER BY v.date_versement DESC";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="7" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun versement trouvé</h4>
                                                </td>
                                            </tr>
                            <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = "";
                                                if ("VALIDATED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-success";
                                                } else if ("PENDING".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-warning";
                                                } else if ("REJECTED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-danger";
                                                }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_versement")) %></td>
                                                <td><%= rs.getString("methode_paiement") %></td>
                                                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (rs.getString("preuve") != null) { %>
                                                    <a href="<%= rs.getString("preuve") %>" target="_blank" class="btn btn-outline btn-sm">
                                                        <i class="fas fa-eye"></i> Voir
                                                    </a>
                                                    <% } else { %>
                                                    -
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
                                session.setAttribute("errorMessage", "Erreur lors de la récupération des versements scolaires: " + e.getMessage());
                            }
                            %>
                        </tbody>
                    </table>
                </div>
                
                <!-- Intérêts scolaires -->
                <div class="card-header" style="margin-top: 40px;">
                    <div class="card-title">
                        <i class="fas fa-percentage"></i> Intérêts Scolaires
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Année</th>
                                <th>Montant Initial</th>
                                <th>Taux</th>
                                <th>Intérêts</th>
                                <th>Date Calcul</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT i.*, m.nom, m.prenom " +
                                           "FROM interets_scolaires i " +
                                           "JOIN members m ON i.member_id = m.member_id " +
                                           "ORDER BY i.annee DESC, i.date_calcul DESC";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="8" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun intérêt calculé</h4>
                                                </td>
                                            </tr>
                            <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = "PENDING".equals(rs.getString("statut")) ? "badge-warning" : "badge-success";
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                                                <td><%= rs.getString("annee") %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_initial")) %> FCFA</td>
                                                <td><%= rs.getBigDecimal("taux_interet") %>%</td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_interet")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_calcul")) %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if ("PENDING".equals(rs.getString("statut"))) { %>
                                                    <button class="btn btn-success btn-sm" onclick="payerInteret(<%= rs.getInt("id") %>)">
                                                        <i class="fas fa-check"></i> Payer
                                                    </button>
                                                    <% } else { %>
                                                    <span class="badge badge-success">
                                                        <i class="fas fa-check"></i> Payé le <%= sdf.format(rs.getDate("date_paiement")) %>
                                                    </span>
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
                                session.setAttribute("errorMessage", "Erreur lors de la récupération des intérêts scolaires: " + e.getMessage());
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        
        <!-- Onglet Punition -->
        <div class="tab-content" id="punition">
            <div class="card">
                <div class="card-header">
                    <div class="card-title">
                        <i class="fas fa-gavel"></i> Caisse Punition
                    </div>
                    <button class="btn btn-danger" id="addSanctionBtn">
                        <i class="fas fa-plus"></i> Nouvelle Sanction
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Type</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT s.*, m.nom, m.prenom FROM sanctions s " +
                                           "JOIN members m ON s.member_id = m.member_id " +
                                           "ORDER BY s.date_sanction DESC";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="6" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucune sanction enregistrée</h4>
                                                </td>
                                            </tr>
                            <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = rs.getString("statut").equals("PAID") ? "badge-success" : "badge-warning";
                                                String typeSanction = "";
                                                switch(rs.getString("type_sanction")) {
                                                    case "RETARD": typeSanction = "Retard"; break;
                                                    case "BAGARRE": typeSanction = "Bagarre"; break;
                                                    case "INJURE": typeSanction = "Injure"; break;
                                                    default: typeSanction = rs.getString("type_sanction");
                                                }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                                                <td><%= typeSanction %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_sanction")) %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if (!rs.getString("statut").equals("PAID")) { %>
                                                    <button class="btn btn-sm btn-success" 
                                                            onclick="validatePayment(<%= rs.getInt("id") %>, 'sanction')">
                                                        Valider Paiement
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
                                session.setAttribute("errorMessage", "Erreur lors de la récupération des sanctions: " + e.getMessage());
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
                    <div class="card-title">
                        <i class="fas fa-file-medical"></i> Gestion des Sinistres
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Membre</th>
                                <th>Type</th>
                                <th>Montant</th>
                                <th>Date</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT s.*, m.nom, m.prenom FROM sinistres_mutuelle s " +
                                           "JOIN members m ON s.member_id = m.member_id " +
                                           "ORDER BY s.date_sinistre DESC";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        if (!rs.isBeforeFirst()) {
                            %>
                                            <tr>
                                                <td colspan="6" style="text-align: center; padding: 40px;">
                                                    <i class="fas fa-inbox" style="font-size: 40px; color: #bdc3c7; margin-bottom: 15px;"></i>
                                                    <h4>Aucun sinistre enregistré</h4>
                                                </td>
                                            </tr>
                            <%
                                        } else {
                                            while (rs.next()) {
                                                String statutClass = "";
                                                if ("APPROVED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-success";
                                                } else if ("PENDING".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-warning";
                                                } else if ("REJECTED".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-danger";
                                                } else if ("PAID".equals(rs.getString("statut"))) {
                                                    statutClass = "badge-info";
                                                }
                                                
                                                String typeSinistre = "";
                                                switch(rs.getString("type_sinistre")) {
                                                    case "HOSPITALISATION": typeSinistre = "Hospitalisation"; break;
                                                    case "DECES_MEMBRE": typeSinistre = "Décès Membre"; break;
                                                    case "DECES_CONJOINT": typeSinistre = "Décès Conjoint"; break;
                                                    case "DECES_PARENT": typeSinistre = "Décès Parent"; break;
                                                    case "DECES_ENFANT": typeSinistre = "Décès Enfant"; break;
                                                }
                            %>
                                            <tr>
                                                <td><%= rs.getString("prenom") %> <%= rs.getString("nom") %></td>
                                                <td><%= typeSinistre %></td>
                                                <td><%= nf.format(rs.getBigDecimal("montant_demande")) %> FCFA</td>
                                                <td><%= sdf.format(rs.getDate("date_sinistre")) %></td>
                                                <td>
                                                    <span class="badge <%= statutClass %>">
                                                        <%= rs.getString("statut") %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <% if ("PENDING".equals(rs.getString("statut"))) { %>
                                                        <button class="btn btn-sm btn-success" 
                                                                onclick="approuverSinistre(<%= rs.getInt("id") %>, 'APPROVED')">
                                                            Approuver
                                                        </button>
                                                        <button class="btn btn-sm btn-danger" 
                                                                onclick="approuverSinistre(<%= rs.getInt("id") %>, 'REJECTED')">
                                                            Rejeter
                                                        </button>
                                                    <% } else if ("APPROVED".equals(rs.getString("statut"))) { %>
                                                        <button class="btn btn-sm btn-info" 
                                                                onclick="payerSinistre(<%= rs.getInt("id") %>)">
                                                            Payer
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
                                session.setAttribute("errorMessage", "Erreur lors de la récupération des sinistres: " + e.getMessage());
                            }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Modal Nouvelle Sanction -->
    <div class="modal" id="sanctionModal">
        <div class="modal-content">
            <div class="modal-header">
                <div class="modal-title">
                    <i class="fas fa-gavel"></i> Nouvelle Sanction
                </div>
                <button class="modal-close">&times;</button>
            </div>
            <form id="sanctionForm" action="saveSanction.jsp" method="POST">
                <div class="modal-body">
                    <div class="form-group">
                        <label>Membre</label>
                        <select class="form-control" name="member_id" required>
                            <option value="">Sélectionner un membre</option>
                            <%
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT member_id, nom, prenom FROM members WHERE isMember = 0 ORDER BY nom";
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    try (ResultSet rs = ps.executeQuery()) {
                                        while (rs.next()) {
                            %>
                                            <option value="<%= rs.getInt("member_id") %>">
                                                <%= rs.getString("prenom") %> <%= rs.getString("nom") %>
                                            </option>
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
                        <label>Type de Sanction</label>
                        <select class="form-control" name="type_sanction" required>
                            <option value="RETARD">Retard</option>
                            <option value="BAGARRE">Bagarre</option>
                            <option value="INJURE">Injure</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Montant (FCFA)</label>
                        <input type="number" class="form-control" name="montant" required>
                    </div>
                    <div class="form-group">
                        <label>Date</label>
                        <input type="date" class="form-control" name="date_sanction" required>
                    </div>
                    <div class="form-group">
                        <label>Raison</label>
                        <textarea class="form-control" name="raison" rows="3" required></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline" id="closeSanctionModal">Annuler</button>
                    <button type="submit" class="btn btn-danger">Enregistrer</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        // Gestion des onglets
        document.querySelectorAll('.tab').forEach(tab => {
            tab.addEventListener('click', () => {
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                
                tab.classList.add('active');
                document.getElementById(tab.getAttribute('data-tab')).classList.add('active');
            });
        });
        
        // Gestion de la modal sanction
        const sanctionModal = document.getElementById('sanctionModal');
        document.getElementById('addSanctionBtn').addEventListener('click', () => {
            sanctionModal.style.display = 'flex';
        });
        
        document.getElementById('closeSanctionModal').addEventListener('click', () => {
            sanctionModal.style.display = 'none';
        });
        
        // Validation paiement
        function validatePayment(id, type) {
            Swal.fire({
                title: 'Validation de paiement',
                text: 'Confirmez-vous la validation de ce paiement ?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Oui, valider',
                cancelButtonText: 'Annuler'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = `validatePayment.jsp?id=${id}&type=${type}`;
                }
            });
        }
        
        // Fonctions pour gérer les sinistres
        function approuverSinistre(id, action) {
            Swal.fire({
                title: 'Action sur sinistre',
                text: `Confirmez-vous cette action (${action}) ?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Oui, confirmer',
                cancelButtonText: 'Annuler'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = `processSinistre.jsp?id=${id}&action=${action}`;
                }
            });
        }

        function payerSinistre(id) {
            Swal.fire({
                title: 'Paiement sinistre',
                text: 'Confirmez-vous le paiement de ce sinistre ?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Oui, payer',
                cancelButtonText: 'Annuler'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = `payerSinistre.jsp?id=${id}`;
                }
            });
        }

        // Fonction pour payer les intérêts
        function payerInteret(id) {
            Swal.fire({
                title: 'Paiement intérêts',
                text: 'Confirmez-vous le paiement de ces intérêts ?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Oui, payer',
                cancelButtonText: 'Annuler'
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = `payerInteret.jsp?id=${id}`;
                }
            });
        }
        
        // Calcul des intérêts scolaires
        document.getElementById('calculInteretsBtn').addEventListener('click', function() {
            Swal.fire({
                title: 'Calcul des intérêts scolaires',
                text: 'Voulez-vous calculer les intérêts pour l\'année en cours ?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Oui, calculer',
                cancelButtonText: 'Annuler'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Calcul en cours',
                        html: 'Veuillez patienter pendant le calcul des intérêts...',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    fetch('calculInteretsScolaires.jsp', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        }
                    })
                    .then(response => response.json())
                    .then(data => {
                        Swal.close();
                        if (data.success) {
                            Swal.fire({
                                title: 'Succès!',
                                text: data.message,
                                icon: 'success'
                            }).then(() => {
                                location.reload();
                            });
                        } else {
                            Swal.fire({
                                title: 'Erreur!',
                                text: data.message,
                                icon: 'error'
                            });
                        }
                    })
                    .catch(error => {
                        Swal.close();
                        Swal.fire({
                            title: 'Erreur!',
                            text: 'Une erreur est survenue lors du calcul: ' + error,
                            icon: 'error'
                        });
                    });
                }
            });
        });

        // Fermer modal en cliquant à l'extérieur
        window.addEventListener('click', (e) => {
            if (e.target === sanctionModal) {
                sanctionModal.style.display = 'none';
            }
        });
    </script>
</body>
</html>