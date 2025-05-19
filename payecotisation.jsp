<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page session="true" %>

<%
// Vérification du rôle admin uniquement
String memberRole = (String) session.getAttribute("role");
if (!"ADMIN".equals(memberRole)) {
    response.sendRedirect("login.jsp");
    return;
}

// Variables pour le traitement
String selectedTontineIdParam = request.getParameter("tontine_id");
int selectedTontineId = 0;
if (selectedTontineIdParam != null && !selectedTontineIdParam.isEmpty()) {
    selectedTontineId = Integer.parseInt(selectedTontineIdParam);
}

// Variables pour affichage du bénéficiaire
String selectedBeneficiary = (String) session.getAttribute("selectedBeneficiary");
String beneficiaryId = (String) session.getAttribute("beneficiaryId");
BigDecimal beneficiaryAmount = (BigDecimal) session.getAttribute("beneficiaryAmount");

// Effacer les attributs de session après les avoir récupérés
if (selectedBeneficiary != null) {
    session.removeAttribute("selectedBeneficiary");
    session.removeAttribute("beneficiaryId");
    session.removeAttribute("beneficiaryAmount");
}

// Récupérer toutes les tontines actives
List<java.util.Map<String, Object>> allTontines = new ArrayList<>();
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT t.id, t.nom, t.montant_mensuel, t.date_debut, t.date_fin, t.periode " +
               "FROM tontines t WHERE t.etat = 'ACTIVE'";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> tontine = new java.util.HashMap<>();
                tontine.put("id", rs.getInt("id"));
                tontine.put("nom", rs.getString("nom"));
                tontine.put("montant_mensuel", rs.getBigDecimal("montant_mensuel"));
                tontine.put("date_debut", rs.getDate("date_debut"));
                tontine.put("date_fin", rs.getDate("date_fin"));
                tontine.put("periode", rs.getString("periode"));
                allTontines.add(tontine);
                
                if (selectedTontineId == 0) {
                    selectedTontineId = rs.getInt("id");
                }
            }
        }
    }
} catch (SQLException e) {
    session.setAttribute("errorMessage", "Erreur technique lors de la récupération des tontines");
    e.printStackTrace();
}

// Si aucune tontine active
if (allTontines.isEmpty()) {
    session.setAttribute("errorMessage", "Aucune tontine active disponible");
    response.sendRedirect("admin.jsp");
    return;
}

// Récupérer les détails de la tontine sélectionnée
java.util.Map<String, Object> selectedTontine = null;
for (java.util.Map<String, Object> tontine : allTontines) {
    if ((Integer)tontine.get("id") == selectedTontineId) {
        selectedTontine = tontine;
        break;
    }
}

// Variables pour le formulaire
BigDecimal montantCotisation = selectedTontine != null ? (BigDecimal)selectedTontine.get("montant_mensuel") : BigDecimal.ZERO;
String tontineName = selectedTontine != null ? (String)selectedTontine.get("nom") : "";
String tontinePeriode = selectedTontine != null ? (String)selectedTontine.get("periode") : "";

