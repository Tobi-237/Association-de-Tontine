<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page session="true" %>


<%-- Déclaration des constantes --%>
<%! 
    final BigDecimal SOUSCRIPTION_AMOUNT = new BigDecimal("10000");
    final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("dd/MM/yyyy");
%>

<%-- Traitement de la soumission du formulaire --%>
<%
    // Vérification de l'authentification
    Integer memberId = (Integer) session.getAttribute("memberId");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Traitement du formulaire POST
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        if (request.getParameter("souscrire") != null) {
            processSubscription(request, response, session, memberId);
        }
    }
%>

<%-- Méthodes utilitaires --%>
<%!
    // Méthode pour traiter la souscription
    private void processSubscription(HttpServletRequest request, HttpServletResponse response, 
            HttpSession session, int memberId) throws Exception {
        try {
            int tontineId = Integer.parseInt(request.getParameter("tontine_id"));
            int nombreDeParts = Integer.parseInt(request.getParameter("nombre_de_parts"));

            // Validation des données
            if (nombreDeParts <= 0) {
                setErrorMessage(session, "Le nombre de parts doit être supérieur à zéro.");
                response.sendRedirect("souscription.jsp");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                // Vérification du paiement
                if (!hasValidPayment(conn, memberId, nombreDeParts)) {
                    setErrorMessage(session, "Paiement insuffisant pour le nombre de parts demandé.");
                    response.sendRedirect("payementsouscription.jsp");
                    return;
                }

                // Vérification de l'inscription existante
                if (isAlreadySubscribed(conn, tontineId, memberId)) {
                    setErrorMessage(session, "Vous êtes déjà inscrit à cette tontine.");
                    response.sendRedirect("souscription.jsp");
                    return;
                }

                // Vérification des parts disponibles
                if (!hasAvailableParts(conn, tontineId, nombreDeParts)) {
                    setErrorMessage(session, "Nombre de parts non disponible.");
                    response.sendRedirect("souscription.jsp");
                    return;
                }

                // Enregistrement de la demande
                if (createSubscriptionRequest(conn, tontineId, memberId, nombreDeParts)) {
                    if (addAdherentToTontine(conn, tontineId, memberId, nombreDeParts)) {
                        setSuccessMessage(session, "Votre souscription a été enregistrée avec succès.");
                    } else {
                        setErrorMessage(session, "Erreur lors de l'enregistrement de votre adhésion.");
                    }
                } else {
                    setErrorMessage(session, "Échec de l'envoi de la demande.");
                }
            }
        } catch (NumberFormatException e) {
            setErrorMessage(session, "Données invalides dans le formulaire.");
        } catch (SQLException e) {
            setErrorMessage(session, "Erreur de base de données: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            setErrorMessage(session, "Erreur technique: " + e.getMessage());
            e.printStackTrace();
        }
        response.sendRedirect("souscription.jsp");
    }

private boolean addAdherentToTontine(Connection conn, int tontineId, int memberId, int nombreDeParts) throws SQLException {
    // Version robuste avec vérification des colonnes
    String sql = "INSERT INTO tontine_adherents1 (tontine_id, member_id, nombre_de_parts, date_adhesion) " +
               "VALUES (?, ?, ?, ?)";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, tontineId);
        ps.setInt(2, memberId);
        ps.setInt(3, nombreDeParts);
        ps.setTimestamp(4, new Timestamp(System.currentTimeMillis())); // Date actuelle explicite
        
        return ps.executeUpdate() > 0;
    }
}

    private boolean hasValidPayment(Connection conn, int memberId, int nombreDeParts) throws SQLException {
        String sql = "SELECT COALESCE(SUM(montant), 0) as total_paiement FROM paiements " +
                    "WHERE member_id = ? AND type_paiement = 'SOUSCRIPTION'";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                BigDecimal totalPaiement = rs.getBigDecimal("total_paiement");
                int partsAutorisees = totalPaiement.divide(SOUSCRIPTION_AMOUNT, 0, RoundingMode.DOWN).intValue();
                return nombreDeParts <= partsAutorisees;
            }
            return false;
        }
    }

    private boolean isAlreadySubscribed(Connection conn, int tontineId, int memberId) throws SQLException {
        String sql = "SELECT 1 FROM tontine_adherents1 WHERE tontine_id = ? AND member_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tontineId);
            ps.setInt(2, memberId);
            return ps.executeQuery().next();
        }
    }

    private boolean hasAvailableParts(Connection conn, int tontineId, int nombreDeParts) throws SQLException {
        String sql = "SELECT nombre_parts_max, periode, " +
                    "(SELECT COALESCE(SUM(nombre_de_parts), 0) FROM tontine_adherents1 WHERE tontine_id = ?) as parts_utilisees " +
                    "FROM tontines WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tontineId);
            ps.setInt(2, tontineId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                int partsMax = rs.getInt("nombre_parts_max");
                int partsUtilisees = rs.getInt("parts_utilisees");
                return (partsUtilisees + nombreDeParts) <= partsMax;
            }
            return false;
        }
    }

    private boolean createSubscriptionRequest(Connection conn, int tontineId, int memberId, 
                                           int nombreDeParts) throws SQLException {
        String sql = "INSERT INTO souscription_requests (tontine_id, member_id, request_date, amount, nombre_de_parts, status) " +
                    "VALUES (?, ?, NOW(), ?, ?, 'PENDING')";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tontineId);
            ps.setInt(2, memberId);
            ps.setBigDecimal(3, SOUSCRIPTION_AMOUNT.multiply(new BigDecimal(nombreDeParts)));
            ps.setInt(4, nombreDeParts);
            return ps.executeUpdate() > 0;
        }
    }

    private void setErrorMessage(HttpSession session, String message) {
        session.setAttribute("errorMessage", message);
    }

    private void setSuccessMessage(HttpSession session, String message) {
        session.setAttribute("successMessage", message);
    }

    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&#39;");
    }

    private String formatCurrency(BigDecimal amount) {
        if (amount == null) return "0";
        return String.format("%,d", amount.intValue());
    }

    private String formatDate(Date date) {
        if (date == null) return "Non spécifié";
        return DATE_FORMAT.format(date);
    }

    private int getUsedParts(Connection conn, int tontineId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(nombre_de_parts), 0) as count FROM tontine_adherents1 WHERE tontine_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, tontineId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt("count") : 0;
        }
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Souscription aux Tontines - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            font-family: 'Poppins', sans-serif;
        }
        
        body { 
            background: linear-gradient(135deg, #f5faf5, #e0f2e1);
            display: flex; 
            min-height: 100vh; 
            overflow-x: hidden;
        }
        
        .sidebar {
            width: 250px;
            background: #2c3e50;
            color: white;
            height: 100vh;
            position: fixed;
            transition: all 0.3s;
            z-index: 1000;
        }
        
        .content { 
            flex: 1; 
            padding: 30px; 
            background: rgba(255, 255, 255, 0.95); 
            border-top-left-radius: 20px; 
            overflow-y: auto;
            height: 100vh;
            margin-left: 250px;
            width: calc(100% - 250px);
        }
        
        h2 {
            margin: 20px 0;
            color: #2c3e50;
            font-size: 24px;
            position: relative;
            padding-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        h2:after {
            content: "";
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 3px;
            background: #27ae60;
        }
        
        .alert {
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert-success {
            background: #e8f5e9;
            color: #27ae60;
            border-left: 4px solid #27ae60;
        }
        
        .alert-error {
            background: #ffebee;
            color: #e74c3c;
            border-left: 4px solid #e74c3c;
        }
        
        .tontine-container {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .tontine-list {
            flex: 1;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 20px;
            max-height: 500px;
            overflow-y: auto;
        }
        
        .tontine-details {
            flex: 2;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 20px;
        }
        
        .tontine-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .tontine-item:hover {
            background: #f5f5f5;
        }
        
        .tontine-item.active {
            background: #e8f5e9;
            border-left: 4px solid #27ae60;
        }
        
        .tontine-item h4 {
            margin: 0 0 5px 0;
            color: #2c3e50;
        }
        
        .tontine-item p {
            margin: 0;
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .detail-row {
            display: flex;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .detail-label {
            flex: 1;
            color: #7f8c8d;
            font-weight: 500;
        }
        
        .detail-value {
            flex: 2;
            color: #2c3e50;
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
        }
        
        .btn-success {
            background: #27ae60;
            color: white;
        }
        
        .btn-success:hover {
            background: #219653;
            transform: translateY(-2px);
            box-shadow: 0 4px 10px rgba(39, 174, 96, 0.3);
        }
        
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #95a5a6;
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 15px;
            color: #bdc3c7;
        }
        
        .subscription-form {
            margin-top: 20px;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 8px;
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
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        
        @media (max-width: 768px) {
            .tontine-container {
                flex-direction: column;
            }
            
            .sidebar {
                left: -250px;
            }
            
            .sidebar.active {
                left: 0;
            }
            
            .content {
                margin-left: 0;
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebars.jsp" %>
    
    <div class="content">
        <h2><i class="fas fa-hand-holding-usd"></i> Souscription aux Tontines</h2>
        
        <%-- Affichage des messages d'erreur/succès --%>
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i>
                <%= session.getAttribute("errorMessage") %>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i>
                <%= session.getAttribute("successMessage") %>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
        <h3><i class="fas fa-list-ul"></i> Tontines disponibles</h3>
        <div class="tontine-container">
            <%-- Liste des tontines --%>
            <div class="tontine-list">
                <% displayAvailableTontines(out, memberId); %>
            </div>
            
            <%-- Détails de la tontine --%>
            <div class="tontine-details" id="tontineDetails">
                <% displayDefaultTontineDetails(out, memberId); %>
            </div>
        </div>
        
        <h3><i class="fas fa-user-check"></i> Mes Tontines</h3>
        <% displayUserTontines(out, memberId); %>
    </div>

    <script>
    // Fonction pour afficher les détails d'une tontine
    function showTontineDetails(tontineId) {
        document.querySelectorAll('.tontine-item').forEach(item => {
            item.classList.remove('active');
        });
        document.getElementById('tontine-' + tontineId).classList.add('active');
        
        fetch('getTontineDetails.jsp?tontine_id=' + tontineId)
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(data => {
                document.getElementById('tontineDetails').innerHTML = data;
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('tontineDetails').innerHTML = 
                    '<div class="alert alert-error">Erreur lors du chargement des détails</div>';
            });
    }
    
    // Confirmation avant souscription
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('form').forEach(form => {
            if (form.querySelector('[name="souscrire"]')) {
                form.addEventListener('submit', function(e) {
                    const parts = parseInt(form.querySelector('select[name="nombre_de_parts"]').value);
                    const montantTotal = <%= SOUSCRIPTION_AMOUNT.intValue() %> * parts;
                    
                    if (!confirm('Confirmez-vous la souscription pour ' + parts + ' part(s) (' + montantTotal.toLocaleString('fr-FR') + ' FCFA) ?')) {
                        e.preventDefault();
                    }
                });
            }
        });
    });
    </script>
</body>
</html>

<%-- Méthodes d'affichage --%>
<%!
    private void displayAvailableTontines(JspWriter out, int memberId) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT t.*, u.nom as createur_nom, u.prenom as createur_prenom " +
                        "FROM tontines t JOIN users u ON t.member_id = u.id " +
                        "WHERE t.etat = 'ACTIVE' AND t.id NOT IN " +
                        "(SELECT tontine_id FROM tontine_adherents1 WHERE member_id = ?) " +
                        "ORDER BY t.date_debut DESC";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, memberId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.isBeforeFirst()) {
                        out.println("<div class='empty-state'>");
                        out.println("<i class='fas fa-inbox'></i>");
                        out.println("<h4>Aucune tontine disponible pour le moment</h4>");
                        out.println("<p>Toutes les tontines actives ont déjà été souscrites.</p>");
                        out.println("</div>");
                    } else {
                        boolean firstItem = true;
                        while (rs.next()) {
                            out.println("<div class='tontine-item " + (firstItem ? "active" : "") + "' " +
                                      "onclick='showTontineDetails(" + rs.getInt("id") + ")' " +
                                      "id='tontine-" + rs.getInt("id") + "'>");
                            out.println("<h4><i class='fas fa-users'></i> " + escapeHtml(rs.getString("nom")) + "</h4>");
                            out.println("<p><i class='fas fa-calendar-alt'></i> " + 
                                      formatDate(rs.getDate("date_debut")) + 
                                      " au " + formatDate(rs.getDate("date_fin")) + "</p>");
                            out.println("<p><i class='fas fa-money-bill-wave'></i> " + 
                                      formatCurrency(rs.getBigDecimal("montant_mensuel")) + " FCFA/mois</p>");
                            out.println("</div>");
                            firstItem = false;
                        }
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<div class='alert alert-error'>Erreur lors du chargement des tontines</div>");
            e.printStackTrace();
        }
    }

    private void displayDefaultTontineDetails(JspWriter out, int memberId) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT t.*, u.nom as createur_nom, u.prenom as createur_prenom " +
                        "FROM tontines t JOIN users u ON t.member_id = u.id " +
                        "WHERE t.etat = 'ACTIVE' AND t.id NOT IN " +
                        "(SELECT tontine_id FROM tontine_adherents1 WHERE member_id = ?) " +
                        "ORDER BY t.date_debut DESC LIMIT 1";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, memberId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        displayTontineDetails(out, conn, rs);
                    } else {
                        out.println("<div class='empty-state'>");
                        out.println("<i class='fas fa-inbox'></i>");
                        out.println("<h4>Aucune tontine sélectionnée</h4>");
                        out.println("<p>Sélectionnez une tontine dans la liste pour voir ses détails.</p>");
                        out.println("</div>");
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<div class='alert alert-error'>Erreur lors du chargement des détails</div>");
            e.printStackTrace();
        }
    }

    private void displayTontineDetails(JspWriter out, Connection conn, ResultSet rs) throws Exception {
        int tontineId = rs.getInt("id");
        int partsMax = rs.getInt("nombre_parts_max");
        int partsUtilisees = getUsedParts(conn, tontineId);
        int partsDisponibles = partsMax - partsUtilisees;
        String periode = rs.getString("periode");
        
        out.println("<h3><i class='fas fa-info-circle'></i> Détails de la tontine</h3>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Nom:</div>");
        out.println("<div class='detail-value'>" + escapeHtml(rs.getString("nom")) + "</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Créateur:</div>");
        out.println("<div class='detail-value'>" + escapeHtml(rs.getString("createur_prenom") + " " + rs.getString("createur_nom")) + "</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Période:</div>");
        out.println("<div class='detail-value'>" + formatDate(rs.getDate("date_debut")) + " - " + formatDate(rs.getDate("date_fin")) + "</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Fréquence de cotisation:</div>");
        out.println("<div class='detail-value'>" + (periode != null ? escapeHtml(periode) : "Non spécifiée") + "</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Montant mensuel:</div>");
        out.println("<div class='detail-value'>" + formatCurrency(rs.getBigDecimal("montant_mensuel")) + " FCFA</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Parts disponibles:</div>");
        out.println("<div class='detail-value'>" + partsDisponibles + " / " + partsMax + "</div>");
        out.println("</div>");
        
        out.println("<div class='detail-row'>");
        out.println("<div class='detail-label'>Description:</div>");
        out.println("<div class='detail-value'>" + (rs.getString("description") != null ? escapeHtml(rs.getString("description")) : "Aucune description") + "</div>");
        out.println("</div>");
        
        if (partsDisponibles > 0) {
            out.println("<div class='subscription-form'>");
            out.println("<h4><i class='fas fa-user-plus'></i> Souscrire à cette tontine</h4>");
            out.println("<form method='post'>");
            out.println("<input type='hidden' name='tontine_id' value='" + tontineId + "'>");
            out.println("<div class='form-group'>");
            out.println("<label for='nombre_de_parts'>Nombre de parts:</label>");
            out.println("<select name='nombre_de_parts' id='nombre_de_parts' class='form-control' required>");
            
            int maxParts = Math.min(partsDisponibles, 5);
            for (int i = 1; i <= maxParts; i++) {
                out.println("<option value='" + i + "'>" + i + " part" + (i > 1 ? "s" : "") + 
                          " (" + formatCurrency(SOUSCRIPTION_AMOUNT.multiply(new BigDecimal(i))) + " FCFA)</option>");
            }
            
            out.println("</select>");
            out.println("</div>");
            out.println("<button type='submit' name='souscrire' class='btn btn-success'>");
            out.println("<i class='fas fa-check'></i> Confirmer la souscription");
            out.println("</button>");
            out.println("</form>");
            out.println("</div>");
        } else {
            out.println("<div class='alert alert-error'>");
            out.println("<i class='fas fa-times-circle'></i> Plus de parts disponibles pour cette tontine");
            out.println("</div>");
        }
    }

    private void displayUserTontines(JspWriter out, int memberId) throws Exception {
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT t.id, t.nom, t.montant_mensuel, t.periode, t.date_debut, t.date_fin, " +
                        "ta.date_adhesion as date_adhesion, " +
                        "(ta.nombre_de_parts * " + SOUSCRIPTION_AMOUNT + ") as montant_souscription, " +
                        "ta.nombre_de_parts " + 
                        "FROM tontines t " +
                        "JOIN tontine_adherents1 ta ON t.id = ta.tontine_id " +
                        "WHERE ta.member_id = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, memberId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.isBeforeFirst()) {
                        out.println("<div class='empty-state'>");
                        out.println("<i class='fas fa-user-slash'></i>");
                        out.println("<h4>Vous n'êtes inscrit à aucune tontine</h4>");
                        out.println("<p>Souscrivez à une tontine disponible pour commencer.</p>");
                        out.println("</div>");
                    } else {
                        while (rs.next()) {
                            out.println("<div class='tontine-details' style='margin-top: 20px;'>");
                            out.println("<h3><i class='fas fa-users'></i> " + escapeHtml(rs.getString("nom")) + "</h3>");
                            
                            out.println("<div class='detail-row'>");
                            out.println("<div class='detail-label'>Date de souscription:</div>");
                            out.println("<div class='detail-value'>" + formatDate(rs.getDate("date_adhesion")) + "</div>");
                            out.println("</div>");
                            
                            out.println("<div class='detail-row'>");
                            out.println("<div class='detail-label'>Fréquence de cotisation:</div>");
                            out.println("<div class='detail-value'>" + escapeHtml(rs.getString("periode")) + "</div>");
                            out.println("</div>");
                            
                            out.println("<div class='detail-row'>");
                            out.println("<div class='detail-label'>Nombre de parts:</div>");
                            out.println("<div class='detail-value'>" + rs.getInt("nombre_de_parts") + "</div>");
                            out.println("</div>");
                            
                            out.println("<div class='detail-row'>");
                            out.println("<div class='detail-label'>Montant total:</div>");
                            out.println("<div class='detail-value'>" + formatCurrency(rs.getBigDecimal("montant_souscription")) + " FCFA</div>");
                            out.println("</div>");
                            
                            out.println("<a href='cotisations.jsp?tontine_id=" + rs.getInt("id") + "' class='btn btn-success' style='margin-top: 15px;'>");
                            out.println("<i class='fas fa-file-invoice-dollar'></i> Voir mes cotisations");
                            out.println("</a>");
                            out.println("</div>");
                        }
                    }
                }
            }
        } catch (SQLException e) {
            out.println("<div class='alert alert-error'>Erreur lors du chargement de vos tontines</div>");
            e.printStackTrace();
        }
    }
%>