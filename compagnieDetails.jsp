<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
// Vérifier si l'utilisateur est admin
String memberRole = (String) session.getAttribute("role");
if (!"ADMIN".equals(memberRole)) {
    response.sendRedirect("assurance.jsp");
    return;
}

// Récupérer l'ID de la compagnie
int compagnieId = Integer.parseInt(request.getParameter("id"));

// Formatage des dates
SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");

// Variables pour les données
String nom = "";
String contactPersonne = "";
String email = "";
String telephone = "";
String typeContrat = "";
java.util.Date dateDebut = null;
java.util.Date dateFin = null;
String conditions = "";

try (Connection conn = DBConnection.getConnection()) {
    // Récupérer les détails de la compagnie
    String sql = "SELECT * FROM compagnies_assurance WHERE id = ?";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, compagnieId);
        
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                nom = rs.getString("nom");
                contactPersonne = rs.getString("contact_personne");
                email = rs.getString("email");
                telephone = rs.getString("telephone");
                typeContrat = rs.getString("type_contrat");
                dateDebut = rs.getDate("date_debut");
                dateFin = rs.getDate("date_fin");
                conditions = rs.getString("conditions");
            } else {
                response.sendRedirect("assurance.jsp");
                return;
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
    <title>Détails Compagnie | Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
   <style>
    :root {
        --primary-color: #2ecc71;
        --primary-dark: #27ae60;
        --primary-light: #58d68d;
        --white: #ffffff;
        --light-bg: #f5f9f7;
        --dark-text: #2c3e50;
        --light-text: #7f8c8d;
        --card-shadow: 0 15px 30px rgba(46, 204, 113, 0.15);
    }
    
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Poppins', sans-serif;
    }
    
    body {
        background: linear-gradient(135deg, var(--light-bg) 0%, #e4f5ea 100%);
        min-height: 100vh;
        color: var(--dark-text);
        overflow-x: hidden;
    }
    
    .content {
        padding: 40px;
        animation: fadeIn 0.8s ease-out;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; transform: translateY(20px); }
        to { opacity: 1; transform: translateY(0); }
    }
    
    .back-link {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        color: var(--primary-dark);
        margin-bottom: 25px;
        text-decoration: none;
        font-weight: 500;
        transition: all 0.3s;
    }
    
    .back-link:hover {
        color: var(--primary-color);
        transform: translateX(-5px);
    }
    
    .back-link i {
        transition: all 0.3s;
    }
    
    .header {
        margin-bottom: 40px;
    }
    
    .header h1 {
        font-size: 2.5rem;
        color: var(--dark-text);
        position: relative;
        display: inline-block;
    }
    
    .header h1:after {
        content: "";
        position: absolute;
        bottom: -10px;
        left: 0;
        width: 80px;
        height: 4px;
        background: linear-gradient(to right, var(--primary-color), var(--primary-light));
        border-radius: 3px;
    }
    
    .header h1 i {
        color: var(--primary-color);
        margin-right: 15px;
    }
    
    .card {
        background: var(--white);
        border-radius: 16px;
        box-shadow: var(--card-shadow);
        padding: 30px;
        margin-bottom: 30px;
        position: relative;
        overflow: hidden;
        transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.1);
    }
    
    .card:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 40px rgba(46, 204, 113, 0.2);
    }
    
    .card:before {
        content: "";
        position: absolute;
        top: 0;
        left: 0;
        width: 5px;
        height: 100%;
        background: linear-gradient(to bottom, var(--primary-color), var(--primary-light));
    }
    
    .card-title {
        font-size: 1.5rem;
        margin-bottom: 25px;
        color: var(--dark-text);
        display: flex;
        align-items: center;
        gap: 15px;
    }
    
    .card-title i {
        color: var(--primary-color);
        font-size: 1.8rem;
    }
    
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 25px;
    }
    
    .info-item {
        padding: 20px;
        background: rgba(255, 255, 255, 0.7);
        border-radius: 12px;
        box-shadow: 0 5px 15px rgba(0, 0, 0, 0.03);
        transition: all 0.3s;
        border: 1px solid rgba(46, 204, 113, 0.1);
    }
    
    .info-item:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(46, 204, 113, 0.1);
        border-color: rgba(46, 204, 113, 0.2);
    }
    
    .info-label {
        font-size: 0.9rem;
        color: var(--light-text);
        margin-bottom: 8px;
        font-weight: 500;
    }
    
    .info-value {
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--dark-text);
    }
    
    .btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        padding: 12px 24px;
        border-radius: 50px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.4s;
        border: none;
        font-size: 1rem;
        text-decoration: none;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
    }
    
    .btn i {
        margin-right: 10px;
        transition: all 0.3s;
    }
    
    .btn-danger {
        background: linear-gradient(135deg, #e74c3c, #c0392b);
        color: white;
    }
    
    .btn-danger:hover {
        transform: translateY(-3px);
        box-shadow: 0 8px 25px rgba(231, 76, 60, 0.3);
    }
    
    .btn-danger:active {
        transform: translateY(1px);
    }
    
    /* Animation pour les éléments d'information */
    @keyframes slideIn {
        from { opacity: 0; transform: translateX(-20px); }
        to { opacity: 1; transform: translateX(0); }
    }
    
    .info-item {
        animation: slideIn 0.6s ease-out forwards;
        opacity: 0;
    }
    
    .info-item:nth-child(1) { animation-delay: 0.1s; }
    .info-item:nth-child(2) { animation-delay: 0.2s; }
    .info-item:nth-child(3) { animation-delay: 0.3s; }
    .info-item:nth-child(4) { animation-delay: 0.4s; }
    .info-item:nth-child(5) { animation-delay: 0.5s; }
    .info-item:nth-child(6) { animation-delay: 0.6s; }
    .info-item:nth-child(7) { animation-delay: 0.7s; }
    
    /* Effet de vague décoratif */
    .card:after {
        content: "";
        position: absolute;
        bottom: -50px;
        right: -50px;
        width: 150px;
        height: 150px;
        background: radial-gradient(circle, rgba(46, 204, 113, 0.1) 0%, rgba(46, 204, 113, 0) 70%);
        border-radius: 50%;
        z-index: 0;
    }
</style>
</head>
<body>
    <%@ include file="sidebar.jsp" %>

    <div class="content">
        <a href="assurance.jsp?tab=compagnies" class="back-link">
            <i class="fas fa-arrow-left"></i> Retour à la liste
        </a>
        
        <div class="header">
            <h1>
                <i class="fas fa-building"></i> Détails de la Compagnie
            </h1>
        </div>
        
        <div class="card">
            <h2 class="card-title">Informations de Base</h2>
            
            <div class="info-grid">
                <div class="info-item">
                    <div class="info-label">Nom</div>
                    <div class="info-value"><%= nom %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Personne de Contact</div>
                    <div class="info-value"><%= contactPersonne %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Email</div>
                    <div class="info-value"><%= email %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Téléphone</div>
                    <div class="info-value"><%= telephone %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Type de Contrat</div>
                    <div class="info-value"><%= typeContrat %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Date Début Partenariat</div>
                    <div class="info-value"><%= sdf.format(dateDebut) %></div>
                </div>
                
                <div class="info-item">
                    <div class="info-label">Date Fin Partenariat</div>
                    <div class="info-value"><%= dateFin != null ? sdf.format(dateFin) : "Indéterminée" %></div>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2 class="card-title">Conditions Spéciales</h2>
            <p><%= conditions != null && !conditions.isEmpty() ? conditions : "Aucune condition spéciale enregistrée" %></p>
        </div>
        
        <div class="card">
            <h2 class="card-title">Actions</h2>
            <button class="btn btn-danger" onclick="deleteCompagnie(<%= compagnieId %>)">
                <i class="fas fa-trash"></i> Supprimer cette compagnie
            </button>
        </div>
    </div>
    
    <script>
        function deleteCompagnie(id) {
            if (confirm('Êtes-vous sûr de vouloir supprimer cette compagnie d\'assurance ?')) {
                window.location.href = 'deleteCompagnie.jsp?id=' + id;
            }
        }
    </script>
</body>
</html>