<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page session="true" %>
<%
    // Vérifier si l'utilisateur est administrateur
    Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
    if (isAdmin == null || !isAdmin) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Variables
    String successMessage = null;
    String errorMessage = null;
    String selectedTontineId = request.getParameter("tontine_id");
    // Traitement des actions
    if (request.getMethod().toString().equals("POST")) {
        if (request.getParameter("approve") != null) {
            // Approbation d'une souscription
            int requestId = Integer.parseInt(request.getParameter("approve"));
            
            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                
                // Récupérer les détails de la demande
                String selectSql = "SELECT * FROM souscription_requests WHERE id = ?";
                try (PreparedStatement selectPs = conn.prepareStatement(selectSql)) {
                    selectPs.setInt(1, requestId);
                    ResultSet rs = selectPs.executeQuery();
                    
                    if (rs.next()) {
                        int tontineId = rs.getInt("tontine_id");
                        int memberId = rs.getInt("member_id");
                        BigDecimal amount = rs.getBigDecimal("amount");
                        int nombreParts = rs.getInt("nombre_de_parts");
                        
                        // Vérifier si le membre est déjà inscrit
                        String checkSql = "SELECT 1 FROM tontine_adherents1 WHERE tontine_id = ? AND member_id = ?";
                        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                            checkPs.setInt(1, tontineId);
                            checkPs.setInt(2, memberId);
                            
                            if (checkPs.executeQuery().next()) {
                                errorMessage = "Le membre est déjà inscrit à cette tontine";
                                conn.rollback();
                            } else {
                                // Vérifier que le membre existe
                                String memberCheckSql = "SELECT 1 FROM members WHERE id = ?";
                                try (PreparedStatement memberCheckPs = conn.prepareStatement(memberCheckSql)) {
                                    memberCheckPs.setInt(1, memberId);
                                    
                                    if (!memberCheckPs.executeQuery().next()) {
                                        errorMessage = "Le membre ID " + memberId + " n'existe pas";
                                        conn.rollback();
                                    } else {
                                        // Enregistrer la souscription
                                        String insertSql = "INSERT INTO tontine_adherents1 (tontine_id, member_id, date_souscription, montant_souscription, nombre_de_parts) VALUES (?, ?, NOW(), ?, ?)";
                                        try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                                            insertPs.setInt(1, tontineId);
                                            insertPs.setInt(2, memberId);
                                            insertPs.setBigDecimal(3, amount);
                                            insertPs.setInt(4, nombreParts);
                                            insertPs.executeUpdate();
                                        }
                                        
                                        // Mettre à jour le statut de la demande
                                        String updateSql = "UPDATE souscription_requests SET status = 'APPROVED', processed_date = NOW() WHERE id = ?";
                                        try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                                            updatePs.setInt(1, requestId);
                                            updatePs.executeUpdate();
                                        }
                                        
                                        conn.commit();
                                        successMessage = "Souscription approuvée avec succès";
                                    }
                                }
                            }
                        }
                    } else {
                        errorMessage = "Demande de souscription introuvable";
                    }
                }
            } catch(Exception e) {
                e.printStackTrace();
                errorMessage = "Erreur lors de l'approbation: " + e.getMessage();
            }
        } 
        else if (request.getParameter("reject") != null) {
            // Rejet d'une souscription
            int requestId = Integer.parseInt(request.getParameter("reject"));
            
            try (Connection conn = DBConnection.getConnection()) {
                String updateSql = "UPDATE souscription_requests SET status = 'REJECTED', processed_date = NOW() WHERE id = ?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setInt(1, requestId);
                    updatePs.executeUpdate();
                    successMessage = "Souscription rejetée avec succès";
                }
            } catch(Exception e) {
                e.printStackTrace();
                errorMessage = "Erreur lors du rejet: " + e.getMessage();
            }
        }
        else if (request.getParameter("update_parts") != null) {
            // Mise à jour du nombre de parts
            int adherentId = Integer.parseInt(request.getParameter("adherent_id"));
            int newParts = Integer.parseInt(request.getParameter("nombre_part"));
            
            try (Connection conn = DBConnection.getConnection()) {
                String updateSql = "UPDATE tontine_adherents1 SET nombre_de_parts = ? WHERE id = ?";
                try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                    updatePs.setInt(1, newParts);
                    updatePs.setInt(2, adherentId);
                    updatePs.executeUpdate();
                    successMessage = "Nombre de parts mis à jour avec succès";
                }
            } catch(Exception e) {
                e.printStackTrace();
                errorMessage = "Erreur lors de la mise à jour: " + e.getMessage();
            }
        }
        else if (request.getParameter("remove_adherent") != null) {
            // Suppression d'un adhérent
            int adherentId = Integer.parseInt(request.getParameter("adherent_id"));
            
            try (Connection conn = DBConnection.getConnection()) {
                String deleteSql = "DELETE FROM tontine_adherents1 WHERE id = ?";
                try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                    deletePs.setInt(1, adherentId);
                    deletePs.executeUpdate();
                    successMessage = "Adhérent supprimé avec succès";
                }
            } catch(Exception e) {
                e.printStackTrace();
                errorMessage = "Erreur lors de la suppression: " + e.getMessage();
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Tontines | Tontine Manager</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2ecc71;
            --primary-dark: #27ae60;
            --primary-light: #d5f5e3;
            --white: #ffffff;
            --light-gray: #f5f5f5;
            --medium-gray: #e0e0e0;
            --dark-gray: #333333;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            --transition: all 0.3s ease;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: url('OIP (9).jpeg') no-repeat center center/cover;
            margin: 0;
            display: flex;
            min-height: 100vh;
            width: 100vw;
            overflow: hidden;
        }

        .content {
            flex: 1;
            padding: 40px;
            overflow-y: auto;
            background: rgba(255, 255, 255, 0.95);
            border-top-left-radius: 20px;
            height: 100vh;
            width: 100%;
            transition: var(--transition);
        }

        h2 {
            color: var(--primary-dark);
            margin-bottom: 20px;
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        h2 i {
            color: var(--primary-color);
        }

        h3 {
            color: var(--primary-dark);
            margin-bottom: 20px;
            font-size: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        h3 i {
            color: var(--primary-color);
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
            cursor: pointer;
            border: none;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: var(--white);
        }

        .btn-primary:hover {
            background-color: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .btn-danger {
            background-color: #e74c3c;
            color: var(--white);
        }

        .btn-danger:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .btn-warning {
            background-color: #f39c12;
            color: var(--white);
        }

        .btn-warning:hover {
            background-color: #d35400;
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .btn-sm {
            padding: 8px 15px;
            font-size: 14px;
        }

        .card {
            background-color: var(--white);
            border-radius: 12px;
            padding: 25px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .table-container {
            overflow-x: auto;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 800px;
        }

        thead {
            background-color: var(--primary-color);
            color: var(--white);
        }

        th {
            padding: 15px;
            text-align: left;
            font-weight: 500;
            text-transform: uppercase;
            font-size: 14px;
            letter-spacing: 0.5px;
        }

        td {
            padding: 15px;
            border-bottom: 1px solid var(--medium-gray);
        }

        tbody tr {
            transition: var(--transition);
        }

        tbody tr:hover {
            background-color: var(--primary-light);
            transform: scale(1.01);
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            display: flex;
            align-items: center;
            gap: 15px;
            animation: slideIn 0.5s ease;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }

        .alert-success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border-left: 5px solid #2ecc71;
        }

        .alert-error {
            background-color: #ffebee;
            color: #c62828;
            border-left: 5px solid #e74c3c;
        }

        .alert i {
            font-size: 20px;
        }

        form {
            display: inline;
        }

        .tontine-selector {
            display: flex;
            gap: 15px;
            margin-bottom: 20px;
            align-items: center;
        }

        .tontine-selector select {
            padding: 10px 15px;
            border-radius: 6px;
            border: 1px solid var(--medium-gray);
            font-size: 16px;
            min-width: 300px;
        }

        .tontine-selector button {
            margin-left: 10px;
        }

        .tontine-details {
            background-color: var(--light-gray);
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .tontine-details h4 {
            margin-bottom: 10px;
            color: var(--primary-dark);
        }

        .tontine-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
        }

        .detail-item {
            background-color: var(--white);
            padding: 15px;
            border-radius: 6px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .detail-item label {
            font-weight: 600;
            color: var(--dark-gray);
            display: block;
            margin-bottom: 5px;
        }

        .detail-item span {
            color: var(--dark-gray);
        }

        .parts-input {
            width: 60px;
            padding: 5px;
            text-align: center;
            border: 1px solid var(--medium-gray);
            border-radius: 4px;
        }

        /* Animation for buttons */
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        .btn-animate {
            animation: pulse 2s infinite;
        }

        .btn-animate:hover {
            animation: none;
        }

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }
            
            .card {
                padding: 15px;
            }
            
            th, td {
                padding: 10px 8px;
                font-size: 13px;
            }
            
            .tontine-selector {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .tontine-selector select {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <h2><i class="fas fa-users-cog"></i> Gestion des Tontines</h2>
        
        <%-- Affichage des messages --%>
        <% if (successMessage != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= successMessage %>
            </div>
        <% } %>
        
        <% if (errorMessage != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= errorMessage %>
            </div>
        <% } %>
        
        <div class="card">
            <h3><i class="fas fa-list-ul"></i> Sélectionnez une Tontine</h3>
            
            <form method="get" class="tontine-selector">
                <select name="tontine_id" required>
                    <option value="">-- Sélectionnez une tontine --</option>
                    <%
                    try (Connection conn = DBConnection.getConnection()) {
                        String sql = "SELECT id, nom, code FROM tontines ORDER BY nom";
                        try (PreparedStatement ps = conn.prepareStatement(sql);
                             ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                String selected = selectedTontineId != null && selectedTontineId.equals(rs.getString("id")) ? "selected" : "";
                    %>
                    <option value="<%= rs.getInt("id") %>" <%= selected %>>
                        <%= rs.getString("nom") %> (<%= rs.getString("code") %>)
                    </option>
                    <%
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                    %>
                </select>
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-search"></i> Voir les détails
                </button>
            </form>
            
            <%-- Affichage des détails de la tontine sélectionnée --%>
            <% if (selectedTontineId != null && !selectedTontineId.isEmpty()) { 
                try (Connection conn = DBConnection.getConnection()) {
                    String sql = "SELECT * FROM tontines WHERE id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(selectedTontineId));
                        ResultSet rs = ps.executeQuery();
                        
                        if (rs.next()) {
            %>
            <div class="tontine-details">
                <h4><i class="fas fa-info-circle"></i> Détails de la Tontine</h4>
                <div class="tontine-details-grid">
                    <div class="detail-item">
                        <label>Nom:</label>
                        <span><%= rs.getString("nom") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Code:</label>
                        <span><%= rs.getString("code") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Montant mensuel:</label>
                        <span><%= String.format("%,d", rs.getBigDecimal("montant_mensuel").intValue()) %> FCFA</span>
                    </div>
                    <div class="detail-item">
                        <label>Période:</label>
                        <span><%= rs.getString("periode") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Fréquence:</label>
                        <span><%= rs.getString("frequence") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Date début:</label>
                        <span><%= rs.getDate("date_debut") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Date fin:</label>
                        <span><%= rs.getDate("date_fin") %></span>
                    </div>
                    <div class="detail-item">
                        <label>Parts max/membre:</label>
                        <span><%= rs.getInt("nombre_parts_max") %></span>
                    </div>
                </div>
            </div>
            <%
                        }
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            %>
            
            <h3><i class="fas fa-user-plus"></i> Demandes de Souscription</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Membre</th>
                            <th>Date Demande</th>
                            <th>Montant</th>
                            <th>Parts</th>
                            <th>Statut</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        try (Connection conn = DBConnection.getConnection()) {
                            String sql = "SELECT sr.*, m.nom as membre_nom, m.prenom as membre_prenom " +
                                        "FROM souscription_requests sr " +
                                        "JOIN members m ON sr.member_id = m.id " +
                                        "WHERE sr.tontine_id = ? AND sr.status = 'PENDING' " +
                                        "ORDER BY sr.request_date DESC";
                            
                            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                ps.setInt(1, Integer.parseInt(selectedTontineId));
                                ResultSet rs = ps.executeQuery();
                                
                                while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("membre_prenom") %> <%= rs.getString("membre_nom") %></td>
                            <td><%= rs.getTimestamp("request_date") %></td>
                            <td><%= String.format("%,d", rs.getBigDecimal("amount").intValue()) %> FCFA</td>
                            <td><%= rs.getInt("nombre_de_parts") %></td>
                            <td><span class="status-pending">En attente</span></td>
                            <td>
                            
                                <form method="post" style="display: inline;">
                                    <input type="hidden" name="approve" value="<%= rs.getInt("id") %>">
                                    <button type="submit" class="btn btn-primary btn-sm btn-animate">
                                        <i class="fas fa-check"></i> Valider
                                    </button>
                                </form>
                                <form method="post" style="display: inline;">
                                    <input type="hidden" name="reject" value="<%= rs.getInt("id") %>">
                                    <button type="submit" class="btn btn-danger btn-sm">
                                        <i class="fas fa-times"></i> Rejeter
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                        %>
                    </tbody>
                </table>
            </div>
            
            <h3 style="margin-top: 30px;"><i class="fas fa-users"></i> Adhérents Actuels</h3>
            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Membre</th>
                            <th>Date Souscription</th>
                            <th>Montant</th>
                            <th>Parts</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        if (selectedTontineId != null && !selectedTontineId.isEmpty()) {
                            try (Connection conn = DBConnection.getConnection()) {
                                String sql = "SELECT ta.*, m.nom as membre_nom, m.prenom as membre_prenom " +
                                            "FROM tontine_adherents1 ta " +
                                            "JOIN members m ON ta.member_id = m.id " +
                                            "WHERE ta.tontine_id = ? " +
                                            "ORDER BY ta.date_souscription DESC";
                                
                                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                                    ps.setInt(1, Integer.parseInt(selectedTontineId));
                                    ResultSet rs = ps.executeQuery();
                                    
                                    while (rs.next()) {
                        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getString("membre_prenom") %> <%= rs.getString("membre_nom") %></td>
                            <td><%= rs.getTimestamp("date_souscription") %></td>
                            <td><%= String.format("%,d", rs.getBigDecimal("montant_souscription").intValue()) %> FCFA</td>
                            <td>
                                <form method="post" style="display: inline;">
                                    <input type="hidden" name="adherent_id" value="<%= rs.getInt("id") %>">
                                    <input type="number" name="nombre_part" value="<%= rs.getInt("nombre_de_parts") %>" 
                                           min="1" max="10" class="parts-input">
                                    <button type="submit" name="update_parts" class="btn btn-warning btn-sm">
                                        <i class="fas fa-sync-alt"></i> Mettre à jour
                                    </button>
                                </form>
                            </td>
                            <td>
                                <form method="post" style="display: inline;">
                                    <input type="hidden" name="adherent_id" value="<%= rs.getInt("id") %>">
                                    <button type="submit" name="remove_adherent" class="btn btn-danger btn-sm">
                                        <i class="fas fa-trash-alt"></i> Supprimer
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <%
                                    }
                                }
                            } catch (SQLException e) {
                                e.printStackTrace();
                            }
                        }
                        %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <script>
        // Confirmation avant actions
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                let confirmMessage = "";
                
                if (this.querySelector('button[name="approve"]')) {
                    confirmMessage = "Confirmez-vous la validation de cette souscription ?";
                } else if (this.querySelector('button[name="reject"]')) {
                    confirmMessage = "Confirmez-vous le rejet de cette souscription ?";
                } else if (this.querySelector('button[name="remove_adherent"]')) {
                    confirmMessage = "Confirmez-vous la suppression de cet adhérent ?";
                }
                
                if (confirmMessage && !confirm(confirmMessage)) {
                    e.preventDefault();
                } else if (confirmMessage) {
                    // Animation de confirmation
                    const button = this.querySelector('button');
                    if (button) {
                        const originalHtml = button.innerHTML;
                        button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Traitement...';
                        button.disabled = true;
                        
                        // Restaurer après 3 secondes au cas où la page ne se recharge pas
                        setTimeout(() => {
                            button.innerHTML = originalHtml;
                            button.disabled = false;
                        }, 3000);
                    }
                }
            });
        });

        // Animation au survol des lignes du tableau
        document.querySelectorAll('tbody tr').forEach(row => {
            row.addEventListener('mouseenter', () => {
                row.style.transform = 'scale(1.01)';
                row.style.boxShadow = '0 5px 15px rgba(46, 204, 113, 0.2)';
            });
            
            row.addEventListener('mouseleave', () => {
                row.style.transform = 'scale(1)';
                row.style.boxShadow = 'none';
            });
        });
    </script>
</body>
</html>