// Traitement de la sélection du bénéficiaire
if ("POST".equalsIgnoreCase(request.getMethod())) {
    try (Connection conn = DBConnection.getConnection()) {
        // Récupérer les membres éligibles
        String sql = "SELECT m.id, m.nom, m.prenom FROM members m " +
                    "JOIN tontine_adherents1 ta ON m.id = ta.member_id " +
                    "JOIN paiements p ON m.id = p.member_id " +
                    "WHERE ta.tontine_id = ? AND p.tontine_id = ? AND p.type_paiement = 'COTISATION' " +
                    "AND m.id NOT IN (SELECT beneficiary_id FROM tontine_beneficiaries WHERE tontine_id = ?) " +
                    "GROUP BY m.id, m.nom, m.prenom";
        
        List<String> beneficiaries = new ArrayList<>();
        List<String> beneficiaryIds = new ArrayList<>();
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, selectedTontineId);
            ps.setInt(2, selectedTontineId);
            ps.setInt(3, selectedTontineId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    beneficiaries.add(rs.getString("prenom") + " " + rs.getString("nom"));
                    beneficiaryIds.add(rs.getString("id"));
                }
            }
        }
        
        // Si tous ont bénéficié, réinitialiser
        if (beneficiaries.isEmpty()) {
            String resetSql = "DELETE FROM tontine_beneficiaries WHERE tontine_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(resetSql)) {
                ps.setInt(1, selectedTontineId);
                ps.executeUpdate();
            }
            
            // Refaire la requête
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, selectedTontineId);
                ps.setInt(2, selectedTontineId);
                ps.setInt(3, selectedTontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        beneficiaries.add(rs.getString("prenom") + " " + rs.getString("nom"));
                        beneficiaryIds.add(rs.getString("id"));
                    }
                }
            }
        }
        
        // Sélection aléatoire si possible
        if (!beneficiaries.isEmpty()) {
            Collections.shuffle(beneficiaries);
            selectedBeneficiary = beneficiaries.get(0);
            beneficiaryId = beneficiaryIds.get(beneficiaries.indexOf(selectedBeneficiary));
            
            // Enregistrement
            String insertSql = "INSERT INTO tontine_beneficiaries (tontine_id, beneficiary_id, date_benefice, amount) " +
                             "VALUES (?, ?, NOW(), ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, selectedTontineId);
                ps.setString(2, beneficiaryId);
                ps.setBigDecimal(3, montantCotisation);
                ps.executeUpdate();
            }
            
            // Stocker dans la session pour affichage après redirection
            session.setAttribute("selectedBeneficiary", selectedBeneficiary);
            session.setAttribute("beneficiaryId", beneficiaryId);
            session.setAttribute("beneficiaryAmount", montantCotisation);
            session.setAttribute("successMessage", "Bénéficiaire sélectionné: " + selectedBeneficiary);
        } else {
            session.setAttribute("errorMessage", "Aucun membre éligible trouvé");
        }
    } catch (SQLException e) {
        session.setAttribute("errorMessage", "Erreur technique lors de la sélection");
        e.printStackTrace();
    }
    response.sendRedirect("payecotisation.jsp?tontine_id=" + selectedTontineId);
    return;
}

