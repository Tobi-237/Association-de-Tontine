<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Base64" %>
<%@ page import="org.apache.commons.io.IOUtils" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ page import="java.io.InputStream" %>

<%
// Vérifier si l'utilisateur est connecté et est admin
Integer memberId = (Integer) session.getAttribute("memberId");
String memberRole = (String) session.getAttribute("role");
if (memberId == null || !"ADMIN".equals(memberRole)) {
    out.print("<div class='error-message'>Accès non autorisé. Veuillez vous connecter.</div>");
    return;
}

// Récupérer l'ID du sinistre
String idParam = request.getParameter("id");
if (idParam == null || idParam.isEmpty()) {
    out.print("<div class='error-message'>ID de sinistre manquant.</div>");
    return;
}
int sinistreId = Integer.parseInt(idParam);

// Formatage des nombres et dates
NumberFormat nf = NumberFormat.getInstance(new Locale("fr", "FR"));
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");

// Styles CSS intégrés
String styles = "<style>" +
    ":root {" +
    "  --primary-color: #27ae60;" +
    "  --primary-light: #2ecc71;" +
    "  --primary-dark: #219653;" +
    "  --white: #ffffff;" +
    "  --light-bg: #f5f7fa;" +
    "  --dark-text: #2c3e50;" +
    "  --light-text: #7f8c8d;" +
    "  --success: #27ae60;" +
    "  --warning: #f39c12;" +
    "  --danger: #e74c3c;" +
    "  --info: #3498db;" +
    "}" +
    ".details-container {" +
    "  font-family: 'Poppins', sans-serif;" +
    "  color: var(--dark-text);" +
    "}" +
    ".section-title {" +
    "  color: var(--primary-dark);" +
    "  border-bottom: 2px solid var(--primary-light);" +
    "  padding-bottom: 8px;" +
    "  margin-bottom: 15px;" +
    "  font-size: 18px;" +
    "  display: flex;" +
    "  align-items: center;" +
    "  gap: 10px;" +
    "}" +
    ".section-title i {" +
    "  font-size: 20px;" +
    "}" +
    ".grid-2cols {" +
    "  display: grid;" +
    "  grid-template-columns: 1fr 1fr;" +
    "  gap: 20px;" +
    "  margin-bottom: 25px;" +
    "}" +
    ".info-item {" +
    "  margin-bottom: 12px;" +
    "}" +
    ".info-label {" +
    "  font-weight: 500;" +
    "  color: var(--primary-dark);" +
    "}" +
    ".info-value {" +
    "  margin-top: 5px;" +
    "}" +
    ".badge {" +
    "  padding: 5px 10px;" +
    "  border-radius: 20px;" +
    "  font-size: 12px;" +
    "  font-weight: 500;" +
    "  display: inline-flex;" +
    "  align-items: center;" +
    "  gap: 5px;" +
    "}" +
    ".badge-success {" +
    "  background: rgba(39, 174, 96, 0.1);" +
    "  color: var(--success);" +
    "}" +
    ".badge-warning {" +
    "  background: rgba(243, 156, 18, 0.1);" +
    "  color: var(--warning);" +
    "}" +
    ".badge-danger {" +
    "  background: rgba(231, 76, 60, 0.1);" +
    "  color: var(--danger);" +
    "}" +
    ".description-box {" +
    "  background: var(--light-bg);" +
    "  padding: 15px;" +
    "  border-radius: 8px;" +
    "  line-height: 1.6;" +
    "}" +
    ".documents-container {" +
    "  margin-top: 20px;" +
    "}" +
    ".documents-grid {" +
    "  display: grid;" +
    "  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));" +
    "  gap: 15px;" +
    "  margin-top: 15px;" +
    "}" +
    ".document-card {" +
    "  border: 1px solid #eee;" +
    "  border-radius: 8px;" +
    "  overflow: hidden;" +
    "  box-shadow: 0 3px 10px rgba(0,0,0,0.1);" +
    "  transition: all 0.3s;" +
    "}" +
    ".document-card:hover {" +
    "  transform: translateY(-3px);" +
    "  box-shadow: 0 5px 15px rgba(0,0,0,0.15);" +
    "}" +
    ".document-image {" +
    "  width: 100%;" +
    "  height: 120px;" +
    "  object-fit: cover;" +
    "}" +
    ".document-icon {" +
    "  display: flex;" +
    "  flex-direction: column;" +
    "  align-items: center;" +
    "  justify-content: center;" +
    "  height: 120px;" +
    "  background: #f5f5f5;" +
    "  color: var(--dark-text);" +
    "}" +
    ".document-icon i {" +
    "  font-size: 40px;" +
    "  margin-bottom: 10px;" +
    "}" +
    ".document-name {" +
    "  padding: 10px;" +
    "  text-align: center;" +
    "  font-size: 12px;" +
    "  word-break: break-all;" +
    "  background: var(--white);" +
    "}" +
    ".error-message {" +
    "  color: var(--danger);" +
    "  text-align: center;" +
    "  padding: 20px;" +
    "}" +
    ".actions {" +
    "  display: flex;" +
    "  gap: 10px;" +
    "  margin-top: 20px;" +
    "}" +
    ".btn {" +
    "  padding: 8px 16px;" +
    "  border-radius: 6px;" +
    "  font-weight: 500;" +
    "  cursor: pointer;" +
    "  display: inline-flex;" +
    "  align-items: center;" +
    "  gap: 5px;" +
    "  font-size: 13px;" +
    "  transition: all 0.3s;" +
    "  border: none;" +
    "}" +
    ".btn-success {" +
    "  background: var(--success);" +
    "  color: white;" +
    "}" +
    ".btn-danger {" +
    "  background: var(--danger);" +
    "  color: white;" +
    "}" +
    ".btn i {" +
    "  font-size: 12px;" +
    "}" +
    "@media (max-width: 768px) {" +
    "  .grid-2cols {" +
    "    grid-template-columns: 1fr;" +
    "  }" +
    "}" +
    "</style>";

