<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="models.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Traitement des Remboursements</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
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
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
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

        .badge-info {
            background-color: #e3f2fd;
            color: var(--info);
        }

        .btn-group {
            display: flex;
            gap: 10px;
        }

        .btn {
            padding: 8px 12px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            border: none;
            font-size: 0.9rem;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
        }

        .btn-secondary {
            background-color: #757575;
            color: white;
        }

        .btn-secondary:hover {
            background-color: #616161;
        }

        .btn-success {
            background-color: var(--success);
            color: white;
        }

        .btn-success:hover {
            background-color: #388e3c;
        }

        .btn-danger {
            background-color: var(--danger);
            color: white;
        }

        .btn-danger:hover {
            background-color: #d32f2f;
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
            max-width: 500px;
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

        .refund-details {
            background-color: #f9f9f9;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 20px;
        }

        .detail-row {
            display: flex;
            margin-bottom: 10px;
        }

        .detail-label {
            font-weight: 500;
            width: 150px;
            color: #555;
        }

        .detail-value {
            flex: 1;
        }

        @media (max-width: 768px) {
            .detail-row {
                flex-direction: column;
            }
            .detail-label {
                width: 100%;
                margin-bottom: 5px;
            }
        }
    </style>
</head>
<body>
<%@ include file="sidebars.jsp" %>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-exchange-alt"></i> Traitement des Remboursements</h1>
        </div>

        <%
            // Récupérer le paramètre d'action (approve/reject) et l'ID de remboursement
            String action = request.getParameter("action");
            String refundIdStr = request.getParameter("id");
            int refundId = 0;
            
            if (refundIdStr != null && !refundIdStr.isEmpty()) {
                refundId = Integer.parseInt(refundIdStr);
            }
            
            // Traitement du formulaire
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String processAction = request.getParameter("processAction");
                int adminId = 1; // À remplacer par l'ID de l'admin connecté
                String method = request.getParameter("method");
                String notes = request.getParameter("notes");
                
                try {
                    Connection conn = DBConnection.getConnection();
                    
                    if ("approve".equals(processAction)) {
                        // Approuver le remboursement
                        String sql = "UPDATE remboursements SET statut = 'APPROVED', date_traitement = NOW(), " +
                                     "methode_remboursement = ?, admin_id = ? WHERE id = ?";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setString(1, method);
                        pstmt.setInt(2, adminId);
                        pstmt.setInt(3, refundId);
                        pstmt.executeUpdate();
                        
                        // TODO: Ajouter le code pour effectuer le remboursement réel (virement, etc.)
                        
                        out.println("<div class='notification success'>Remboursement approuvé avec succès!</div>");
                    } else if ("reject".equals(processAction)) {
                        // Rejeter le remboursement
                        String sql = "UPDATE remboursements SET statut = 'REJECTED', date_traitement = NOW(), " +
                                     "admin_id = ? WHERE id = ?";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, adminId);
                        pstmt.setInt(2, refundId);
                        pstmt.executeUpdate();
                        
                        out.println("<div class='notification warning'>Remboursement rejeté avec succès!</div>");
                    }
                    
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='notification error'>Erreur lors du traitement: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                }
            }
            
            // Récupérer les détails du remboursement
            Refund refund = null;
            Member member = null;
            Paiement transaction = null;
            
            if (refundId > 0) {
                try {
                    Connection conn = DBConnection.getConnection();
                    
                    // Récupérer les détails du remboursement
                    String sql = "SELECT * FROM remboursements WHERE id = ?";
                    PreparedStatement pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, refundId);
                    ResultSet rs = pstmt.executeQuery();
                    
                    if (rs.next()) {
                        refund = new Refund(
                            rs.getInt("id"),
                            rs.getInt("member_id"),
                            rs.getInt("transaction_id"),
                            rs.getBigDecimal("montant"),
                            rs.getString("raison"),
                            rs.getString("details"),
                            rs.getTimestamp("date_demande"),
                            rs.getTimestamp("date_traitement"),
                            rs.getString("statut"),
                            rs.getString("methode_remboursement"),
                            rs.getInt("admin_id")
                        );
                        
                        // Récupérer les infos du membre
                        sql = "SELECT * FROM members WHERE id = ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, refund.getMemberId());
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            member = new Member(
                                rs.getInt("id"),
                                rs.getString("nom"),
                                rs.getString("prenom"),
                                rs.getString("email"),
                                rs.getString("numero"),
                                rs.getString("localisation")
                            );
                        }
                        
                        // Récupérer les infos de la transaction
                        sql = "SELECT * FROM paiements WHERE id = ?";
                        pstmt = conn.prepareStatement(sql);
                        pstmt.setInt(1, refund.getTransactionId());
                        rs = pstmt.executeQuery();
                        
                        if (rs.next()) {
                            transaction = new Paiement(
                                rs.getInt("id"),
                                rs.getInt("member_id"),
                                rs.getBigDecimal("montant"),
                                rs.getString("type_paiement"),
                                rs.getTimestamp("date_paiement"),
                                rs.getString("mode_paiement"),
                                rs.getString("statut")
                            );
                        }
                    }
                    
                    conn.close();
                } catch (Exception e) {
                    out.println("<div class='notification error'>Erreur lors de la récupération des données: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                }
            }
        %>

        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-info-circle"></i> Détails du Remboursement</h2>
            </div>
            
            <% if (refund != null && member != null && transaction != null) { %>
                <div class="refund-details">
                    <div class="detail-row">
                        <div class="detail-label">ID Remboursement:</div>
                        <div class="detail-value">#<%= refund.getId() %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Membre:</div>
                        <div class="detail-value"><%= member.getNomComplet() %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">ID Transaction:</div>
                        <div class="detail-value">#<%= transaction.getId() %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Montant:</div>
                        <div class="detail-value"><%= String.format("%,.2f FCFA", refund.getMontant()) %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Raison:</div>
                        <div class="detail-value"><%= refund.getRaisonText() %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Détails:</div>
                        <div class="detail-value"><%= refund.getDetails() != null ? refund.getDetails() : "Aucun détail supplémentaire" %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Date Demande:</div>
                        <div class="detail-value"><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(refund.getDateDemande()) %></div>
                    </div>
                    <div class="detail-row">
                        <div class="detail-label">Statut:</div>
                        <div class="detail-value">
                            <span class="badge <%= refund.getStatutClass() %>">
                                <%= refund.getStatutText() %>
                            </span>
                        </div>
                    </div>
                    <% if (refund.getDateTraitement() != null) { %>
                    <div class="detail-row">
                        <div class="detail-label">Date Traitement:</div>
                        <div class="detail-value"><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(refund.getDateTraitement()) %></div>
                    </div>
                    <% } %>
                </div>
                
                <% if ("PENDING".equals(refund.getStatut())) { %>
                <form method="POST" action="processRefund.jsp">
                    <input type="hidden" name="id" value="<%= refund.getId() %>">
                    
                    <div class="form-group">
                        <label for="method">Méthode de Remboursement</label>
                        <select id="method" name="method" class="form-control" required>
                            <option value="">Sélectionner une méthode</option>
                            <option value="MTNMONEY">MTN Mobile Money</option>
                            <option value="BANQUE">Virement Bancaire</option>
                            <option value="ORANGEMoney">Orange Money</option>
                            <option value="CASH">Espèces</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="notes">Notes (Optionnel)</label>
                        <textarea id="notes" name="notes" class="form-control" rows="3"></textarea>
                    </div>
                    
                    <div class="btn-group" style="justify-content: flex-end;">
                        <button type="submit" name="processAction" value="reject" class="btn btn-danger">
                            <i class="fas fa-times"></i> Rejeter
                        </button>
                        <button type="submit" name="processAction" value="approve" class="btn btn-success">
                            <i class="fas fa-check"></i> Approuver
                        </button>
                    </div>
                </form>
                <% } else { %>
                <div class="notification info" style="position: relative; margin-bottom: 20px;">
                    Ce remboursement a déjà été traité (<%= refund.getStatutText() %>)
                </div>
                <% } %>
            <% } else { %>
                <div class="notification error" style="position: relative; margin-bottom: 20px;">
                    Aucune demande de remboursement trouvée avec cet ID
                </div>
            <% } %>
        </div>
        
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-history"></i> Historique des Remboursements</h2>
            </div>
            
            <div class="search-filter">
                <div class="search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" class="form-control" placeholder="Rechercher...">
                </div>
                <div class="filter-box">
                    <select class="form-control">
                        <option value="">Tous les statuts</option>
                        <option value="PENDING">En attente</option>
                        <option value="APPROVED">Approuvé</option>
                        <option value="REJECTED">Rejeté</option>
                        <option value="PROCESSED">Traité</option>
                    </select>
                </div>
            </div>
            
            <div class="table-responsive">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Membre</th>
                            <th>Montant</th>
                            <th>Raison</th>
                            <th>Date Demande</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Connection conn = DBConnection.getConnection();
                                String sql = "SELECT r.*, m.nom, m.prenom FROM remboursements r " +
                                            "JOIN members m ON r.member_id = m.id " +
                                            "ORDER BY r.date_demande DESC LIMIT 10";
                                Statement stmt = conn.createStatement();
                                ResultSet rs = stmt.executeQuery(sql);
                                
                                while (rs.next()) {
                                    Refund r = new Refund(
                                        rs.getInt("id"),
                                        rs.getInt("member_id"),
                                        0, // transaction_id non utilisé ici
                                        rs.getBigDecimal("montant"),
                                        rs.getString("raison"),
                                        null, // details non utilisé ici
                                        rs.getTimestamp("date_demande"),
                                        rs.getTimestamp("date_traitement"),
                                        rs.getString("statut"),
                                        null, // methode non utilisé ici
                                        0 // admin_id non utilisé ici
                                    );
                        %>
                        <tr>
                            <td>#<%= r.getId() %></td>
                            <td><%= rs.getString("prenom") + " " + rs.getString("nom") %></td>
                            <td><%= String.format("%,.2f FCFA", r.getMontant()) %></td>
                            <td><%= r.getRaisonText() %></td>
                            <td><%= new SimpleDateFormat("dd/MM/yyyy").format(r.getDateDemande()) %></td>
                            <td>
                                <span class="badge <%= r.getStatutClass() %>">
                                    <%= r.getStatutText() %>
                                </span>
                            </td>
                            <td>
                                <div class="btn-group">
                                    <a href="processRefund.jsp?id=<%= r.getId() %>" class="btn btn-primary">
                                        <i class="fas fa-eye"></i> Voir
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                                conn.close();
                            } catch (Exception e) {
                                out.println("<tr><td colspan='7'>Erreur lors de la récupération des données: " + e.getMessage() + "</td></tr>");
                                e.printStackTrace();
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <div class="pagination">
                <li class="page-item"><a class="page-link" href="#">&laquo;</a></li>
                <li class="page-item active"><a class="page-link" href="#">1</a></li>
                <li class="page-item"><a class="page-link" href="#">2</a></li>
                <li class="page-item"><a class="page-link" href="#">3</a></li>
                <li class="page-item"><a class="page-link" href="#">&raquo;</a></li>
            </div>
        </div>
    </div>

    <script>
        // Fonction pour afficher les notifications
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
    </script>
</body>
</html>

<%!
    // Classes helper pour afficher les données
    public class Refund {
        private int id;
        private int memberId;
        private int transactionId;
        private BigDecimal montant;
        private String raison;
        private String details;
        private Timestamp dateDemande;
        private Timestamp dateTraitement;
        private String statut;
        private String methodeRemboursement;
        private int adminId;

        public Refund(int id, int memberId, int transactionId, BigDecimal montant, String raison, 
                     String details, Timestamp dateDemande, Timestamp dateTraitement, 
                     String statut, String methodeRemboursement, int adminId) {
            this.id = id;
            this.memberId = memberId;
            this.transactionId = transactionId;
            this.montant = montant;
            this.raison = raison;
            this.details = details;
            this.dateDemande = dateDemande;
            this.dateTraitement = dateTraitement;
            this.statut = statut;
            this.methodeRemboursement = methodeRemboursement;
            this.adminId = adminId;
        }

        // Getters
        public int getId() { return id; }
        public int getMemberId() { return memberId; }
        public int getTransactionId() { return transactionId; }
        public BigDecimal getMontant() { return montant; }
        public String getRaison() { return raison; }
        public String getDetails() { return details; }
        public Timestamp getDateDemande() { return dateDemande; }
        public Timestamp getDateTraitement() { return dateTraitement; }
        public String getStatut() { return statut; }
        public String getMethodeRemboursement() { return methodeRemboursement; }
        public int getAdminId() { return adminId; }
        
        public String getRaisonText() {
            switch(raison) {
                case "DOUBLE_PAYMENT": return "Paiement en double";
                case "CANCELLATION": return "Annulation";
                case "OTHER": return "Autre raison";
                default: return raison;
            }
        }
        
        public String getStatutText() {
            switch(statut) {
                case "PENDING": return "En attente";
                case "APPROVED": return "Approuvé";
                case "REJECTED": return "Rejeté";
                case "PROCESSED": return "Traité";
                default: return statut;
            }
        }
        
        public String getStatutClass() {
            switch(statut) {
                case "PENDING": return "badge-warning";
                case "APPROVED": return "badge-info";
                case "REJECTED": return "badge-danger";
                case "PROCESSED": return "badge-success";
                default: return "";
            }
        }
    }

    public class Member {
        private int id;
        private String nom;
        private String prenom;
        private String email;
        private String numero;
        private String localisation;

        public Member(int id, String nom, String prenom, String email, String numero, String localisation) {
            this.id = id;
            this.nom = nom;
            this.prenom = prenom;
            this.email = email;
            this.numero = numero;
            this.localisation = localisation;
        }

        // Getters
        public int getId() { return id; }
        public String getNom() { return nom; }
        public String getPrenom() { return prenom; }
        public String getEmail() { return email; }
        public String getNumero() { return numero; }
        public String getLocalisation() { return localisation; }
        
        public String getNomComplet() {
            return prenom + " " + nom;
        }
    }

    public class Paiement {
        private int id;
        private int memberId;
        private BigDecimal montant;
        private String type;
        private Timestamp date;
        private String methode;
        private String statut;

        public Paiement(int id, int memberId, BigDecimal montant, String type, Timestamp date, String methode, String statut) {
            this.id = id;
            this.memberId = memberId;
            this.montant = montant;
            this.type = type;
            this.date = date;
            this.methode = methode;
            this.statut = statut;
        }

        // Getters
        public int getId() { return id; }
        public int getMemberId() { return memberId; }
        public BigDecimal getMontant() { return montant; }
        public String getType() { return type; }
        public Timestamp getDate() { return date; }
        public String getMethode() { return methode; }
        public String getStatut() { return statut; }
    }
%>