// Récupérer l'historique
List<java.util.Map<String, Object>> beneficiariesHistory = new ArrayList<>();
try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT tb.id, m.nom, m.prenom, tb.amount, tb.date_benefice " +
                "FROM tontine_beneficiaries tb " +
                "JOIN members m ON tb.beneficiary_id = m.id " +
                "WHERE tb.tontine_id = ? " +
                "ORDER BY tb.date_benefice DESC";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, selectedTontineId);
        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> beneficiary = new java.util.HashMap<>();
                beneficiary.put("id", rs.getInt("id"));
                beneficiary.put("nom", rs.getString("nom"));
                beneficiary.put("prenom", rs.getString("prenom"));
                beneficiary.put("amount", rs.getBigDecimal("amount"));
                beneficiary.put("date_benefice", rs.getTimestamp("date_benefice"));
                beneficiariesHistory.add(beneficiary);
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
    <title>Paiement des Cotisations - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #27ae60;
            --primary-dark: #219653;
            --primary-light: #e8f5e9;
            --secondary-color: #f39c12;
            --white: #ffffff;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #2c3e50;
            --orange-money: #ff6600;
            --mtn-money: #ffcc00;
            --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, var(--primary-light) 0%, var(--white) 100%);
            min-height: 100vh;
            color: var(--dark-gray);
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            position: relative;
        }
        
        .header h1 {
            font-size: 2.5rem;
            color: var(--primary-color);
            margin-bottom: 10px;
            position: relative;
            display: inline-block;
        }
        
        .header h1:after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 4px;
            background: var(--primary-color);
            border-radius: 2px;
        }
        
        .header p {
            font-size: 1.1rem;
            color: var(--dark-gray);
            max-width: 700px;
            margin: 0 auto;
        }
        
        .card {
            background: var(--white);
            border-radius: 15px;
            box-shadow: var(--shadow);
            padding: 30px;
            margin-bottom: 30px;
            transition: var(--transition);
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--medium-gray);
        }
        
        .card-header h2 {
            font-size: 1.5rem;
            color: var(--primary-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .card-header h2 i {
            font-size: 1.2em;
        }
        
        .badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--white);
            background: var(--primary-color);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark-gray);
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--medium-gray);
            border-radius: 8px;
            font-size: 1rem;
            transition: var(--transition);
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
            outline: none;
        }
        
        .btn {
            padding: 12px 25px;
            border-radius: 8px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1rem;
            text-align: center;
            justify-content: center;
        }
        
        .btn-primary {
            background: var(--primary-color);
            color: var(--white);
        }
        
        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
        }
        
        .btn-orange {
            background: var(--orange-money);
            color: var(--white);
        }
        
        .btn-orange:hover {
            background: #e65c00;
            transform: translateY(-2px);
        }
        
        .btn-yellow {
            background: var(--mtn-money);
            color: var(--dark-gray);
        }
        
        .btn-yellow:hover {
            background: #e6b800;
            transform: translateY(-2px);
        }
        
        .beneficiary-display {
            text-align: center;
            padding: 30px;
            background: var(--primary-light);
            border-radius: 10px;
            margin: 20px 0;
            animation: fadeIn 0.5s ease;
        }
        
        .beneficiary-display h3 {
            font-size: 1.8rem;
            color: var(--primary-color);
            margin-bottom: 10px;
        }
        
        .beneficiary-display p {
            font-size: 1.2rem;
            margin-bottom: 20px;
        }
        
        .beneficiary-display .amount {
            font-size: 2rem;
            font-weight: 700;
            color: var(--primary-dark);
            margin: 20px 0;
        }
        
        .payment-options {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .payment-option {
            flex: 1;
            min-width: 250px;
            max-width: 300px;
        }
        
        .history-list {
            margin-top: 30px;
        }
        
        .history-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid var(--medium-gray);
            transition: var(--transition);
        }
        
        .history-item:hover {
            background: var(--primary-light);
        }
        
        .history-item .info {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .history-item .avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: var(--primary-color);
            color: var(--white);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
        }
        
        .history-item .details h4 {
            font-size: 1rem;
            color: var(--dark-gray);
            margin-bottom: 5px;
        }
        
        .history-item .details p {
            font-size: 0.8rem;
            color: #7f8c8d;
        }
        
        .history-item .amount {
            font-weight: 600;
            color: var(--primary-dark);
        }
        
        .tontine-selector {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }
        
        .tontine-tab {
            padding: 10px 20px;
            background: var(--white);
            border-radius: 8px;
            cursor: pointer;
            transition: var(--transition);
            border: 1px solid var(--medium-gray);
            font-weight: 500;
        }
        
        .tontine-tab:hover {
            border-color: var(--primary-color);
            color: var(--primary-color);
        }
        
        .tontine-tab.active {
            background: var(--primary-color);
            color: var(--white);
            border-color: var(--primary-color);
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .pulse {
            animation: pulse 2s infinite;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 15px;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .card {
                padding: 20px;
            }
            
            .payment-options {
                flex-direction: column;
                align-items: center;
            }
            
            .payment-option {
                width: 100%;
                max-width: 100%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>
    <div class="container">
        <div class="header">
            <h1><i class="fas fa-hand-holding-usd"></i> Paiement des Cotisations</h1>
            <p>Gérez les bénéficiaires et effectuez les paiements pour les tontines</p>
        </div>
        
        <%-- Affichage des messages d'erreur/succès --%>
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="card" style="background: #ffebee; border-left: 4px solid #e74c3c;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <i class="fas fa-exclamation-circle" style="color: #e74c3c; font-size: 1.5rem;"></i>
                    <div><%= session.getAttribute("errorMessage") %></div>
                </div>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="card" style="background: #e8f5e9; border-left: 4px solid #27ae60;">
                <div style="display: flex; align-items: center; gap: 15px;">
                    <i class="fas fa-check-circle" style="color: #27ae60; font-size: 1.5rem;"></i>
                    <div><%= session.getAttribute("successMessage") %></div>
                </div>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
       
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-users"></i> Sélection de la Tontine</h2>
            </div>
            
            <div class="tontine-selector">
                <% for (java.util.Map<String, Object> tontine : allTontines) { 
                    boolean isActive = (Integer)tontine.get("id") == selectedTontineId;
                %>
                    <div class="tontine-tab <%= isActive ? "active" : "" %>" 
                         onclick="window.location.href='payecotisation.jsp?tontine_id=<%= tontine.get("id") %>'">
                        <%= tontine.get("nom") %>
                    </div>
                <% } %>
            </div>
            
            <% if (selectedTontine != null) { %>
                <div class="form-group">
                    <label>Type de Tontine</label>
                    <div style="display: flex; gap: 10px;">
                        <div style="flex: 1;">
                            <input type="radio" id="type_presence" name="tontine_type" value="PRESENCE" 
                                   <%= "PRESENCE".equals(tontinePeriode) ? "checked" : "" %> class="form-control" style="width: auto;" disabled>
                            <label for="type_presence" style="display: inline;">Présence</label>
                        </div>
                        <div style="flex: 1;">
                            <input type="radio" id="type_hebdo" name="tontine_type" value="HEBDOMADAIRE" 
                                   <%= "HEBDOMADAIRE".equals(tontinePeriode) ? "checked" : "" %> class="form-control" style="width: auto;" disabled>
                            <label for="type_hebdo" style="display: inline;">Hebdomadaire</label>
                        </div>
                        <div style="flex: 1;">
                            <input type="radio" id="type_mensuel" name="tontine_type" value="MENSUELLE" 
                                   <%= "MENSUELLE".equals(tontinePeriode) ? "checked" : "" %> class="form-control" style="width: auto;" disabled>
                            <label for="type_mensuel" style="display: inline;">Mensuelle</label>
                        </div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Montant de la Cotisation</label>
                    <input type="text" class="form-control" value="<%= String.format("%,d", montantCotisation.intValue()) %> FCFA" readonly>
                </div>
                
                <form method="post">
                    <input type="hidden" name="tontine_id" value="<%= selectedTontineId %>">
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-random"></i> Sélectionner aléatoirement le bénéficiaire
                    </button>
                </form>
            <% } %>
        </div>
        
        
        <% if (selectedBeneficiary != null) { %>
            <div class="card pulse">
                <div class="card-header">
                    <h2><i class="fas fa-user-tie"></i> Bénéficiaire Sélectionné</h2>
                    <span class="badge">Nouveau</span>
                </div>
                
                <div class="beneficiary-display">
                    <h3><i class="fas fa-crown"></i> Bénéficiaire désigné</h3>
                    <p>Pour cette période de tontine, le bénéficiaire est :</p>
                    <div class="amount"><%= selectedBeneficiary %></div>
                    <p>Montant à verser : <strong><%= String.format("%,d", beneficiaryAmount.intValue()) %> FCFA</strong></p>
                    
                    <div class="payment-options">
                        <div class="payment-option">
                            <button class="btn btn-orange" onclick="window.open('https://orange-money.com/pay?amount=<%= beneficiaryAmount.intValue() %>&recipient=<%= beneficiaryId %>', '_blank')">
                                <i class="fas fa-money-bill-wave"></i> Payer avec Orange Money
                            </button>
                        </div>
                        <div class="payment-option">
                            <button class="btn btn-yellow" onclick="window.open('https://mtn-money.com/pay?amount=<%= beneficiaryAmount.intValue() %>&recipient=<%= beneficiaryId %>', '_blank')">
                                <i class="fas fa-mobile-alt"></i> Payer avec MTN Money
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        <% } %>
          
        <div class="card">
            <div class="card-header">
                <h2><i class="fas fa-history"></i> Historique des Bénéficiaires</h2>
            </div>
            
            <div class="history-list">
                <% if (beneficiariesHistory.isEmpty()) { %>
                    <div style="text-align: center; padding: 30px; color: #95a5a6;">
                        <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 15px;"></i>
                        <h4>Aucun bénéficiaire enregistré</h4>
                        <p>Les bénéficiaires apparaîtront ici après chaque sélection.</p>
                    </div>
                <% } else { 
                    for (java.util.Map<String, Object> beneficiary : beneficiariesHistory) { 
                        String initials = ((String)beneficiary.get("prenom")).substring(0, 1) + ((String)beneficiary.get("nom")).substring(0, 1);
                %>
                    <div class="history-item">
                        <div class="info">
                            <div class="avatar"><%= initials %></div>
                            <div class="details">
                                <h4><%= beneficiary.get("prenom") %> <%= beneficiary.get("nom") %></h4>
                                <p><%= new SimpleDateFormat("dd/MM/yyyy à HH:mm").format(beneficiary.get("date_benefice")) %></p>
                            </div>
                        </div>
                        <div class="amount">
                            <%= String.format("%,d", ((BigDecimal)beneficiary.get("amount")).intValue()) %> FCFA
                        </div>
                    </div>
                <% } 
                } %>
            </div>
        </div>
    </div>
   
     <script>
        // Animation pour les boutons de paiement
        document.addEventListener('DOMContentLoaded', function() {
            const paymentButtons = document.querySelectorAll('.btn-orange, .btn-yellow');
            paymentButtons.forEach(button => {
                button.addEventListener('mouseenter', function() {
                    this.style.transform = 'scale(1.05)';
                });
                
                button.addEventListener('mouseleave', function() {
                    this.style.transform = 'scale(1)';
                });
            });
            
            // Confirmation avant ouverture du lien de paiement
            document.querySelectorAll('.payment-option button').forEach(button => {
                button.addEventListener('click', function(e) {
                    const amount = <%= selectedBeneficiary != null ? montantCotisation.intValue() : 0 %>;
                    const beneficiary = '<%= selectedBeneficiary != null ? selectedBeneficiary : "" %>';
                    
                    if (!confirm(`Confirmez-vous le paiement de ${amount.toLocaleString('fr-FR')} FCFA à ${beneficiary} ?`)) {
                        e.preventDefault();
                    }
                });
            });
        });
    </script>
</body>
</html>