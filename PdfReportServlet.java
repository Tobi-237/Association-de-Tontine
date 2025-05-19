package servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import utils.DBConnection;

@WebServlet("/generatePdfReport")
public class PdfReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Définir les polices et couleurs
    private static final Font TITLE_FONT = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.DARK_GRAY);
    private static final Font SUBTITLE_FONT = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.GRAY);
    private static final Font HEADER_FONT = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BaseColor.WHITE);
    private static final Font BODY_FONT = FontFactory.getFont(FontFactory.HELVETICA, 10);
    private static final BaseColor HEADER_BG_COLOR = new BaseColor(70, 130, 180); // SteelBlue
    private static final BaseColor EVEN_ROW_COLOR = new BaseColor(240, 240, 240);
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String search = request.getParameter("search");
        String status = request.getParameter("status");
        
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        
        try {
            // Construire la requête SQL (identique à votre version originale)
            String sql = "SELECT s.*, CONCAT(m.prenom, ' ', m.nom) AS membre FROM sanctions s " +
                       "JOIN members m ON s.member_id = m.id WHERE 1=1";
            
            if (search != null && !search.isEmpty()) {
                sql += " AND (CONCAT(m.prenom, ' ', m.nom) LIKE ? OR s.type_sanction LIKE ?";
            }
            
            if (status != null && !status.isEmpty()) {
                sql += " AND s.statut = ?";
            }
            
            sql += " ORDER BY s.date_sanction DESC";
            
            conn = DBConnection.getConnection();
            stmt = conn.prepareStatement(sql);
            
            int paramIndex = 1;
            if (search != null && !search.isEmpty()) {
                stmt.setString(paramIndex++, "%" + search + "%");
                stmt.setString(paramIndex++, "%" + search + "%");
            }
            
            if (status != null && !status.isEmpty()) {
                stmt.setString(paramIndex, status);
            }
            
            rs = stmt.executeQuery();
            
            // Configurer la réponse PDF
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"rapport_sanctions.pdf\"");
            
            // Créer le document PDF
            Document document = new Document();
            PdfWriter.getInstance(document, response.getOutputStream());
            document.open();
            
            // Ajouter un titre stylisé
            Paragraph title = new Paragraph("Rapport des sanctions", TITLE_FONT);
            title.setAlignment(Element.ALIGN_CENTER);
            title.setSpacingAfter(20f);
            document.add(title);
            
            SimpleDateFormat sdf = new SimpleDateFormat("EEEE d MMMM yyyy à HH:mm", Locale.FRANCE);
            String dateStr = sdf.format(new Date());

            Paragraph subtitle = new Paragraph("Généré le " + dateStr, SUBTITLE_FONT);
            subtitle.setAlignment(Element.ALIGN_CENTER);
            subtitle.setSpacingAfter(20f);
            document.add(subtitle);
            
            // Créer un tableau pour les données
            PdfPTable table = new PdfPTable(7); // 7 colonnes
            table.setWidthPercentage(100);
            table.setSpacingBefore(10f);
            table.setSpacingAfter(10f);
            
            // Définir les largeurs des colonnes (en pourcentage)
            float[] columnWidths = {20f, 15f, 10f, 12f, 12f, 10f, 21f};
            table.setWidths(columnWidths);
            
            // En-têtes du tableau avec style
            String[] headers = {"Membre", "Type", "Montant", "Date sanction", "Date fin", "Statut", "Motif"};
            for (String header : headers) {
                PdfPCell cell = new PdfPCell(new Phrase(header, HEADER_FONT));
                cell.setBackgroundColor(HEADER_BG_COLOR);
                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
                cell.setPadding(5f);
                cell.setBorderWidth(1.2f);
                table.addCell(cell);
            }
            
            // Remplir le tableau avec les données
            SimpleDateFormat sdf1 = new SimpleDateFormat("dd/MM/yyyy");
            NumberFormat nf = NumberFormat.getNumberInstance(Locale.FRENCH);
            
            int rowCount = 0;
            while (rs.next()) {
                rowCount++;
                
                // Alterner la couleur de fond des lignes
                BaseColor rowColor = (rowCount % 2 == 0) ? EVEN_ROW_COLOR : BaseColor.WHITE;
                
                // Membre
                addStyledCell(table, rs.getString("membre"), rowColor);
                
                // Type sanction
                addStyledCell(table, rs.getString("type_sanction"), rowColor);
                
                // Montant
                addStyledCell(table, nf.format(rs.getDouble("montant")) + " FCFA", rowColor);
                
                // Date sanction
                addStyledCell(table, sdf.format(rs.getDate("date_sanction")), rowColor);
                
                // Date fin
                String dateFin = rs.getDate("date_fin") != null ? sdf.format(rs.getDate("date_fin")) : "N/A";
                addStyledCell(table, dateFin, rowColor);
                
                // Statut - avec couleur selon le statut
                String statut = rs.getString("statut");
                PdfPCell statutCell = new PdfPCell(new Phrase(statut, BODY_FONT));
                statutCell.setBackgroundColor(rowColor);
                statutCell.setPadding(5f);
                statutCell.setHorizontalAlignment(Element.ALIGN_CENTER);
                
                // Ajouter une couleur en fonction du statut
                if ("Actif".equalsIgnoreCase(statut)) {
                    statutCell.setBackgroundColor(new BaseColor(255, 165, 0)); // Orange
                } else if ("Terminé".equalsIgnoreCase(statut)) {
                    statutCell.setBackgroundColor(new BaseColor(144, 238, 144)); // LightGreen
                } else if ("Annulé".equalsIgnoreCase(statut)) {
                    statutCell.setBackgroundColor(new BaseColor(255, 99, 71)); // Tomato
                }
                
                table.addCell(statutCell);
                
                // Motif
                addStyledCell(table, rs.getString("Motif"), rowColor);
            }
            
            document.add(table);
            
            // Ajouter un pied de page
            Paragraph footer = new Paragraph("Nombre total de sanctions: " + rowCount, 
                FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 10, BaseColor.GRAY));
            footer.setAlignment(Element.ALIGN_RIGHT);
            footer.setSpacingBefore(20f);
            document.add(footer);
            
            document.close();
            
        } catch (SQLException | DocumentException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                "Erreur lors de la génération du PDF");
        } finally {
            // Fermer les ressources
            try { if (rs != null) rs.close(); } catch (SQLException e) { /* ignored */ }
            try { if (stmt != null) stmt.close(); } catch (SQLException e) { /* ignored */ }
            try { if (conn != null) conn.close(); } catch (SQLException e) { /* ignored */ }
        }
    }
    
    // Méthode utilitaire pour ajouter une cellule avec style
    private void addStyledCell(PdfPTable table, String content, BaseColor bgColor) {
        PdfPCell cell = new PdfPCell(new Phrase(content, BODY_FONT));
        cell.setBackgroundColor(bgColor);
        cell.setPadding(5f);
        cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        cell.setBorderWidth(0.5f);
        table.addCell(cell);
    }
}