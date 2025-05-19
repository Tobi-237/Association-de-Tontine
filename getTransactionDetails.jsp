<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, utils.DBConnection, java.text.SimpleDateFormat" %>
<%
    int transactionId = 0;
    try {
        transactionId = Integer.parseInt(request.getParameter("id"));
    } catch(NumberFormatException e) {
        out.println("<div class='alert alert-danger'><i class='fas fa-exclamation-circle'></i> ID de transaction invalide</div>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DBConnection.getConnection();
        String query = "SELECT p.*, t.nom AS tontine_name, m.prenom, m.nom " +
                       "FROM paiements p " +
                       "LEFT JOIN tontines t ON p.tontine_id = t.id " +
                       "LEFT JOIN members m ON p.member_id = m.id " +
                       "WHERE p.id = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, transactionId);
        rs = pstmt.executeQuery();
        
        if(rs.next()) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            SimpleDateFormat displayFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
            Date datePaiement = new Date(rs.getTimestamp("date_paiement").getTime());
            String formattedDate = displayFormat.format(datePaiement);
            
            String tontineName = rs.getString("tontine_name");
            if(tontineName == null) tontineName = "N/A";
            
            String statutClass = "";
            String statutIcon = "";
            String statutText = rs.getString("statut");
            switch(statutText) {
                case "PENDING": 
                    statutClass = "badge-warning";
                    statutIcon = "fas fa-clock";
                    statutText = "En attente";
                    break;
                case "COMPLETED": 
                    statutClass = "badge-success";
                    statutIcon = "fas fa-check-circle";
                    statutText = "Complété";
                    break;
                case "FAILED": 
                    statutClass = "badge-danger";
                    statutIcon = "fas fa-times-circle";
                    statutText = "Échoué";
                    break;
                case "CANCELLED": 
                    statutClass = "badge-danger";
                    statutIcon = "fas fa-ban";
                    statutText = "Annulé";
                    break;
                case "REFUNDED": 
                    statutClass = "badge-info";
                    statutIcon = "fas fa-undo";
                    statutText = "Remboursé";
                    break;
            }
            
            String typeText = rs.getString("type_paiement");
            String typeIcon = "fas fa-money-bill-wave";
            switch(typeText) {
                case "SOUSCRIPTION": 
                    typeText = "Souscription"; 
                    typeIcon = "fas fa-file-signature";
                    break;
                case "COTISATION": 
                    typeText = "Cotisation"; 
                    typeIcon = "fas fa-hand-holding-usd";
                    break;
                case "AUTRE": 
                    typeText = "Autre"; 
                    break;
            }
            
            String methodeText = rs.getString("methode_paiement");
            String methodeIcon = "fas fa-wallet";
            switch(methodeText) {
                case "MTNMONEY": 
                    methodeText = "MTN Mobile Money"; 
                    methodeIcon = "fas fa-mobile-alt";
                    break;
                case "ORANGEMONEY": 
                    methodeText = "Orange Money"; 
                    methodeIcon = "fas fa-mobile-alt";
                    break;
                case "CARD": 
                    methodeText = "Carte Bancaire"; 
                    methodeIcon = "far fa-credit-card";
                    break;
                case "BANK_TRANSFER": 
                    methodeText = "Virement Bancaire"; 
                    methodeIcon = "fas fa-exchange-alt";
                    break;
                case "CASH": 
                    methodeText = "Espèces"; 
                    methodeIcon = "fas fa-money-bill-wave";
                    break;
            }
%>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
            <div class="transaction-container">
                <div class="transaction-header">
                    <h2><i class="fas fa-receipt"></i> Détails de la Transaction</h2>
                    <div class="transaction-id">#<%= rs.getInt("id") %></div>
                </div>
                
                <div class="transaction-body">
                    <div class="detail-section">
                        <h3><i class="fas fa-info-circle"></i> Informations Générales</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <div class="detail-icon"><i class="fas fa-hashtag"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Référence</div>
                                    <div class="detail-value"><%= rs.getString("reference") != null ? rs.getString("reference") : "N/A" %></div>
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-icon"><i class="<%= typeIcon %>"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Type</div>
                                    <div class="detail-value"><%= typeText %></div>
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-icon"><i class="<%= methodeIcon %>"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Méthode</div>
                                    <div class="detail-value"><%= methodeText %></div>
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-icon"><i class="<%= statutIcon %>"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Statut</div>
                                    <div class="detail-value"><span class="badge <%= statutClass %>"><%= statutText %></span></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="detail-section">
                        <h3><i class="fas fa-users"></i> Participants</h3>
                        <div class="detail-grid">
                            <div class="detail-item">
                                <div class="detail-icon"><i class="fas fa-user-friends"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Membre</div>
                                    <div class="detail-value"><%= rs.getString("prenom") + " " + rs.getString("nom") %></div>
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-icon"><i class="fas fa-handshake"></i></div>
                                <div class="detail-content">
                                    <div class="detail-label">Tontine</div>
                                    <div class="detail-value"><%= tontineName %></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="detail-section">
                        <h3><i class="fas fa-money-bill-wave"></i> Montant</h3>
                        <div class="amount-display">
                            <div class="amount-icon"><i class="fas fa-coins"></i></div>
                            <div class="amount-value"><%= String.format("%,.0f FCFA", rs.getDouble("montant")) %></div>
                        </div>
                    </div>
                    
                    <div class="detail-section">
                        <h3><i class="far fa-calendar-alt"></i> Date</h3>
                        <div class="date-display">
                            <div class="date-icon"><i class="far fa-clock"></i></div>
                            <div class="date-value"><%= formattedDate %></div>
                        </div>
                    </div>
                    
                    <% if(rs.getString("description") != null && !rs.getString("description").isEmpty()) { %>
                    <div class="detail-section">
                        <h3><i class="fas fa-align-left"></i> Description</h3>
                        <div class="description-box">
                            <%= rs.getString("description") %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <style>
                @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');
                
                .transaction-container {
                    font-family: 'Poppins', sans-serif;
                    max-width: 800px;
                    margin: 20px auto;
                    background: #ffffff;
                    border-radius: 12px;
                    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
                    overflow: hidden;
                }
                
                .transaction-header {
                    background: linear-gradient(135deg, #6e8efb, #a777e3);
                    color: white;
                    padding: 20px 25px;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }
                
                .transaction-header h2 {
                    margin: 0;
                    font-size: 1.5rem;
                    font-weight: 600;
                    display: flex;
                    align-items: center;
                }
                
                .transaction-header h2 i {
                    margin-right: 10px;
                }
                
                .transaction-id {
                    background: rgba(255, 255, 255, 0.2);
                    padding: 5px 12px;
                    border-radius: 20px;
                    font-weight: 500;
                    font-size: 0.9rem;
                }
                
                .transaction-body {
                    padding: 25px;
                }
                
                .detail-section {
                    margin-bottom: 25px;
                }
                
                .detail-section h3 {
                    color: #4a4a4a;
                    font-size: 1.1rem;
                    margin-bottom: 15px;
                    display: flex;
                    align-items: center;
                    border-bottom: 1px solid #f0f0f0;
                    padding-bottom: 8px;
                }
                
                .detail-section h3 i {
                    margin-right: 8px;
                    color: #6e8efb;
                }
                
                .detail-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                    gap: 15px;
                }
                
                .detail-item {
                    display: flex;
                    background: #f9f9f9;
                    border-radius: 8px;
                    padding: 12px 15px;
                    transition: all 0.3s ease;
                }
                
                .detail-item:hover {
                    background: #f0f0f0;
                    transform: translateY(-2px);
                }
                
                .detail-icon {
                    color: #a777e3;
                    font-size: 1.2rem;
                    margin-right: 15px;
                    display: flex;
                    align-items: center;
                }
                
                .detail-content {
                    flex: 1;
                }
                
                .detail-label {
                    color: #777;
                    font-size: 0.8rem;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                    margin-bottom: 3px;
                }
                
                .detail-value {
                    color: #333;
                    font-weight: 500;
                    font-size: 1rem;
                }
                
                .amount-display {
                    display: flex;
                    align-items: center;
                    background: linear-gradient(to right, #f6f7ff, #f0f2ff);
                    padding: 15px 20px;
                    border-radius: 8px;
                    margin-top: 10px;
                }
                
                .amount-icon {
                    color: #4caf50;
                    font-size: 1.8rem;
                    margin-right: 15px;
                }
                
                .amount-value {
                    font-size: 1.5rem;
                    font-weight: 600;
                    color: #2e7d32;
                }
                
                .date-display {
                    display: flex;
                    align-items: center;
                    background: #f9f9f9;
                    padding: 15px 20px;
                    border-radius: 8px;
                    margin-top: 10px;
                }
                
                .date-icon {
                    color: #6e8efb;
                    font-size: 1.5rem;
                    margin-right: 15px;
                }
                
                .date-value {
                    font-size: 1.1rem;
                    font-weight: 500;
                    color: #333;
                }
                
                .description-box {
                    background: #f9f9f9;
                    padding: 15px;
                    border-radius: 8px;
                    margin-top: 10px;
                    line-height: 1.5;
                    color: #555;
                }
                
                .badge {
                    padding: 5px 12px;
                    border-radius: 20px;
                    font-size: 0.75rem;
                    font-weight: 500;
                    text-transform: uppercase;
                    display: inline-flex;
                    align-items: center;
                }
                
                .badge i {
                    margin-right: 5px;
                    font-size: 0.8rem;
                }
                
                .badge-success {
                    background-color: #e8f5e9;
                    color: #2e7d32;
                }
                
                .badge-warning {
                    background-color: #fff8e1;
                    color: #ff8f00;
                }
                
                .badge-danger {
                    background-color: #ffebee;
                    color: #c62828;
                }
                
                .badge-info {
                    background-color: #e3f2fd;
                    color: #1565c0;
                }
            </style>
<%
        } else {
            out.println("<div class='alert alert-danger'><i class='fas fa-exclamation-triangle'></i> Transaction non trouvée</div>");
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<div class='alert alert-danger'><i class='fas fa-times-circle'></i> Erreur lors de la récupération des détails: " + e.getMessage() + "</div>");
    } finally {
        if(rs != null) rs.close();
        if(pstmt != null) pstmt.close();
        if(conn != null) conn.close();
    }
%>