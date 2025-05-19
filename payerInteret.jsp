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

    // Récupérer l'ID de l'intérêt à payer depuis le paramètre
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect("caisse.jsp");
        return;
    }

    int interetId = Integer.parseInt(idParam);
    
    // Formats
    Locale frenchLocale = Locale.forLanguageTag("fr-FR");
    NumberFormat nf = NumberFormat.getInstance(frenchLocale);
    nf.setMinimumFractionDigits(2);
    nf.setMaximumFractionDigits(2);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
    
    // Variables pour stocker les données
    String nom = "";
    String prenom = "";
    String numero = "";
    String annee = "";
    BigDecimal montantInteret = BigDecimal.ZERO;
    BigDecimal montantInitial = BigDecimal.ZERO;
    BigDecimal taux = BigDecimal.ZERO;
    Date dateCalcul = null;
    try (Connection conn = DBConnection.getConnection()) {
        // Requête pour récupérer les détails de l'intérêt
        String sql = "SELECT i.*, m.nom, m.prenom, m.numero " +
                   "FROM interets_scolaires i " +
                   "JOIN members m ON i.member_id = m.member_id " +
                   "WHERE i.id = ?";
        
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, interetId);
           
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    nom = rs.getString("nom");
                    prenom = rs.getString("prenom");
                    numero = rs.getString("numero");
                    annee = rs.getString("annee");
                    montantInteret = rs.getBigDecimal("montant_interet");
                    montantInitial = rs.getBigDecimal("montant_initial");
                    taux = rs.getBigDecimal("taux_interet");
                    dateCalcul = rs.getDate("date_calcul");
                } else {
                    response.sendRedirect("caisse.jsp");
                    return;
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("caisse.jsp");
        return;
    }
    
    // Traitement de la déduction
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        
        if ("deduire".equals(action)) {
            try (Connection conn = DBConnection.getConnection()) {
                // Mettre à jour le statut de l'intérêt
                String updateSql = "UPDATE interets_scolaires SET statut = 'DEDUCTED', date_paiement = CURRENT_DATE WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, interetId);
                    ps.executeUpdate();
                }
                
                // Enregistrer la déduction dans l'historique
                String insertSql = "INSERT INTO paiements_interets (interet_id, member_id, montant, date_paiement, methode, est_deduction) " +
                                 "VALUES (?, (SELECT member_id FROM interets_scolaires WHERE id = ?), ?, CURRENT_DATE, 'DEDUCTION', 1)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, interetId);
                    ps.setInt(2, interetId);
                    ps.setBigDecimal(3, montantInteret);
                    ps.executeUpdate();
                }
                
                session.setAttribute("successMessage", "Déduction des intérêts enregistrée avec succès");
                response.sendRedirect("caisse.jsp");
                return;
            } catch (SQLException e) {
                e.printStackTrace();
                session.setAttribute("errorMessage", "Erreur lors de l'enregistrement de la déduction");
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement des Intérêts Scolaires | Admin</title>
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
            --orange: #e67e22;
            --mtn-yellow: #ffcc00;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }
        
        body {
            background: var(--light-bg);
            min-height: 100vh;
            color: var(--dark-text);
            padding: 40px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: var(--white);
            border-radius: 16px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.1);
            padding: 40px;
            position: relative;
            overflow: hidden;
        }
        
        .container:before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 5px;
            height: 100%;
            background: linear-gradient(to bottom, var(--primary-color), var(--primary-light));
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(0,0,0,0.1);
        }
        
        .header h2 {
            font-size: 28px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .header h2 i {
            color: var(--primary-color);
        }
        
        .info-card {
            background: rgba(39, 174, 96, 0.05);
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 30px;
        }
        
        .info-row {
            display: flex;
            margin-bottom: 15px;
        }
        
        .info-label {
            font-weight: 500;
            color: var(--light-text);
            width: 200px;
        }
        
        .info-value {
            font-weight: 600;
        }
        
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
            margin-right: 10px;
            margin-bottom: 10px;
            text-decoration: none;
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
        
        .btn-info {
            background: linear-gradient(to right, #3498db, #2980b9);
            color: white;
        }
        
        .btn-info:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3);
        }
        
        .btn-orange {
            background: linear-gradient(to right, var(--orange), #d35400);
            color: white;
        }
        
        .btn-mtn {
            background: linear-gradient(to right, var(--mtn-yellow), #ff9900);
            color: #000;
        }
        
        .btn-outline {
            background: transparent;
            border: 1px solid #ddd;
            color: var(--dark-text);
        }
        
        .btn-outline:hover {
            background: #f5f5f5;
        }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: rgba(39, 174, 96, 0.1);
            color: var(--success);
            border-left: 4px solid var(--success);
        }
        
        .alert-error {
            background: rgba(231, 76, 60, 0.1);
            color: var(--danger);
            border-left: 4px solid var(--danger);
        }
        
        .payment-methods {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        
        .payment-method {
            flex: 1;
            min-width: 120px;
        }
        
        .amount-display {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-color);
            margin: 20px 0;
            text-align: center;
        }
    </style>
</head>
<body>
<%@ include file="sidebar.jsp" %>
    <div class="container">
        <div class="header">
            <h2><i class="fas fa-percentage"></i> Paiement des Intérêts Scolaires</h2>
            <a href="caisse.jsp" class="btn btn-outline">
                <i class="fas fa-arrow-left"></i> Retour
            </a>
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
        
        <div class="info-card">
            <div class="info-row">
                <div class="info-label">Membre:</div>
                <div class="info-value"><%= prenom %> <%= nom %></div>
            </div>
            <div class="info-row">
                <div class="info-label">Numéro:</div>
                <div class="info-value"><%= numero != null ? numero : "Non renseigné" %></div>
            </div>
            <div class="info-row">
                <div class="info-label">Année scolaire:</div>
                <div class="info-value"><%= annee %></div>
            </div>
            <div class="info-row">
                <div class="info-label">Montant initial:</div>
                <div class="info-value"><%= nf.format(montantInitial) %> FCFA</div>
            </div>
            <div class="info-row">
                <div class="info-label">Taux d'intérêt:</div>
                <div class="info-value"><%= taux %> %</div>
            </div>
            <div class="info-row">
                <div class="info-label">Date de calcul:</div>
                <div class="info-value"><%= sdf.format(dateCalcul) %></div>
            </div>
        </div>
        
        <div class="amount-display">
            Montant à payer : <%= nf.format(montantInteret) %> FCFA
        </div>
        
        <form method="POST" action="payerInteret.jsp?id=<%= interetId %>">
            <div class="payment-methods">
                <div class="payment-method">
                    <a href="https://pay.mesomb.com/l/t202bdyU6OE6LAz20yGM?amount=<%= montantInteret %>" class="btn btn-orange">
                        <i class="fas fa-mobile-alt"></i> Payer via Orange Money
                    </a>
                </div>
                <div class="payment-method">
                    <a href="https://pay.mesomb.com/l/t202bdyU6OE6LAz20yGM?amount=<%= montantInteret %>" class="btn btn-mtn">
                        <i class="fas fa-mobile-alt"></i> Payer via MTN Money
                    </a>
                </div>
            </div>
            
            
            <div class="form-group" style="margin-top: 30px;">
                <button type="submit" class="btn btn-info" name="action" value="deduire">
                    <i class="fas fa-minus-circle"></i> Déduire du solde
                </button>
            </div>
        </form>
    </div>
    
    <script>
        // Confirmation avant déduction
        document.querySelector('button[value="deduire"]').addEventListener('click', function(e) {
            if (!confirm("Confirmez-vous la déduction de ces intérêts du solde du membre ?")) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>