out.print(styles);

try (Connection conn = DBConnection.getConnection()) {
    String sql = "SELECT s.*, m.nom, m.prenom, m.email, m.numero, a.type_assurance, " +
                "a.montant_couverture, a.prime_mensuelle, c.nom as compagnie_nom, " +
                "s.documents as documents_data " +
                "FROM sinistres s " +
                "JOIN members m ON s.member_id = m.member_id " +
                "JOIN assurances a ON s.assurance_id = a.id " +
                "LEFT JOIN compagnies_assurance c ON a.compagnie_id = c.id " +
                "WHERE s.id = ?";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, sinistreId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                String statutClass = "";
                if ("PAYE".equals(rs.getString("statut"))) {
                    statutClass = "badge-success";
                } else if ("EN_COURS".equals(rs.getString("statut"))) {
                    statutClass = "badge-warning";
                } else if ("REJETE".equals(rs.getString("statut"))) {
                    statutClass = "badge-danger";
                }
                
                // Récupération des documents (supposés stockés en BLOB)
                byte[] documentsBlob = rs.getBytes("documents_data");
                boolean hasDocuments = documentsBlob != null && documentsBlob.length > 0;
%>
                <div class="details-container">
                    <div class="grid-2cols">
                        <div>
                            <h3 class="section-title"><i class="fas fa-user"></i> Informations du Membre</h3>
                            <div class="info-item">
                                <div class="info-label">Nom complet</div>
                                <div class="info-value"><%= rs.getString("prenom") + " " + rs.getString("nom") %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Email</div>
                                <div class="info-value"><%= rs.getString("email") %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Téléphone</div>
                                <div class="info-value"><%= rs.getString("numero") != null ? rs.getString("numero") : "Non renseigné" %></div>
                            </div>
                        </div>
                        
                        <div>
                            <h3 class="section-title"><i class="fas fa-file-medical"></i> Détails du Sinistre</h3>
                            <div class="info-item">
                                <div class="info-label">Statut</div>
                                <div class="info-value">
                                    <span class="badge <%= statutClass %>">
                                        <i class="fas fa-circle"></i> <%= rs.getString("statut") %>
                                    </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Date du sinistre</div>
                                <div class="info-value"><%= sdf.format(rs.getTimestamp("date_sinistre")) %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Type</div>
                                <div class="info-value"><%= rs.getString("type_sinistre") %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Montant demandé</div>
                                <div class="info-value"><%= nf.format(rs.getBigDecimal("montant_indemnisation")) %> FCFA</div>
                            </div>
                        </div>
                    </div>
                    
                    <div>
                        <h3 class="section-title"><i class="fas fa-shield-alt"></i> Informations de l'Assurance</h3>
                        <div class="grid-2cols">
                            <div>
                                <div class="info-item">
                                    <div class="info-label">Type d'assurance</div>
                                    <div class="info-value"><%= rs.getString("type_assurance") %></div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Montant couverture</div>
                                    <div class="info-value"><%= nf.format(rs.getBigDecimal("montant_couverture")) %> FCFA</div>
                                </div>
                            </div>
                            <div>
                                <div class="info-item">
                                    <div class="info-label">Prime mensuelle</div>
                                    <div class="info-value"><%= nf.format(rs.getBigDecimal("prime_mensuelle")) %> FCFA</div>
                                </div>
                                <div class="info-item">
                                    <div class="info-label">Compagnie</div>
                                    <div class="info-value"><%= rs.getString("compagnie_nom") != null ? rs.getString("compagnie_nom") : "Assurance interne" %></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div>
                        <h3 class="section-title"><i class="fas fa-align-left"></i> Description du Sinistre</h3>
                        <div class="description-box">
                            <%= rs.getString("description") %>
                        </div>
                    </div>
                    
                    <div class="documents-container">
                        <h3 class="section-title"><i class="fas fa-file-upload"></i> Documents Justificatifs</h3>
                        <% if (hasDocuments) { 
                            // Dans une vraie application, vous devriez parser le BLOB pour extraire les fichiers individuels
                            // Ceci est un exemple simplifié
                        %>
                        <div class="documents-grid">
                            <div class="document-card">
                                <div class="document-icon">
                                    <i class="fas fa-file-pdf"></i>
                                    <div>Document_1.pdf</div>
                                </div>
                                <div class="document-name">Rapport médical</div>
                            </div>
                            <div class="document-card">
                                <div class="document-icon">
                                    <i class="fas fa-file-image"></i>
                                    <div>Photo_1.jpg</div>
                                </div>
                                <div class="document-name">Photo du sinistre</div>
                            </div>
                            <div class="document-card">
                                <div class="document-icon">
                                    <i class="fas fa-file-invoice"></i>
                                    <div>Facture.pdf</div>
                                </div>
                                <div class="document-name">Facture médicale</div>
                            </div>
                        </div>
                        <% } else { %>
                        <div style="color: var(--light-text); text-align: center; padding: 20px;">
                            <i class="fas fa-inbox" style="font-size: 30px; margin-bottom: 10px;"></i>
                            <p>Aucun document justificatif fourni</p>
                        </div>
                        <% } %>
                    </div>
                    
                    <% if ("EN_COURS".equals(rs.getString("statut"))) { %>
                    <div class="actions">
                        <button class="btn btn-success" onclick="payerSinistre(<%= sinistreId %>)">
                            <i class="fas fa-check"></i> Payer le sinistre
                        </button>
                        <button class="btn btn-danger" onclick="rejeterSinistre(<%= sinistreId %>)">
                            <i class="fas fa-times"></i> Rejeter la demande
                        </button>
                    </div>
                    <% } %>
                </div>
                
                <script>
                    function payerSinistre(id) {
                        if (confirm('Confirmez-vous le paiement de ce sinistre ?')) {
                            fetch('payerSinistre.jsp?id=' + id)
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        alert('Le sinistre a été marqué comme payé.');
                                        window.location.reload();
                                    } else {
                                        alert('Erreur: ' + data.message);
                                    }
                                })
                                .catch(error => {
                                    console.error('Error:', error);
                                    alert('Une erreur est survenue lors du paiement.');
                                });
                        }
                    }
                    
                    function rejeterSinistre(id) {
                        const raison = prompt('Veuillez indiquer la raison du rejet :');
                        if (raison !== null && raison.trim() !== '') {
                            fetch('rejeterSinistre.jsp?id=' + id + '&raison=' + encodeURIComponent(raison))
                                .then(response => response.json())
                                .then(data => {
                                    if (data.success) {
                                        alert('Le sinistre a été rejeté.');
                                        window.location.reload();
                                    } else {
                                        alert('Erreur: ' + data.message);
                                    }
                                })
                                .catch(error => {
                                    console.error('Error:', error);
                                    alert('Une erreur est survenue lors du rejet.');
                                });
                        }
                    }
                </script>
<%
            } else {
                out.print("<div class='error-message'>" +
                         "<i class='fas fa-exclamation-triangle'></i>" +
                         "<p>Sinistre non trouvé</p>" +
                         "</div>");
            }
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
    out.print("<div class='error-message'>" +
             "<i class='fas fa-exclamation-triangle'></i>" +
             "<p>Erreur de base de données: " + e.getMessage() + "</p>" +
             "</div>");
}
%>