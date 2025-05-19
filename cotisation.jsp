<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import= "java.io.File" %>
<%@ page import= "java.nio.file.Paths" %>
<%@ page session="true" %>

<%

    // Vérifier si l'utilisateur est connecté
    Integer memberId = (Integer) session.getAttribute("memberId");
    String memberRole = (String) session.getAttribute("role");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String uploadPath = getServletContext().getRealPath("/") + "uploads";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();
    
    // Récupérer le paramètre tontine_id s'il existe
    int selectedTontineId = 0;
    String selectedTontineIdParam = request.getParameter("tontine_id");
    if (selectedTontineIdParam != null && !selectedTontineIdParam.isEmpty()) {
        selectedTontineId = Integer.parseInt(selectedTontineIdParam);
    }
    
    // Récupérer toutes les tontines de l'utilisateur
    java.util.List<java.util.Map<String, Object>> userTontines = new java.util.ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT t.id, t.nom, t.montant_mensuel, t.date_debut, t.date_fin, " +
                     "ta.date_adhesion, ta.montant_souscription, ta.nombre_de_parts " +
                     "FROM tontines t " +
                     "JOIN tontine_adherents1 ta ON t.id = ta.tontine_id " +
                     "WHERE ta.member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> tontine = new java.util.HashMap<>();
                    tontine.put("id", rs.getInt("id"));
                    tontine.put("nom", rs.getString("nom"));
                    tontine.put("montant_mensuel", rs.getBigDecimal("montant_mensuel"));
                    tontine.put("date_debut", rs.getDate("date_debut"));
                    tontine.put("date_fin", rs.getDate("date_fin"));
                    tontine.put("date_adhesion", rs.getTimestamp("date_adhesion"));
                    tontine.put("montant_souscription", rs.getBigDecimal("montant_souscription"));
                    tontine.put("nombre_de_parts", rs.getInt("nombre_de_parts"));
                    userTontines.add(tontine);
                    
                    // Si aucune tontine sélectionnée, prendre la première
                    if (selectedTontineId == 0) {
                        selectedTontineId = rs.getInt("id");
                    }
                }
            }
        }
    } catch (SQLException e) {
        session.setAttribute("errorMessage", "Erreur technique lors de la récupération de vos tontines");
        e.printStackTrace();
    }
    
    // Si l'utilisateur n'est inscrit à aucune tontine
    if (userTontines.isEmpty()) {
        session.setAttribute("errorMessage", "Vous n'êtes inscrit à aucune tontine");
        response.sendRedirect("souscription.jsp");
        return;
    }
    
    // Récupérer les détails de la tontine sélectionnée
    java.util.Map<String, Object> selectedTontine = null;
    for (java.util.Map<String, Object> tontine : userTontines) {
        if ((Integer)tontine.get("id") == selectedTontineId) {
            selectedTontine = tontine;
            break;
        }
    }
    
    // Variables pour le formulaire et les statistiques
    BigDecimal montantMensuel = selectedTontine != null ? (BigDecimal)selectedTontine.get("montant_mensuel") : BigDecimal.ZERO;
    String tontineName = selectedTontine != null ? (String)selectedTontine.get("nom") : "";
    
    // Récupérer le fond de caisse et le total des paiements pour affichage
    BigDecimal fondCaisse = BigDecimal.ZERO;
    BigDecimal totalPaiements = BigDecimal.ZERO;
    BigDecimal disponible = BigDecimal.ZERO;

    try (Connection conn = DBConnection.getConnection()) {
        // Fond de caisse
        String fondSql = "SELECT montant_souscription FROM tontine_adherents1 WHERE member_id  = ?";
        try (PreparedStatement ps = conn.prepareStatement(fondSql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    fondCaisse = new BigDecimal(rs.getString("montant_souscription"));
                }
            }
        }
        
        // Total des paiements pour la tontine sélectionnée
        String totalSql = "SELECT COALESCE(SUM(montant), 0) as total FROM paiements " +
                         "WHERE member_id = ? AND tontine_id = ? AND type_paiement = 'COTISATION'";
        try (PreparedStatement ps = conn.prepareStatement(totalSql)) {
            ps.setInt(1, memberId);
            ps.setInt(2, selectedTontineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalPaiements = rs.getBigDecimal("total");
                }
            }
        }
        
        disponible = fondCaisse.subtract(totalPaiements);
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            // Récupérer les paramètres standards
            String moisAnnee = request.getParameter("mois_annee");
            String methodePaiement = request.getParameter("methode_paiement");
            String reference = request.getParameter("reference");
            System.out.println(reference);
    
         // Gestion de l'upload de fichier
            String fileName = null;
            Part filePart = request.getPart("preuve_paiement");
            if (filePart != null && filePart.getSize() > 0) {
                fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                filePart.write(uploadPath + File.separator + fileName);
            }
            
            // Vérifier si ce mois n'a pas déjà été payé
           String checkPaymentSql = "SELECT 1 FROM paiements WHERE member_id = ? AND tontine_id = ? AND mois_annee = ? AND type_paiement = 'COTISATION'";
            try (PreparedStatement checkPs = conn.prepareStatement(checkPaymentSql)) {
                checkPs.setInt(1, memberId);
                checkPs.setInt(2, selectedTontineId);
                checkPs.setString(3, moisAnnee);
                
                if (checkPs.executeQuery().next()) {
                    session.setAttribute("errorMessage", "Vous avez déjà payé la cotisation pour " + moisAnnee);
                    response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                    return;
                }
            }
            
            // Vérifier si le nouveau paiement dépasse le fond de caisse
            BigDecimal nouveauTotal = totalPaiements.add(montantMensuel);
            if (nouveauTotal.compareTo(fondCaisse) > 0) {
                session.setAttribute("errorMessage", "Paiement refusé : Le montant total des cotisations (" + 
                    nouveauTotal + " FCFA) dépasse votre fond de caisse (" + fondCaisse + " FCFA)");
                response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                return;
            }
            
            // Si égal, bloquer aussi (comme demandé)
            if (nouveauTotal.compareTo(fondCaisse) == 0) {
                session.setAttribute("errorMessage", "Paiement bloqué : Le montant total des cotisations atteint exactement votre fond de caisse (" + 
                    fondCaisse + " FCFA)");
                response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                return;
            }
            
            // Enregistrer le paiement si tout est OK
     String insertSql = "INSERT INTO paiements (member_id, tontine_id, montant, date_paiement, " +
                      "type_paiement, statut, mois_annee, methode_paiement, reference, preuve_paiement) " +
                      "VALUES (?, ?, ?, NOW(), 'COTISATION', 'COMPLETED', ?, ?, ?, ?)";
    
    try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
        insertPs.setInt(1, memberId);
        insertPs.setInt(2, selectedTontineId);
        insertPs.setBigDecimal(3, montantMensuel);
        insertPs.setString(4, moisAnnee);
        insertPs.setString(5, methodePaiement);
        insertPs.setString(6, reference);
        insertPs.setString(7, fileName); // Nom du fichier ou null
        
        int rows = insertPs.executeUpdate();
        
        System.out.println("Méthode paiement: " + methodePaiement);
        System.out.println("Référence: " + reference);
        System.out.println("Fichier: " + (fileName != null ? fileName : "aucun"));
                if (rows > 0) {
                    session.setAttribute("successMessage", "Paiement de " + montantMensuel + 
                        " FCFA enregistré pour " + moisAnnee);
                    response.sendRedirect("cotisation.jsp?tontine_id=" + selectedTontineId);
                    return;
                }
            }
        }
    } catch (SQLException e) {
        session.setAttribute("errorMessage", "Erreur technique: " + e.getMessage());
        e.printStackTrace();
    }
    
    // Variables pour les statistiques
    int paidCount = 0;
    int pendingCount = 0;
    int missedCount = 0;
    int totalMembers = 0;
    
    // Récupérer les statistiques des cotisations
    try (Connection conn = DBConnection.getConnection()) {
        // Cotisations payées pour la tontine sélectionnée
        String paidSql = "SELECT COUNT(*) as count FROM paiements " +
                        "WHERE tontine_id = ? AND member_id = ? AND type_paiement = 'COTISATION'";
        try (PreparedStatement ps = conn.prepareStatement(paidSql)) {
            ps.setInt(1, selectedTontineId);
            ps.setInt(2, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    paidCount = rs.getInt("count");
                }
            }
        }
        
        // Total des membres dans la tontine
        String totalSql = "SELECT COUNT(*) as total FROM tontine_adherents1 WHERE tontine_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(totalSql)) {
            ps.setInt(1, selectedTontineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    totalMembers = rs.getInt("total");
                }
            }
        }
        
        // Cotisations en attente (membres n'ayant pas encore payé)
        pendingCount = (paidCount > 0 ? 0 : 1);
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Cotisations - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #e4efe9 100%);
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        .container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 350px;
            background: linear-gradient(to bottom, #2c3e50, #1a252f);
            color: white;
            padding: 20px;
            overflow-y: auto;
        }
        
        .content {
            flex: 1;
            padding: 30px;
            overflow-y: auto;
        }
        
        .tontine-list {
            margin-top: 20px;
        }
        
        .tontine-item {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 15px;
            cursor: pointer;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }
        
        .tontine-item:hover {
            background: rgba(255, 255, 255, 0.15);
        }
        
        .tontine-item.active {
            background: rgba(255, 255, 255, 0.2);
            border-left-color: #27ae60;
        }
        
        .tontine-item h3 {
            font-size: 16px;
            margin-bottom: 5px;
            color: white;
        }
        
        .tontine-item p {
            font-size: 14px;
            color: #bdc3c7;
            margin-bottom: 5px;
        }
        
        .tontine-item .montant {
            color: #2ecc71;
            font-weight: 500;
        }
        
        .tontine-details {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .tontine-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .tontine-header h2 {
            color: #2c3e50;
            font-size: 24px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .tontine-header h2 i {
            color: #27ae60;
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            color: white;
        }
        
        .badge-success {
            background: #27ae60;
        }
        
        .payment-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
        }
        
        .form-section {
            background: #f9f9f9;
            border-radius: 10px;
            padding: 20px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #2c3e50;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            transition: all 0.3s;
        }
        
        .form-control:focus {
            border-color: #27ae60;
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
            outline: none;
        }
        
        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #219653;
            transform: translateY(-2px);
        }
        
        .file-upload {
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
            border: 2px dashed #ddd;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .file-upload:hover {
            border-color: #27ae60;
        }
        
        .file-upload i {
            font-size: 24px;
            color: #7f8c8d;
            margin-bottom: 10px;
        }
        
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 20px;
        }
        
        .summary-card {
            background: white;
            border-radius: 8px;
            padding: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            text-align: center;
        }
        
        .summary-card h3 {
            font-size: 14px;
            color: #7f8c8d;
            margin-bottom: 5px;
        }
        
        .summary-card p {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
        }
        
        .paid {
            color: #27ae60;
        }
        
        .pending {
            color: #f39c12;
        }
        
        .missed {
            color: #e74c3c;
        }
        
        .payment-history {
            margin-top: 30px;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 20px rgba(0,0,0,0.05);
        }
        
        .table th {
            background: #27ae60;
            color: white;
            padding: 12px 15px;
            text-align: left;
            font-weight: 500;
        }
        
        .table td {
            padding: 10px 15px;
            border-bottom: 1px solid #eee;
            color: #2c3e50;
        }
        
        .table tr:last-child td {
            border-bottom: none;
        }
        
        .table tr:hover {
            background: rgba(39, 174, 96, 0.05);
        }
        
        .status-paid {
            color: #27ae60;
            font-weight: 500;
        }
        
        .status-pending {
            color: #f39c12;
            font-weight: 500;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 15px;
            background: white;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border-left: 4px solid;
        }
        
        .alert-success {
            border-left-color: #27ae60;
            color: #27ae60;
        }
        
        .alert-error {
            border-left-color: #e74c3c;
            color: #e74c3c;
        }
        
        .alert i {
            font-size: 20px;
        }
        
        .empty-state {
            text-align: center;
            padding: 30px;
            color: #95a5a6;
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 15px;
            color: #bdc3c7;
        }
        
        @media (max-width: 992px) {
            .container {
                flex-direction: column;
            }
            
            .sidebar {
                width: 100%;
                height: auto;
            }
            
            .payment-form {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Sidebar avec la liste des tontines -->
        <div class="sidebar">
            <h2><i class="fas fa-users"></i> Mes Tontines</h2>
            
            <div class="tontine-list">
                <% for (java.util.Map<String, Object> tontine : userTontines) { 
                    boolean isActive = (Integer)tontine.get("id") == selectedTontineId;
                %>
                    <div class="tontine-item <%= isActive ? "active" : "" %>" 
                         onclick="window.location.href='cotisation.jsp?tontine_id=<%= tontine.get("id") %>'">
                        <h3><%= tontine.get("nom") %></h3>
                        <p><i class="fas fa-calendar-alt"></i> 
                           <%= new SimpleDateFormat("dd/MM/yyyy").format(tontine.get("date_debut")) %> - 
                           <%= new SimpleDateFormat("dd/MM/yyyy").format(tontine.get("date_fin")) %></p>
                        <p class="montant"><i class="fas fa-money-bill-wave"></i> 
                           <%= String.format("%,d", ((BigDecimal)tontine.get("montant_mensuel")).intValue()) %> FCFA/mois</p>
                        <p><i class="fas fa-user-friends"></i> <%= tontine.get("nombre_de_parts") %> part(s)</p>
                    </div>
                <% } %>
            </div>
        </div>
        
        <!-- Contenu principal -->
        <div class="content">
            <!-- Affichage des messages -->
            <% if (session.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle"></i>
                    <div><%= session.getAttribute("successMessage") %></div>
                </div>
                <% session.removeAttribute("successMessage"); %>
            <% } %>
            
            <% if (session.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-error">
                    <i class="fas fa-exclamation-circle"></i>
                    <div><%= session.getAttribute("errorMessage") %></div>
                </div>
                <% session.removeAttribute("errorMessage"); %>
            <% } %>
            
            <!-- Détails de la tontine sélectionnée -->
            <div class="tontine-details">
                <div class="tontine-header">
                    <h2><i class="fas fa-info-circle"></i> <%= tontineName %></h2>
                    <span class="badge badge-success">ACTIVE</span>
                </div>
                <div>
                 <a href="souscription.jsp"><i class="fas fa-check-circle"></i> retour</a>
                </div>
                
                <div class="payment-form">
                    <!-- Formulaire de paiement -->
                    <div class="form-section">
                        <h3><i class="fas fa-money-bill-wave"></i> Nouvelle Cotisation</h3>
                        
                        <form method="post" enctype="multipart/form-data" action="ImageServlet" >
                            <input type="hidden" name="tontine_id" value="<%= selectedTontineId %>">
                            
                            <div class="form-group">
                                <label for="mois_annee">Mois/Année</label>
                                <input type="month" id="mois_annee" name="mois_annee" class="form-control" required 
                                       value="<%= new SimpleDateFormat("yyyy-MM").format(new java.util.Date()) %>">
                            </div>
                            
                            <div class="form-group">
                                <label for="montant">Montant</label>
                                <input type="text" id="montant" class="form-control" 
                                       value="<%= String.format("%,d", montantMensuel.intValue()) %> FCFA" readonly>
                                <small style="color: #27ae60; margin-top: 5px; display: block;">
                                    Fond disponible: <%= String.format("%,d", disponible.intValue()) %> FCFA / 
                                    <%= String.format("%,d", fondCaisse.intValue()) %> FCFA
                                </small>
                            </div>
                            
                        <div class="form-group">
    <label for="methode_paiement">Mode de paiement</label>
    <select id="methode_paiement" name="methode_paiement" class="form-control" required>
        <option value="">Sélectionnez...</option>
        <option value="CASH">Espèces</option>
        <option value="MTNMONEY">Mobile Money</option>
        <option value="BANQUE">Virement Bancaire</option>
        <option value="CHEQUE">Chèque</option>
        <option value="ORANGEMoney">Orange Money</option>
    </select>
</div>

<div class="form-group">
    <label for="reference">Référence</label>
    <input type="text" id="reference" name="reference" class="form-control" 
           placeholder="Numéro de transaction">
</div>
                          
                            <div class="form-group">
                                <label>Preuve de paiement</label>
                                <div class="file-upload" onclick="document.getElementById('fileInput').click()">
                                    <i class="fas fa-cloud-upload-alt"></i>
                                    <span>Cliquez pour téléverser une preuve</span>
                                    <input type="file" id="fileInput" name="preuve_paiement" style="display: none;">
                                </div>
                                
                            </div>
                            
                            <button type="submit" class="btn btn-success">
                                <i class="fas fa-check-circle"></i> Enregistrer le paiement
                            </button>
                        </form>
                    </div>
                    
                    <!-- Résumé des cotisations -->
                    <div class="form-section">
                        <h3><i class="fas fa-chart-pie"></i> Résumé des Cotisations</h3>
                        
                        <div class="summary-cards">
                            <div class="summary-card">
                                <h3>Payées</h3>
                                <p class="paid"><%= paidCount %></p>
                            </div>
                            
                            <div class="summary-card">
                                <h3>En attente</h3>
                                <p class="pending"><%= pendingCount %></p>
                            </div>
                            
                            <div class="summary-card">
                                <h3>En retard</h3>
                                <p class="missed"><%= missedCount %></p>
                            </div>
                        </div>
                        
                        <div style="margin-top: 20px;">
                            <h4 style="color: #2c3e50; margin-bottom: 10px;">
                                <i class="fas fa-calendar-alt"></i> Prochaine échéance
                            </h4>
                            <div style="background: #f8f9fa; padding: 15px; border-radius: 8px;">
                                <p style="color: #2c3e50;">
                                    <i class="fas fa-arrow-right" style="color: #27ae60; margin-right: 10px;"></i>
                                    <strong><%= new SimpleDateFormat("MMMM yyyy").format(new java.util.Date()) %></strong>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Historique des paiements -->
            <div class="payment-history">
                <h3><i class="fas fa-history"></i> Historique des Cotisations</h3>
                
                <%
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT p.*, m.prenom, m.nom FROM paiements p " +
                                "JOIN members m ON p.member_id = m.id " +
                                "WHERE p.tontine_id = ? AND p.member_id = ? " +
                                "AND p.type_paiement = 'COTISATION' " +
                                "ORDER BY p.date_paiement DESC";
                    
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, selectedTontineId);
                        ps.setInt(2, memberId);
                        
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.isBeforeFirst()) {
                %>
                                <div class="empty-state">
                                    <i class="fas fa-inbox"></i>
                                    <h4>Aucune cotisation enregistrée</h4>
                                    <p>Commencez par enregistrer votre première cotisation.</p>
                                </div>
                <%
                            } else {
                %>
                                <div style="overflow-x: auto;">
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Mois/Année</th>
                                                <th>Montant</th>
                                                <th>Date Paiement</th>
                                                <th>Mode</th>
                                                <th>Référence</th>
                                                <th>Statut</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                <%
                                            while (rs.next()) {
                                                String statusClass = "status-paid";
                                                if ("PENDING".equals(rs.getString("statut"))) {
                                                    statusClass = "status-pending";
                                                } else if ("MISSED".equals(rs.getString("statut"))) {
                                                    statusClass = "status-missed";
                                                }
                %>
                                            <tr>
                                                <td><%= rs.getString("mois_annee") %></td>
                                                <td><%= String.format("%,d", rs.getBigDecimal("montant").intValue()) %> FCFA</td>
                                                <td><%= new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("date_paiement")) %></td>
                                                <td><%= rs.getString("methode_paiement") %></td>
                                                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                                                <td class="<%= statusClass %>">
                                                    <i class="fas <%= "COMPLETED".equals(rs.getString("statut")) ? "fa-check-circle" : 
                                                                   "PENDING".equals(rs.getString("statut")) ? "fa-clock" : "fa-times-circle" %>"></i>
                                                    <%= rs.getString("statut") %>
                                                </td>
                                            </tr>
                <%
                                            }
                %>
                                        </tbody>
                                    </table>
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
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Confirmation avant paiement avec vérification du fond disponible
            const form = document.querySelector('form');
            if (form) {
                form.addEventListener('submit', function(e) {
                    const montant = <%= montantMensuel.intValue() %>;
                    const disponible = <%= disponible.intValue() %>;
                    
                    if (montant > disponible) {
                        e.preventDefault();
                        alert('Paiement impossible : Le montant dépasse votre fond de caisse disponible (' + 
                              disponible.toLocaleString() + ' FCFA)');
                        return false;
                    }
                    
                    if (!confirm('Confirmez-vous le paiement de ' + montant.toLocaleString() + 
                               ' FCFA pour la cotisation mensuelle ?\n\nIl vous restera ' + 
                               (disponible - montant).toLocaleString() + ' FCFA disponible.')) {
                        e.preventDefault();
                    }
                });
            }
            
            // Affichage du nom du fichier sélectionné
            const fileInput = document.getElementById('fileInput');
            if (fileInput) {
                fileInput.addEventListener('change', function() {
                    if (this.files && this.files[0]) {
                        const fileUploadDiv = this.closest('.file-upload');
                        if (fileUploadDiv) {
                            const span = fileUploadDiv.querySelector('span');
                            if (span) {
                                span.textContent = this.files[0].name;
                                fileUploadDiv.style.borderColor = '#27ae60';
                            }
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>