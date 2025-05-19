<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, models.*, java.text.SimpleDateFormat, java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mes Transactions - Membre</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
                  --primary-color: #2e7d32;
            --primary-light: #60ad5e;
            --primary-dark: #005005;
            --secondary-color: #f5f5f5;
            --text-color: #333;
            --white: #ffffff;
            --success: #4caf50;
            --warning: #ff9800;
            --danger: #f44336;
            --info: #2196f3;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: #f9f9f9;
            color: var(--text-color);
        }

        .container {
    display: flex;
    min-height: 100vh;
    background-color: #f4f7f6;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

        .sidebar {
            width: 250px;
            background-color: var(--primary-color);
            color: var(--white);
            padding: 20px 0;
            transition: all 0.3s ease;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
        }

        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header h3 {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 1.2rem;
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .menu-item:hover, .menu-item.active {
            background-color: var(--primary-light);
        }

        .menu-item i {
            width: 20px;
            text-align: center;
        }

.main-content {
    flex: 1;
    padding: 30px;
    margin-left: 289px;
 background-color: #27ae60; /* Vert foncé stylé */
color: blue;
    border-top-left-radius: 25px;
    border-bottom-left-radius: 25px;
    box-shadow: -3px 0 10px rgba(0, 0, 0, 0.05);
    animation: fadeIn 0.8s ease-in-out;
}   
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 1px solid #ddd;
        }

        .header h1 {
            color: var(--primary-color);
            font-size: 1.8rem;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .user-info img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .card {
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            padding: 20px;
            margin-bottom: 20px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .card-header h2 {
            font-size: 1.3rem;
            color: var(--primary-color);
        }

        .card-header .btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .card-header .btn:hover {
            background-color: var(--primary-dark);
        }

        .table-responsive {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        th {
            background-color: var(--primary-color);
            color: white;
            font-weight: 500;
        }

        tr:hover {
            background-color: #f5f5f5;
        }

        .badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 500;
            text-transform: uppercase;
        }

        .badge-success {
            background-color: #e8f5e9;
            color: var(--success);
        }

        .badge-warning {
            background-color: #fff8e1;
            color: var(--warning);
        }

        .badge-danger {
            background-color: #ffebee;
            color: var(--danger);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-light);
            box-shadow: 0 0 0 2px rgba(46, 125, 50, 0.2);
        }

        .btn-group {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
        }

        .btn-secondary {
            background-color: #757575;
            color: white;
            border: none;
        }

        .btn-secondary:hover {
            background-color: #616161;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            border-radius: 8px;
            width: 90%;
            max-width: 600px;
            max-height: 90vh;
            overflow-y: auto;
            padding: 20px;
            animation: modalFadeIn 0.3s ease;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .modal-header h2 {
            color: var(--primary-color);
        }

        .close {
            font-size: 1.5rem;
            cursor: pointer;
            color: #757575;
        }

 .stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
    animation: slideUp 0.8s ease-in-out;
}

        .stat-card {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 15px;
            font-size: 1.5rem;
            color: white;
        }

        .stat-icon.income {
            background-color: var(--success);
        }

        .stat-icon.expense {
            background-color: var(--danger);
        }

        .stat-icon.members {
            background-color: var(--info);
        }

        .stat-value {
            font-size: 1.8rem;
            font-weight: 600;
            margin-bottom: 5px;
            color: var(--primary-color);
        }

        .stat-label {
            color: #757575;
            font-size: 0.9rem;
        }

       .chart-container {
    height: 300px;
    margin-bottom: 30px;
    background-color: #e8fdf1;
    border-radius: 20px;
    box-shadow: 0 5px 15px rgba(46, 204, 113, 0.15);
    padding: 20px;
    animation: fadeIn 1s ease;
}
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(20px); }
    to { opacity: 1; transform: translateY(0); }
}

