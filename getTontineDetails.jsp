<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page session="true" %>

<%
    final BigDecimal SOUSCRIPTION_AMOUNT = new BigDecimal("10000");
    
    if (request.getParameter("tontine_id") != null) {
        int tontineId = Integer.parseInt(request.getParameter("tontine_id"));
        
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT t.*, u.nom as createur_nom, u.prenom as createur_prenom " +
                        "FROM tontines t " +
                        "JOIN users u ON t.member_id = u.id " +
                        "WHERE t.id = ?";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, tontineId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int partsMax = rs.getInt("nombre_parts_max");
%>
                        <h3><i class="fas fa-info-circle"></i> Détails de la tontine</h3>
                        
                        <div class="detail-row">
                            <div class="detail-label">Nom:</div>
                            <div class="detail-value"><%= rs.getString("nom") %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Description:</div>
                            <div class="detail-value"><%= rs.getString("description") != null ? rs.getString("description") : "Aucune description fournie." %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Montant mensuel:</div>
                            <div class="detail-value"><%= String.format("%,d", rs.getBigDecimal("montant_mensuel").intValue()) %> FCFA</div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Mode de règlement:</div>
                            <div class="detail-value"><%= rs.getString("mode_reglement") %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Période:</div>
                            <div class="detail-value"><%= rs.getDate("date_debut") %> au <%= rs.getDate("date_fin") %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Fréquence:</div>
                            <div class="detail-value"><%= rs.getString("frequence") %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Jour de cotisation:</div>
                            <div class="detail-value"><%= rs.getInt("jourCotisation") %></div>
                        </div>
                        
                        <div class="detail-row">
                            <div class="detail-label">Créateur:</div>
                            <div class="detail-value"><%= rs.getString("createur_prenom") %> <%= rs.getString("createur_nom") %></div>
                        </div>
                        
                        <div class="subscription-form">
                            <h4><i class="fas fa-user-plus"></i> Souscrire à cette tontine</h4>
                            <form method="post">
                                <input type="hidden" name="tontine_id" value="<%= tontineId %>">
                                
                                <div class="form-group">
                                    <label for="nombre_de_parts">Nombre de parts:</label>
                                    <select name="nombre_de_parts" id="nombre_de_parts" class="form-control" required>
                                        <% for (int i = 1; i <= partsMax; i++) { %>
                                            <option value="<%= i %>"><%= i %> part<%= i > 1 ? "s" : "" %> (<%= String.format("%,d", SOUSCRIPTION_AMOUNT.multiply(new BigDecimal(i)).intValue()) %> FCFA)</option>
                                        <% } %>
                                    </select>
                                </div>
                                
                                <button type="submit" name="souscrire" class="btn btn-success">
                                    <i class="fas fa-check"></i> Confirmer la souscription
                                </button>
                            </form>
                        </div>
<%
                    } else {
%>
                        <div class="empty-state">
                            <i class="fas fa-exclamation-triangle"></i>
                            <h4>Tontine non trouvée</h4>
                            <p>La tontine sélectionnée n'existe pas ou n'est plus disponible.</p>
                        </div>
<%
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
%>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> Erreur lors du chargement des détails de la tontine.
            </div>
<%
        }
    }
%>