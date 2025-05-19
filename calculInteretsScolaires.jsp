<%@page import="java.math.BigDecimal"%>
<%@page import="java.util.Date"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<%@page import="org.json.JSONObject"%>
<%@page import="utils.DBConnection"%>
<%@page contentType="application/json" pageEncoding="UTF-8"%>

<%
    response.setContentType("application/json");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String currentYear = new SimpleDateFormat("yyyy").format(new Date());
    
    JSONObject result = new JSONObject();
    
    try (Connection conn = DBConnection.getConnection()) {
        // Vérifier si le calcul a déjà été fait pour cette année
        String checkSql = "SELECT COUNT(*) AS count FROM interets_scolaires WHERE annee = ?";
        try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
            checkPs.setString(1, currentYear);
            ResultSet rs = checkPs.executeQuery();
            if (rs.next() && rs.getInt("count") > 0) {
                result.put("success", false);
                result.put("message", "Les intérêts pour l'année " + currentYear + " ont déjà été calculés.");
                out.print(result.toString());
                return;
            }
        }
        
        // Désactiver l'autocommit pour gérer la transaction manuellement
        conn.setAutoCommit(false);
        
        try {
            // 1. Récupérer le solde de chaque membre dans la caisse scolaire
            String sql = "SELECT m.member_id, m.nom, m.prenom, COALESCE(SUM(v.montant), 0) AS solde " +
                         "FROM members m " +
                         "LEFT JOIN versements v ON m.member_id = v.member_id " +
                         "WHERE v.caisse_id = (SELECT id FROM caisses WHERE type_caisse = 'SCOLAIRE') " +
                         "AND v.statut = 'VALIDATED' " +
                         "GROUP BY m.member_id, m.nom, m.prenom " +
                         "HAVING COALESCE(SUM(v.montant), 0) > 0";
            
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ResultSet rs = ps.executeQuery();
                
                // 2. Pour chaque membre, calculer les intérêts (5% par exemple)
                BigDecimal tauxInteret = new BigDecimal("5.00"); // 5%
                int count = 0;
                
                String insertSql = "INSERT INTO interets_scolaires (member_id, annee, montant_initial, taux_interet, " +
                                  "montant_interet, date_calcul, statut) VALUES (?, ?, ?, ?, ?, ?, ?)";
                
                try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                    while (rs.next()) {
                        BigDecimal solde = rs.getBigDecimal("solde");
                        BigDecimal interets = solde.multiply(tauxInteret).divide(new BigDecimal("100"));
                        
                        insertPs.setInt(1, rs.getInt("member_id"));
                        insertPs.setString(2, currentYear);
                        insertPs.setBigDecimal(3, solde);
                        insertPs.setBigDecimal(4, tauxInteret);
                        insertPs.setBigDecimal(5, interets);
                        insertPs.setString(6, sdf.format(new Date()));
                        insertPs.setString(7, "PENDING"); // Statut initial
                        
                        insertPs.addBatch();
                        count++;
                    }
                    
                    // Exécuter le batch insert
                    insertPs.executeBatch();
                }
                
                // Valider la transaction
                conn.commit();
                
                result.put("success", true);
                result.put("message", "Calcul des intérêts terminé pour " + count + " membres.");
            }
        } catch (SQLException e) {
            // En cas d'erreur, annuler la transaction
            conn.rollback();
            result.put("success", false);
            result.put("message", "Erreur lors du calcul des intérêts: " + e.getMessage());
        } finally {
            conn.setAutoCommit(true);
        }
    } catch (SQLException e) {
        result.put("success", false);
        result.put("message", "Erreur de connexion à la base de données: " + e.getMessage());
    }
    
    out.print(result.toString());
%>