@keyframes slideUp {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
}
        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px 20px;
            border-radius: 4px;
            color: white;
            font-weight: 500;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            z-index: 1100;
            animation: slideIn 0.3s ease, fadeOut 0.5s ease 3s forwards;
        }

        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }

        @keyframes fadeOut {
            to {
                opacity: 0;
                visibility: hidden;
            }
        }

        .notification.success {
            background-color: var(--success);
        }

        .notification.error {
            background-color: var(--danger);
        }

        .notification.warning {
            background-color: var(--warning);
        }

        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 20px;
            gap: 5px;
        }

        .page-item {
            list-style: none;
        }

        .page-link {
            padding: 8px 12px;
            border: 1px solid #ddd;
            color: var(--primary-color);
            text-decoration: none;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .page-link:hover {
            background-color: #f5f5f5;
        }

        .page-item.active .page-link {
            background-color: var(--primary-color);
            color: white;
            border-color: var(--primary-color);
        }

        .search-filter {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .search-box {
            flex: 1;
            min-width: 250px;
            position: relative;
        }

        .search-box i {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #757575;
        }

        .search-box input {
            padding-left: 35px;
        }

        .filter-box {
            min-width: 200px;
        }

        .invoice {
            border: 1px solid #eee;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            background-color: white;
        }

        .invoice-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .invoice-title {
            color: var(--primary-color);
            font-weight: 600;
        }

        .invoice-status {
            font-weight: 500;
        }

        .invoice-body {
            margin-bottom: 20px;
        }

        .invoice-footer {
            display: flex;
            justify-content: flex-end;
        }

        @media (max-width: 768px) {
            .container {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                padding: 10px 0;
            }
            .sidebar-menu {
                display: flex;
                overflow-x: auto;
                padding: 10px 0;
            }
            .menu-item {
                white-space: nowrap;
                padding: 10px 15px;
            }
            .stats-container {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<%@ include file="sidebars.jsp" %>
  <!-- Main Content -->
        <div class="main-content">
         <h3><i class="fas fa-user-circle"></i> Mon Espace</h3>
            <div class="header">
                <h1><i class="fas fa-chart-line"></i> Mes Rapports Financiers</h1>
                <div class="user-info">
                    <%
                        // Récupération des infos du membre connecté
                        String memberName = "Membre";
                        int memberId = 0;
                        
                        if(session.getAttribute("member_id") != null) {
                            memberId = (Integer) session.getAttribute("member_id");
                            
                            try {
                                Connection conn = DBConnection.getConnection();
                                String query = "SELECT prenom, nom FROM members WHERE id = ?";
                                PreparedStatement pstmt = conn.prepareStatement(query);
                                pstmt.setInt(1, memberId);
                                ResultSet rs = pstmt.executeQuery();
                                
                                if(rs.next()) {
                                    memberName = rs.getString("prenom") + " " + rs.getString("nom");
                                }
                                conn.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                    <img src="https://ui-avatars.com/api/?name=<%= memberName.replace(" ", "+") %>&background=2e7d32&color=fff" alt="Membre">
                    <span><%= memberName %></span>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="stats-container">
                <%
                    // Calcul des statistiques pour le membre
                    double totalPaye = 0;
                    double totalRemboursements = 0;
                    int tontinesActives = 0;
                    int cotisationsPayees = 0;
                    int cotisationsTotales = 12; // Valeur par défaut
                    
                    if(memberId > 0) {
                        try {
                            Connection conn = DBConnection.getConnection();
                            
                            // Total payé
                            String query = "SELECT SUM(montant) AS total FROM paiements WHERE member_id = ? AND statut = 'COMPLETED'";
                            PreparedStatement pstmt = conn.prepareStatement(query);
                            pstmt.setInt(1, memberId);
                            ResultSet rs = pstmt.executeQuery();
                            if(rs.next()) totalPaye = rs.getDouble("total");
                            
                            // Remboursements reçus
                            query = "SELECT SUM(montant) AS total FROM remboursements WHERE member_id = ? AND statut = 'PROCESSED'";
                            pstmt = conn.prepareStatement(query);
                            pstmt.setInt(1, memberId);
                            rs = pstmt.executeQuery();
                            if(rs.next()) totalRemboursements = rs.getDouble("total");
                            
                            // Tontines actives
                            query = "SELECT COUNT(DISTINCT tontine_id) AS total FROM tontine_adherents1 WHERE member_id = ?";
                            pstmt = conn.prepareStatement(query);
                            pstmt.setInt(1, memberId);
                            rs = pstmt.executeQuery();
                            if(rs.next()) tontinesActives = rs.getInt("total");
                            
                            // Cotisations payées
                            query = "SELECT COUNT(*) AS total FROM paiements WHERE member_id = ? AND type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
                            pstmt = conn.prepareStatement(query);
                            pstmt.setInt(1, memberId);
                            rs = pstmt.executeQuery();
                            if(rs.next()) cotisationsPayees = rs.getInt("total");
                            
                            conn.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
                %>
                <div class="stat-card">
                    <div class="stat-icon income">
                        <i class="fas fa-money-bill-wave"></i>
                    </div>
                    <div class="stat-value"><%= String.format("%,.0f FCFA", totalPaye) %></div>
                    <div class="stat-label">Total payé</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon expense">
                        <i class="fas fa-hand-holding-usd"></i>
                    </div>
                    <div class="stat-value"><%= String.format("%,.0f FCFA", totalRemboursements) %></div>
                    <div class="stat-label">Remboursements</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon members">
                        <i class="fas fa-handshake"></i>
                    </div>
                    <div class="stat-value"><%= tontinesActives %></div>
                    <div class="stat-label">Tontines actives</div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon income">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                    <div class="stat-value"><%= cotisationsPayees %>/<%= cotisationsTotales %></div>
                    <div class="stat-label">Cotisations payées</div>
                </div>
            </div>

            <!-- Recent Transactions -->
            <div class="card">
                <div class="card-header">
                    <h2><i class="fas fa-list"></i> Mes Dernières Transactions</h2>
                </div>
                <div class="search-filter">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" class="form-control" placeholder="Rechercher...">
                    </div>
                    <div class="filter-box">
                        <select class="form-control">
                            <option value="">Tous les types</option>
                            <option value="SOUSCRIPTION">Souscription</option>
                            <option value="COTISATION">Cotisation</option>
                            <option value="AUTRE">Autre</option>
                        </select>
                    </div>
                    <div class="filter-box">
                        <select class="form-control" id="tontineFilter">
                            <option value="">Toutes les tontines</option>
                            <%
                                if(memberId > 0) {
                                    try {
                                        Connection conn = DBConnection.getConnection();
                                        String query = "SELECT ta.tontine_id, t.nom FROM tontine_adherents1 ta " +
                                                      "JOIN tontines t ON ta.tontine_id = t.id " +
                                                      "WHERE ta.member_id = ?";
                                        PreparedStatement pstmt = conn.prepareStatement(query);
                                        pstmt.setInt(1, memberId);
                                        ResultSet rs = pstmt.executeQuery();
                                        
                                        while(rs.next()) {
                            %>
                            <option value="<%= rs.getInt("tontine_id") %>"><%= rs.getString("nom") %></option>
                            <%
                                        }
                                        conn.close();
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    }
                                }
                            %>
                        </select>
                    </div>
                </div>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Tontine</th>
                                <th>Montant</th>
                                <th>Type</th>
                                <th>Date</th>
                                <th>Méthode</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                List<Paiement> transactions = new ArrayList<>();
                                if(memberId > 0) {
                                    try {
                                        Connection conn = DBConnection.getConnection();
                                        String query = "SELECT p.*, t.nom AS tontine_name FROM paiements p " +
                                                      "LEFT JOIN tontines t ON p.tontine_id = t.id " +
                                                      "WHERE p.member_id = ? " +
                                                      "ORDER BY p.date_paiement DESC LIMIT 10";
                                        PreparedStatement pstmt = conn.prepareStatement(query);
                                        pstmt.setInt(1, memberId);
                                        ResultSet rs = pstmt.executeQuery();
                                        
                                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                        SimpleDateFormat displayFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                                        
                                        while(rs.next()) {
                                            String tontineName = rs.getString("tontine_name");
                                            if(tontineName == null) tontineName = "N/A";
                                            
                                            Date datePaiement = new Date(rs.getTimestamp("date_paiement").getTime());
                                            String formattedDate = displayFormat.format(datePaiement);
                                            
                                            transactions.add(new Paiement(
                                                rs.getInt("id"),
                                                tontineName,
                                                rs.getDouble("montant"),
                                                rs.getString("type_paiement"),
                                                formattedDate,
                                                rs.getString("methode_paiement"),
                                                rs.getString("statut")
                                            ));
                                        }
                                        conn.close();
                                    } catch(Exception e) {
                                        e.printStackTrace();
                                    }
                                }
                                
                                for (Paiement transaction : transactions) {
                            %>
                            <tr>
                                <td><%= transaction.getId() %></td>
                                <td><%= transaction.getTontineName() %></td>
                                <td><%= String.format("%,.0f FCFA", transaction.getMontant()) %></td>
                                <td><%= transaction.getType() %></td>
                                <td><%= transaction.getDate() %></td>
                                <td><%= transaction.getMethode() %></td>
                                <td>
                                    <span class="badge <%= transaction.getStatutClass() %>">
                                        <%= transaction.getStatutText() %>
                                    </span>
                                </td>
                                <td>
                                    <div class="btn-group">
                                        <button class="btn btn-primary" onclick="viewTransaction(<%= transaction.getId() %>)">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <% if ("PENDING".equals(transaction.getStatut())) { %>
                                        <button class="btn btn-secondary" onclick="cancelTransaction(<%= transaction.getId() %>)">
                                            <i class="fas fa-times"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
              <ul class="pagination">
				    <li class="page-item"><a class="page-link" href="#">&laquo;</a></li>
				    <li class="page-item active"><a class="page-link" href="#">1</a></li>
				    <li class="page-item"><a class="page-link" href="#">2</a></li>
				    <li class="page-item"><a class="page-link" href="#">3</a></li>
				    <li class="page-item"><a class="page-link" href="#">&raquo;</a></li>
				</ul>
				            </div>

            <!-- My Invoices -->
            <div class="card">
                <div class="card-header">
                    <h2><i class="fas fa-file-invoice-dollar"></i> Mes Factures Récentes</h2>
                </div>
                <%
                    List<Facture> factures = new ArrayList<>();
                    if(memberId > 0) {
                        try {
                            Connection conn = DBConnection.getConnection();
                            String query = "SELECT f.*, t.nom AS tontine_name FROM factures f " +
                                          "LEFT JOIN tontines t ON f.tontine_id = t.id " +
                                          "WHERE f.member_id = ? " +
                                          "ORDER BY f.date_emission DESC LIMIT 2";
                            PreparedStatement pstmt = conn.prepareStatement(query);
                            pstmt.setInt(1, memberId);
                            ResultSet rs = pstmt.executeQuery();
                            
                            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                            SimpleDateFormat displayFormat = new SimpleDateFormat("dd/MM/yyyy");
                            
                            while(rs.next()) {
                                String tontineName = rs.getString("tontine_name");
                                if(tontineName == null) tontineName = "N/A";
                                
                                Date dateEmission = new Date(rs.getTimestamp("date_emission").getTime());
                                Date dateEcheance = new Date(rs.getTimestamp("date_echeance").getTime());
                                
                                factures.add(new Facture(
                                    rs.getString("numero"),
                                    tontineName,
                                    rs.getString("type"),
                                    rs.getDouble("montant"),
                                    displayFormat.format(dateEmission),
                                    displayFormat.format(dateEcheance),
                                    rs.getString("statut")
                                ));
                            }
                            conn.close();
                        } catch(Exception e) {
                            e.printStackTrace();
                        }
                    }
                    
                    for(Facture facture : factures) {
                %>
                <div class="invoice">
                    <div class="invoice-header">
                        <div class="invoice-title">Facture #<%= facture.getNumero() %></div>
                        <div class="invoice-status badge <%= facture.getStatutClass() %>"><%= facture.getStatutText() %></div>
                    </div>
                    <div class="invoice-body">
                        <p><strong>Tontine:</strong> <%= facture.getTontineName() %></p>
                        <p><strong>Type:</strong> <%= facture.getTypeText() %></p>
                        <p><strong>Montant:</strong> <%= String.format("%,.0f FCFA", facture.getMontant()) %></p>
                        <p><strong>Date d'émission:</strong> <%= facture.getDateEmission() %></p>
                        <p><strong>Date d'échéance:</strong> <%= facture.getDateEcheance() %></p>
                    </div>
                    <div class="invoice-footer">
                        <button class="btn btn-primary">
                            <i class="fas fa-download"></i> Télécharger
                        </button>
                    </div>
                </div>
                <% } %>
            </div>

         <!-- Refund Request Section -->
<div class="card">
    <div class="card-header">
        <h2><i class="fas fa-exchange-alt"></i> Demande de Remboursement</h2>
        <button class="btn btn-primary" onclick="toggleRefundForm()">
            <i class="fas fa-plus"></i> Demander un remboursement
        </button>
    </div>
    
    <!-- Refund Form (hidden by default) -->
    <div id="refundFormContainer" style="display: none;">
        <form id="refundForm" action="processRefund.jsp" method="POST">
            <input type="hidden" name="member_id" value="<%= memberId %>">
            <div class="form-group">
                <label for="transaction">Transaction concernée</label>
                <select id="transaction" name="transaction_id" class="form-control" required>
                    <option value="">Sélectionner une transaction</option>
                    <%
                        if(memberId > 0) {
                            try {
                                Connection conn = DBConnection.getConnection();
                                String query = "SELECT id, montant, date_paiement, type_paiement FROM paiements " +
                                              "WHERE member_id = ? AND statut = 'COMPLETED' " +
                                              "ORDER BY date_paiement DESC";
                                PreparedStatement pstmt = conn.prepareStatement(query);
                                pstmt.setInt(1, memberId);
                                ResultSet rs = pstmt.executeQuery();
                                
                                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                SimpleDateFormat displayFormat = new SimpleDateFormat("dd/MM/yyyy");
                                
                                while(rs.next()) {
                                    Date datePaiement = new Date(rs.getTimestamp("date_paiement").getTime());
                                    String optionText = "#" + rs.getInt("id") + " - " + 
                                        rs.getString("type_paiement") + " - " + 
                                        String.format("%,.0f FCFA", rs.getDouble("montant")) + " - " + 
                                        displayFormat.format(datePaiement);
                    %>
                    <option value="<%= rs.getInt("id") %>"><%= optionText %></option>
                    <%
                                }
                                conn.close();
                            } catch(Exception e) {
                                e.printStackTrace();
                            }
                        }
                    %>
                </select>
            </div>
            <div class="form-group">
                <label for="amount">Montant à rembourser (FCFA)</label>
                <input type="number" id="amount" name="montant" class="form-control" required step="0.01">
            </div>
            <div class="form-group">
                <label for="reason">Raison du remboursement</label>
                <select id="reason" name="raison" class="form-control" required>
                    <option value="">Sélectionner une raison</option>
                    <option value="DOUBLE_PAYMENT">Paiement en double</option>
                    <option value="CANCELLATION">Annulation de souscription</option>
                    <option value="OTHER">Autre raison</option>
                </select>
            </div>
            <div class="form-group">
                <label for="details">Détails supplémentaires</label>
                <textarea id="details" name="details" class="form-control" rows="3"></textarea>
            </div>
            <div class="form-group">
                <label for="method">Méthode de remboursement préférée</label>
                <select id="method" name="methode_remboursement" class="form-control" required>
                    <option value="">Sélectionner une méthode</option>
                    <option value="MTNMONEY">MTN Mobile Money</option>
                    <option value="BANQUE">Virement Bancaire</option>
                    <option value="ORANGEMoney">Orange Money</option>
                </select>
            </div>
            <div class="btn-group" style="justify-content: flex-end;">
                <button type="button" class="btn btn-secondary" onclick="toggleRefundForm()">Annuler</button>
                <button type="submit" class="btn btn-primary">Soumettre la demande</button>
            </div>
        </form>
    </div>
</div>
        </div>
    

    <!-- Transaction Details Modal -->
    <div id="transactionModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2><i class="fas fa-money-bill-wave"></i> Détails de la Transaction</h2>
                <span class="close" onclick="closeModal('transactionModal')">&times;</span>
            </div>
            <div id="transactionDetails">
                <!-- Les détails seront chargés dynamiquement via JavaScript -->
            </div>
        </div>
    </div>

    <script>
        // Gestion des modales
        function openModal(id) {
            document.getElementById(id).style.display = "flex";
        }

        function closeModal(id) {
            document.getElementById(id).style.display = "none";
        }

        // Fermer la modale en cliquant à l'extérieur
        window.onclick = function(event) {
            if (event.target.className === "modal") {
                event.target.style.display = "none";
            }
        }

        // Gestion du formulaire de remboursement
        document.getElementById('refundForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Validation du montant
            const transactionSelect = document.getElementById('transaction');
            const amountInput = document.getElementById('amount');
            const selectedOption = transactionSelect.options[transactionSelect.selectedIndex];
            
            if(selectedOption.value && parseFloat(amountInput.value) > parseFloat(selectedOption.dataset.maxAmount)) {
                showNotification('error', 'Le montant demandé ne peut pas dépasser le montant de la transaction');
                return;
            }
            
            // Soumission du formulaire
            this.submit();
        });
        
     // Fonction pour afficher/masquer le formulaire de remboursement
        function toggleRefundForm() {
            const formContainer = document.getElementById('refundFormContainer');
            if (formContainer.style.display === 'none') {
                formContainer.style.display = 'block';
            } else {
                formContainer.style.display = 'none';
                document.getElementById('refundForm').reset();
            }
        }

        // Chargement des détails de transaction
        function viewTransaction(id) {
            fetch('getTransactionDetails.jsp?id=' + id)
                .then(response => response.text())
                .then(html => {
                    document.getElementById('transactionDetails').innerHTML = html;
                    openModal('transactionModal');
                })
                .catch(error => {
                    console.error('Error:', error);
                    showNotification('error', 'Erreur lors du chargement des détails');
                });
        }

        function cancelTransaction(id) {
            if (confirm("Êtes-vous sûr de vouloir annuler cette transaction?")) {
                fetch('cancelTransaction.jsp?id=' + id)
                    .then(response => response.json())
                    .then(data => {
                        if(data.success) {
                            showNotification('success', data.message);
                            // Recharger la page après un délai
                            setTimeout(() => location.reload(), 1500);
                        } else {
                            showNotification('error', data.message);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showNotification('error', 'Erreur lors de l\'annulation');
                    });
            }
        }

        function showNotification(type, message) {
            const notification = document.createElement('div');
            notification.className = `notification ${type}`;
            notification.innerHTML = message;
            document.body.appendChild(notification);
            
            // Supprimer la notification après l'animation
            setTimeout(() => {
                notification.remove();
            }, 3500);
        }

        // Mettre à jour le montant maximum lors de la sélection d'une transaction
        document.getElementById('transaction').addEventListener('change', function() {
            const selectedOption = this.options[this.selectedIndex];
            if(selectedOption.value) {
                document.getElementById('amount').value = selectedOption.dataset.maxAmount;
                document.getElementById('amount').max = selectedOption.dataset.maxAmount;
            }
        });
    </script>
</body>
</html>

<%!
    // Classe helper pour afficher les transactions
    public class Paiement {
        private int id;
        private String tontineName;
        private double montant;
        private String type;
        private String date;
        private String methode;
        private String statut;

        public Paiement(int id, String tontineName, double montant, String type, String date, String methode, String statut) {
            this.id = id;
            this.tontineName = tontineName;
            this.montant = montant;
            this.type = type;
            this.date = date;
            this.methode = methode;
            this.statut = statut;
        }

        public int getId() { return id; }
        public String getTontineName() { return tontineName; }
        public double getMontant() { return montant; }
        public String getType() { return type; }
        public String getDate() { return date; }
        public String getMethode() { return methode; }
        public String getStatut() { return statut; }
        public String getStatutText() { 
            switch(statut) {
                case "PENDING": return "En attente";
                case "COMPLETED": return "Complété";
                case "FAILED": return "Échoué";
                default: return statut;
            }
        }
        public String getStatutClass() { 
            switch(statut) {
                case "PENDING": return "badge-warning";
                case "COMPLETED": return "badge-success";
                case "FAILED": return "badge-danger";
                default: return "";
            }
        }
    }

    // Classe helper pour afficher les factures
    public class Facture {
        private String numero;
        private String tontineName;
        private String type;
        private double montant;
        private String dateEmission;
        private String dateEcheance;
        private String statut;

        public Facture(String numero, String tontineName, String type, double montant, String dateEmission, String dateEcheance, String statut) {
            this.numero = numero;
            this.tontineName = tontineName;
            this.type = type;
            this.montant = montant;
            this.dateEmission = dateEmission;
            this.dateEcheance = dateEcheance;
            this.statut = statut;
        }

        public String getNumero() { return numero; }
        public String getTontineName() { return tontineName; }
        public String getType() { return type; }
        public String getTypeText() {
            switch(type) {
                case "COTISATION": return "Cotisation";
                case "SOUSCRIPTION": return "Souscription";
                case "AUTRE": return "Autre";
                default: return type;
            }
        }
        public double getMontant() { return montant; }
        public String getDateEmission() { return dateEmission; }
        public String getDateEcheance() { return dateEcheance; }
        public String getStatut() { return statut; }
        public String getStatutText() {
            switch(statut) {
                case "UNPAID": return "Impayée";
                case "PAID": return "Payée";
                case "CANCELLED": return "Annulée";
                case "OVERDUE": return "En retard";
                default: return statut;
            }
        }
        public String getStatutClass() {
            switch(statut) {
                case "PAID": return "badge-success";
                case "UNPAID": 
                case "OVERDUE": return "badge-warning";
                case "CANCELLED": return "badge-danger";
                default: return "";
            }
        }
    }
%>