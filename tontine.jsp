<%@ page import="java.sql.*"%>
<%@ page import="utils.DBConnection"%>
<%@ page import="java.time.LocalDate"%>
<%@ page import="java.util.UUID"%>
<%@ page session="true"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<%
// Variables globales
ResultSet tontineToEdit = null;
boolean isEditMode = false;
String formAction = "CreateTontineServlet";
String formTitle = "Créer un nouveau tour de Tontine";
String buttonLabel = "Créer le tour";
String randomCode = "";

// Vérifier si on est en mode édition
String editId = request.getParameter("editId");
if (editId != null && !editId.trim().isEmpty() && !"null".equalsIgnoreCase(editId)) {
    try {
        // Conversion sécurisée de l'ID
        int tontineId = Integer.parseInt(editId.trim());
        Integer memberId = (Integer) session.getAttribute("memberId");

        if (memberId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            String sql = "SELECT * FROM tontines WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, tontineId);

            tontineToEdit = ps.executeQuery();
            if (tontineToEdit != null && tontineToEdit.next()) {
                isEditMode = true;
                formAction = "UpdateTontineServlet";
                formTitle = "Modifier le tour de Tontine";
                buttonLabel = "Mettre à jour";
                randomCode = tontineToEdit.getString("code");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Erreur de base de données: " + e.getMessage());
        } finally {
            // Fermeture des ressources
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        }
    } catch (NumberFormatException e) {
        request.setAttribute("errorMessage", "ID de tontine invalide: " + editId);
    }
} else {
    // Générer un code aléatoire pour la tontine seulement en mode création
    randomCode = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
}
%>
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Gestion Tontine - Tontine GO-FAR</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
<style>
/* ===== BASE STYLES ===== */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
    font-family: 'Poppins', sans-serif;
}

body {
    background: url('OIP (9).jpeg') no-repeat center center/cover;
    margin: 0;
    display: flex;
    min-height: 100vh;
    width: 100vw;
    overflow-x: hidden;
}

/* ===== CONTENT AREA ===== */
.content {
    flex: 1;
    padding: 2rem;
    overflow-y: auto;
    background: rgba(255, 255, 255, 0.95);
    height: 100vh;
    width: 100%;
}

h2 {
    margin: 1rem 0;
    color: #2c3e50;
    font-size: 1.5rem;
}

/* ===== FORM STYLES ===== */
.form-container {
    max-width: 1000px;
    margin: 0 auto;
    padding: 1.5rem;
    background: white;
    border-radius: 0.5rem;
    box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
}

.form-group {
    margin-bottom: 1rem;
}

label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: #34495e;
    font-size: 0.9rem;
}

input, textarea, select {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #ddd;
    border-radius: 0.375rem;
    font-size: 0.9rem;
    transition: all 0.3s;
}

input:focus, textarea:focus, select:focus {
    border-color: #1abc9c;
    box-shadow: 0 0 0 2px rgba(26, 188, 156, 0.2);
    outline: none;
}

textarea {
    min-height: 100px;
    resize: vertical;
}

/* ===== BUTTON STYLES ===== */
.btn {
    background: #1abc9c;
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    cursor: pointer;
    border-radius: 0.375rem;
    font-size: 0.9rem;
    font-weight: 500;
    transition: all 0.3s;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
}

.btn:hover {
    background: #16a085;
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.btn-cancel {
    background: #e74c3c;
}

.btn-cancel:hover {
    background: #c0392b;
}

.btn-group {
    margin-top: 1.5rem;
    display: flex;
    gap: 0.75rem;
}

/* ===== TABLE STYLES ===== */
.table-container {
    overflow-x: auto;
    margin-top: 2rem;
}

table {
    width: 100%;
    border-collapse: collapse;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    background: white;
    font-size: 0.85rem;
}

th, td {
    padding: 0.75rem 1rem;
    text-align: left;
    color: green;
    border-bottom: 1px solid #eee;
}

th {
    background: #2c3e50;
    color: green;
    font-weight: 500;
    position: sticky;
    top: 0;
}

tr:hover {
    background-color: #f9f9f9;
}

/* ===== ACTION BUTTONS ===== */
.action-btn {
    padding: 0.5rem 0.75rem;
    border: none;
    border-radius: 0.25rem;
    cursor: pointer;
    font-size: 0.8rem;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    transition: all 0.3s;
}

.edit-btn {
    background: #3498db;
    color: white;
}

.edit-btn:hover {
    background: #2980b9;
    transform: translateY(-2px);
}

.delete-btn {
    background: #e74c3c;
    color: white;
}

.delete-btn:hover {
    background: #c0392b;
    transform: translateY(-2px);
}

/* ===== STATE BADGES ===== */
.state-badge {
    color: green;
    padding: 0.25rem 0.5rem;
    border-radius: 1rem;
    font-size: 0.75rem;
    display: inline-block;
}

.state-active {
    background: #2ecc71;
}

.state-completed {
    background: #3498db;
}

.state-cancelled {
    background: #e74c3c;
}

/* ===== FORM SECTIONS ===== */
.form-section {
    margin-bottom: 1.5rem;
}

.form-section h3 {
    margin-bottom: 1rem;
    color: #2c3e50;
    border-bottom: 1px solid #eee;
    padding-bottom: 0.75rem;
    font-size: 1.1rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.required:after {
    content: " *";
    color: #e74c3c;
}

/* ===== PAYMENT METHODS ===== */
.payment-method {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    padding: 0.25rem 0.5rem;
    border-radius: 1rem;
    font-size: 0.75rem;
}

.payment-method.banque {
    background: #e3f2fd;
    color: #1976d2;
}

.payment-method.orangemoney {
    background: #fff3e0;
    color: #ff6d00;
}

.payment-method.mtnmoney {
    background: #e8f5e9;
    color: #2e7d32;
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

/* ===== FORM INLINE ===== */
.inline-form {
    display: inline-block;
    margin-right: 0.5rem;
}

/* ===== CHART CONTAINER ===== */
.chart-container {
    background: white;
    padding: 1.25rem;
    border-radius: 0.5rem;
    box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);
    margin-top: 1rem;
    display: none;
}

.chart-container.show {
    display: block;
}

/* ===== ERROR MESSAGE ===== */
.error-message {
    color: #e74c3c;
    background-color: #fdecea;
    padding: 0.75rem 1rem;
    border-radius: 0.375rem;
    margin-bottom: 1rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

/* ===== RESPONSIVE ADJUSTMENTS ===== */
@media (max-width: 768px) {
    .content {
        padding: 1rem;
    }
    .form-container {
        padding: 1rem;
    }
    .btn-group {
        flex-direction: column;
    }
    .btn {
        width: 100%;
        justify-content: center;
    }
}
</style>
</head>
<body>
    <%@ include file="sidebar.jsp"%>

    <div class="content">
        <!-- Affichage des erreurs -->
        <% if (request.getAttribute("errorMessage") != null) { %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle"></i>
            <%=request.getAttribute("errorMessage")%>
        </div>
        <% } %>

        <!-- Menu déroulant pour les actions -->
        <div class="dropdown">
            <button class="dropdown-btn">
                <i class="fas fa-cog"></i> Actions Tontine <i class="fas fa-chevron-down"></i>
            </button>
            <div class="dropdown-content">
                <a href="enregTontine.jsp"> <i class="fas fa-save"></i> Enregistrer les souscriptions </a> 
                <a href="gerecotisation.jsp"> <i class="fas fa-save"></i> Cotisation </a> 
                <a href="#" id="showChartBtn"> <i class="fas fa-chart-line"></i> Statistiques </a>
            </div>
        </div>

        <!-- Conteneur pour le graphique -->
        <div id="chartContainer" class="chart-container">
            <h3><i class="fas fa-chart-line"></i> Statistiques des souscriptions</h3>
            <canvas id="subscriptionsChart" width="400" height="200"></canvas>
        </div>

        <!-- Formulaire principal -->
        <div class="form-container">
            <h2>
                <i class="<%=isEditMode ? "fas fa-edit" : "fas fa-plus-circle"%>"></i>
                <%=formTitle%>
            </h2>
            <form action="<%=formAction%>" method="post">
                <% if (isEditMode) { %>
                <input type="hidden" name="id" value="<%=tontineToEdit.getInt("id")%>">
                <% } %>

                <div class="form-section">
                    <h3><i class="fas fa-info-circle"></i> Informations de base</h3>

                    <div class="form-group">
                        <label for="code">Code Tontine :</label> 
                        <input type="text" name="code" id="code" value="<%=randomCode%>" readonly> 
                        <small class="form-text">Ce code est généré automatiquement</small>
                    </div>

                    <div class="form-group">
                        <label for="nom" class="required">Nom du tour :</label> 
                        <input type="text" name="nom" id="nom" 
                            value="<%=isEditMode ? tontineToEdit.getString("nom") : "Tontine "%>" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Description :</label>
                        <textarea name="description" id="description" rows="4"><%=isEditMode ? tontineToEdit.getString("description") : "Tour de tontine pour les membres du groupe"%></textarea>
                    </div>
                </div>

                <div class="form-section">
                    <h3><i class="fas fa-money-bill-wave"></i> Détails financiers</h3>

                    <div class="form-group">
                        <label for="montant" class="required">Montant par période (FCFA) :</label> 
                        <input type="number" name="montant" id="montant" 
                            value="<%=isEditMode ? tontineToEdit.getBigDecimal("montant_mensuel") : "1000"%>" required>
                    </div>

                    <div class="form-group">
                        <label for="mode_reglement" class="required">Mode de règlement :</label> 
                        <select name="mode_reglement" id="mode_reglement" required>
                            <option value="">-- Sélectionnez un mode --</option>
                            <option value="Banque" <%=isEditMode && "Banque".equals(tontineToEdit.getString("mode_reglement")) ? "selected" : ""%>>Banque (Virement/Transfert)</option>
                            <option value="OrangeMoney" <%=isEditMode && "OrangeMoney".equals(tontineToEdit.getString("mode_reglement")) ? "selected" : ""%>>Orange Money</option>
                            <option value="MTNMoney" <%=isEditMode && "MTNMoney".equals(tontineToEdit.getString("mode_reglement")) ? "selected" : ""%>>MTN Mobile Money</option>
                        </select>
                    </div>
                </div>

                <div class="form-section">
                    <h3><i class="far fa-calendar-alt"></i> Période et fréquence</h3>

                    <div class="form-group">
                        <label for="frequence" class="required">Fréquence de cotisation :</label> 
                        <select name="frequence" id="frequence" required>
                            <option value="PRESENCE" <%=isEditMode && "PRESENCE".equals(tontineToEdit.getString("frequence")) ? "selected" : ""%>>Présence</option>
                            <option value="HEBDOMADAIRE" <%=isEditMode && "HEBDOMADAIRE".equals(tontineToEdit.getString("frequence")) ? "selected" : ""%>>Hebdomadaire</option>
                            <option value="MENSUELLE" <%=isEditMode && "MENSUELLE".equals(tontineToEdit.getString("frequence")) ? "selected" : ""%>>Mensuelle</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="dateDebut" class="required">Date de début :</label> 
                        <input type="date" name="dateDebut" id="dateDebut" 
                            value="<%=isEditMode ? tontineToEdit.getDate("date_debut").toLocalDate() : LocalDate.now().toString()%>" required>
                    </div>

                    <div class="form-group">
                        <label for="dateFin">Date de fin :</label> 
                        <input type="date" name="dateFin" id="dateFin" readonly 
                            value="<%=isEditMode ? tontineToEdit.getDate("date_fin").toLocalDate() : ""%>">
                    </div>
                </div>

                <div class="btn-group">
                    <button type="submit" class="btn">
                        <i class="fas fa-save"></i> <%=buttonLabel%>
                    </button>

                    <% if (isEditMode) { %>
                    <a href="tontine.jsp" class="btn btn-cancel"> <i class="fas fa-times"></i> Annuler </a>
                    <% } %>
                </div>
            </form>
        </div>

        <h2 style="margin-top: 2rem;"><i class="fas fa-list"></i> Liste des Tontines</h2>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nom</th>
                        <th>Code</th>
                        <th>Montant</th>
                        <th>Fréquence</th>
                        <th>Mode Règlement</th>
                        <th>Date Début</th>
                        <th>Date Fin</th>
                        <th>État</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    Integer memberId = (Integer) session.getAttribute("memberId");
                    if (memberId != null) {
                        Connection conn = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;

                        try {
                            conn = DBConnection.getConnection();
                            String sql = "SELECT t.* FROM tontines t WHERE t.member_id = ? ORDER BY t.date_debut DESC";
                            ps = conn.prepareStatement(sql);
                            ps.setInt(1, memberId);
                            rs = ps.executeQuery();

                            while (rs != null && rs.next()) {
                                String stateClass = "";
                                switch (rs.getString("etat")) {
                                    case "ACTIVE": stateClass = "state-active"; break;
                                    case "COMPLETED": stateClass = "state-completed"; break;
                                    case "CANCELLED": stateClass = "state-cancelled"; break;
                                }

                                String paymentClass = "";
                                String paymentMethod = rs.getString("mode_reglement");
                                if (paymentMethod != null) {
                                    switch (paymentMethod.toLowerCase()) {
                                        case "banque": paymentClass = "banque"; break;
                                        case "orangemoney": paymentClass = "orangemoney"; break;
                                        case "mtnmoney": paymentClass = "mtnmoney"; break;
                                    }
                                }
                    %>
                    <tr>
                        <td><%=rs.getInt("id")%></td>
                        <td><strong><%=rs.getString("nom")%></strong></td>
                        <td><code><%=rs.getString("code") != null ? rs.getString("code") : "N/A"%></code></td>
                        <td><%=String.format("%,d", rs.getBigDecimal("montant_mensuel").intValue())%> FCFA</td>
                        <td><%=rs.getString("frequence")%></td>
                        <td>
                            <% if (paymentMethod != null) { %>
                            <span class="payment-method <%=paymentClass%>">
                                <i class="fas fa-<%=paymentClass.equals("banque") ? "university" : paymentClass.equals("orangemoney") ? "money-bill-wave" : "mobile-alt"%>"></i>
                                <%=paymentMethod%>
                            </span>
                            <% } else { %>
                            Non spécifié
                            <% } %>
                        </td>
                        <td><%=rs.getDate("date_debut")%></td>
                        <td><%=rs.getDate("date_fin")%></td>
                        <td><span class="state-badge <%=stateClass%>"><%=rs.getString("etat")%></span></td>
                        <td>
                            <!-- Bouton Modifier -->
                            <form action="tontine.jsp" method="get" class="inline-form">
                                <input type="hidden" name="editId" value="<%=rs.getInt("id")%>">
                                <button type="submit" class="action-btn edit-btn">
                                    <i class="fas fa-edit"></i> Modifier
                                </button>
                            </form>
                            <!-- Bouton Supprimer -->
                            <form action="DeleteTontineServlet" method="post" class="inline-form">
                                <input type="hidden" name="id" value="<%=rs.getInt("id")%>">
                                <button type="submit" class="action-btn delete-btn">
                                    <i class="fas fa-trash-alt"></i> Supprimer
                                </button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                    %>
                    <tr>
                        <td colspan="10" class="error-message"><i class="fas fa-exclamation-circle"></i> Erreur lors du chargement des tontines</td>
                    </tr>
                    <%
                        } finally {
                            if (rs != null) rs.close();
                            if (ps != null) ps.close();
                            if (conn != null) conn.close();
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="10">Veuillez vous connecter pour voir vos tontines</td>
                    </tr>
                    <%
                    }
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Scripts JS -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Confirmation avant suppression
            document.querySelectorAll('.delete-btn').forEach(button => {
                button.addEventListener('click', function(e) {
                    if (!confirm('Êtes-vous sûr de vouloir supprimer cette tontine ? Cette action est irréversible.')) {
                        e.preventDefault();
                    }
                });
            });
            
            // Gestion du menu déroulant
            document.getElementById('showChartBtn').addEventListener('click', function(e) {
                e.preventDefault();
                const chartContainer = document.getElementById('chartContainer');
                chartContainer.classList.toggle('show');
                
                if (chartContainer.classList.contains('show')) {
                    renderChart();
                }
            });
            
            // Fonction pour afficher le graphique
            function renderChart() {
                const ctx = document.getElementById('subscriptionsChart').getContext('2d');
                
                // Données factices pour l'exemple
                const data = {
                    labels: ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'],
                    datasets: [{
                        label: 'Souscriptions mensuelles',
                        data: [12, 19, 3, 5, 2, 3, 7, 15, 10, 8, 12, 5],
                        backgroundColor: 'rgba(26, 188, 156, 0.2)',
                        borderColor: 'rgba(26, 188, 156, 1)',
                        borderWidth: 2,
                        tension: 0.4,
                        fill: true
                    }]
                };
                
                const config = {
                    type: 'line',
                    data: data,
                    options: {
                        responsive: true,
                        plugins: {
                            legend: {
                                position: 'top',
                            },
                            tooltip: {
                                mode: 'index',
                                intersect: false,
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                title: {
                                    display: true,
                                    text: 'Nombre de souscriptions'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Mois'
                                }
                            }
                        }
                    }
                };
                
                if (window.subscriptionsChart) {
                    window.subscriptionsChart.destroy();
                }
                
                window.subscriptionsChart = new Chart(ctx, config);
            }
            
            // Gestion des changements de fréquence
            const frequenceSelect = document.getElementById('frequence');
            const montantInput = document.getElementById('montant');
            const dateDebutInput = document.getElementById('dateDebut');
            const dateFinInput = document.getElementById('dateFin');
            
            function updateFormBasedOnFrequency() {
                const frequence = frequenceSelect.value;
                
                switch(frequence) {
                    case 'PRESENCE':
                        montantInput.value = 1000;
                        montantInput.min = 1000;
                        montantInput.max = 1000;
                        montantInput.step = 1000;
                        calculateEndDate();
                        break;
                        
                    case 'HEBDOMADAIRE':
                        montantInput.value = 5000;
                        montantInput.min = 5000;
                        montantInput.max = 10000;
                        montantInput.step = 1000;
                        calculateEndDate();
                        break;
                        
                    case 'MENSUELLE':
                        montantInput.value = 15000;
                        montantInput.min = 15000;
                        montantInput.max = 20000;
                        montantInput.step = 1000;
                        calculateEndDate();
                        break;
                }
            }
            
            function calculateEndDate() {
                if (dateDebutInput.value && frequenceSelect.value) {
                    const startDate = new Date(dateDebutInput.value);
                    let endDate = new Date(startDate);
                    
                    switch(frequenceSelect.value) {
                        case 'PRESENCE':
                            // Fin le même jour pour présence
                            break;
                            
                        case 'HEBDOMADAIRE':
                            // Fin 7 jours plus tard
                            endDate.setDate(endDate.getDate() + 7);
                            break;
                            
                        case 'MENSUELLE':
                            // Fin le dernier samedi du mois
                            // D'abord aller à la fin du mois
                            endDate.setMonth(endDate.getMonth() + 1);
                            endDate.setDate(0); // Dernier jour du mois
                            
                            // Puis revenir au dernier samedi
                            while (endDate.getDay() !== 6) { // 6 = samedi
                                endDate.setDate(endDate.getDate() - 1);
                            }
                            break;
                    }
                    
                    dateFinInput.value = endDate.toISOString().split('T')[0];
                }
            }
            
            // Écouteurs d'événements
            frequenceSelect.addEventListener('change', updateFormBasedOnFrequency);
            dateDebutInput.addEventListener('change', calculateEndDate);
            
            // Initialisation
            updateFormBasedOnFrequency();
            if (dateDebutInput.value && !dateFinInput.value) {
                calculateEndDate();
            }
        });
    </script>
</body>
</html>