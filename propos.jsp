<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="utils.DBConnection" %>


<%
// Initialisation des variables
String tableName = "members";
String tableName1 = "tontines";
String paymentsTable = "paiements";
String tontineAdherentsTable = "tontine_adherents1";
int activeMembers = 0;
int activeTontines = 0;
int totalContributions = 0;
int totalSubscribers = 0;

// Récupération des données pour les statistiques
try {
    Connection conn = DBConnection.getConnection();
    
    // Nombre total de membres
    String sql = "SELECT COUNT(*) AS active_members FROM " + tableName;
    PreparedStatement stmt = conn.prepareStatement(sql);
    ResultSet rs = stmt.executeQuery();
    if (rs.next()) activeMembers = rs.getInt("active_members");
    rs.close();
    stmt.close();
    
    // Nombre total de tontines
    sql = "SELECT COUNT(*) AS active_tontines FROM " + tableName1;
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) activeTontines = rs.getInt("active_tontines");
    rs.close();
    stmt.close();
    
    // Total des cotisations
    sql = "SELECT SUM(montant) AS total_cotisations FROM " + paymentsTable + 
          " WHERE type_paiement = 'COTISATION' AND statut = 'COMPLETED'";
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) totalContributions = rs.getInt("total_cotisations");
    rs.close();
    stmt.close();
    
    // Nombre total de souscripteurs
    sql = "SELECT COUNT(DISTINCT member_id) AS total_souscripteurs FROM " + tontineAdherentsTable;
    stmt = conn.prepareStatement(sql);
    rs = stmt.executeQuery();
    if (rs.next()) totalSubscribers = rs.getInt("total_souscripteurs");
    rs.close();
    stmt.close();
    
    conn.close();
} catch (SQLException e) {
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Espace Utilisateur</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Base Styles */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5faf5;
            color: #333;
            margin: 0;
            padding: 0;
            transition: all 0.3s ease;
        }

        /* Main Content */
        .content {
            margin-left: 280px;
            padding: 30px;
            transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.1);
            min-height: 100vh;
        }

        h2 {
            margin-left: 280px;
            color: #2e7d32;
            font-size: 2.5rem;
            font-weight: 600;
            position: relative;
            display: inline-block;
            animation: fadeInDown 1s ease;
        }

        h2::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 60%;
            height: 4px;
            background: linear-gradient(90deg, #2e7d32, #81c784);
            border-radius: 2px;
        }

        /* Welcome Card */
        .welcome-card {
            background: linear-gradient(135deg, #ffffff 0%, #f1f8e9 100%);
            border-radius: 15px;
            padding: 30px;
            margin: 40px auto;
            max-width: 800px;
            box-shadow: 0 10px 30px rgba(46, 125, 50, 0.1);
            border-left: 5px solid #2e7d32;
            animation: slideInUp 0.8s ease;
            transition: transform 0.3s ease;
        }

        .welcome-card:hover {
            transform: translateY(-5px);
        }

        .welcome-card h3 {
            color: #2e7d32;
            font-size: 1.8rem;
            margin-top: 0;
            display: flex;
            align-items: center;
        }

        .welcome-card h3 i {
            margin-right: 15px;
            color: #388e3c;
        }

        .welcome-card p {
            font-size: 1.1rem;
            line-height: 1.6;
            color: #555;
        }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 25px;
            margin: 40px 0;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 5px 15px rgba(46, 125, 50, 0.1);
            transition: all 0.3s ease;
            text-align: center;
            border-top: 4px solid #81c784;
        }

        .stat-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(46, 125, 50, 0.2);
        }

        .stat-card i {
            font-size: 2.5rem;
            color: #2e7d32;
            margin-bottom: 15px;
            transition: transform 0.5s ease;
        }

        .stat-card:hover i {
            transform: rotate(360deg);
        }

        .stat-card h4 {
            color: #2e7d32;
            margin: 10px 0;
            font-size: 1.3rem;
        }

        .stat-card p {
            color: #666;
            font-size: 1.1rem;
        }

        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: #388e3c;
            margin: 10px 0;
        }

        /* Button Styles */
        .elegant-btn {
            background: linear-gradient(135deg, #2e7d32 0%, #388e3c 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            font-size: 1rem;
            border-radius: 30px;
            cursor: pointer;
            margin: 20px 0;
            margin-left: 280px;
            box-shadow: 0 4px 15px rgba(46, 125, 50, 0.3);
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            position: relative;
            overflow: hidden;
        }

        .elegant-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(46, 125, 50, 0.4);
        }

        .elegant-btn:active {
            transform: translateY(1px);
        }

        .elegant-btn::after {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: rgba(255, 255, 255, 0.1);
            transform: rotate(45deg);
            transition: all 0.3s ease;
            pointer-events: none;
        }

        .elegant-btn:hover::after {
            left: 100%;
        }

        /* Modal Styles */
        .modal {
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
            display: none;
            animation: fadeIn 0.3s ease;
        }

        .modal-content {
            background: linear-gradient(135deg, #ffffff 0%, #f1f8e9 100%);
            margin: 5% auto;
            padding: 30px;
            border-radius: 15px;
            width: 80%;
            max-width: 800px;
            box-shadow: 0 15px 40px rgba(0,0,0,0.2);
            position: relative;
            animation: slideInDown 0.5s ease;
        }

        .close-btn {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            transition: color 0.3s ease;
        }

        .close-btn:hover {
            color: #2e7d32;
            transform: rotate(90deg);
        }

        .modal h2 {
            color: #2e7d32;
            margin-left: 0;
            text-align: center;
            font-size: 2rem;
        }

        .modal h2 i {
            margin-right: 10px;
        }

        .modal h3 {
            color: #388e3c;
            margin-top: 25px;
            font-size: 1.5rem;
            display: flex;
            align-items: center;
        }

        .modal h3 i {
            margin-right: 10px;
            font-size: 1.3rem;
        }

        .modal p {
            line-height: 1.7;
            color: #555;
        }

        .modal ul {
            padding-left: 20px;
        }

        .modal li {
            margin-bottom: 10px;
            line-height: 1.6;
            position: relative;
            padding-left: 30px;
        }

        .modal li i {
            position: absolute;
            left: 0;
            top: 3px;
            color: #388e3c;
        }

        /* Decorative Elements */
        .leaf-decoration {
            position: absolute;
            opacity: 0.1;
            z-index: -1;
        }

        .leaf-1 {
            top: 10%;
            right: 5%;
            font-size: 10rem;
            color: #2e7d32;
            transform: rotate(30deg);
        }

        .leaf-2 {
            bottom: 10%;
            left: 5%;
            font-size: 8rem;
            color: #388e3c;
            transform: rotate(-20deg);
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes fadeInDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes slideInDown {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        @keyframes floating {
            0% { transform: translateY(0px); }
            50% { transform: translateY(-15px); }
            100% { transform: translateY(0px); }
        }

        /* Floating Elements */
        .floating {
            animation: floating 3s ease-in-out infinite;
        }

        /* Button Animation */
        .elegant-btn {
            animation: pulse 2s infinite 1s;
        }

        /* Responsive Design */
        @media screen and (max-width: 768px) {
            .content {
                margin-left: 0;
                padding: 20px;
            }
            
            h2 {
                margin-left: 0;
                text-align: center;
                font-size: 2rem;
            }
            
            h2::after {
                left: 50%;
                transform: translateX(-50%);
                width: 80%;
            }
            
            .elegant-btn {
                margin-left: 0;
                width: 100%;
                justify-content: center;
            }
            
            .modal-content {
                width: 90%;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <%@ include file="sidebars.jsp" %>

    <!-- Decorative elements -->
    <i class="fas fa-leaf leaf-decoration leaf-1 floating" style="animation-delay: 0.2s;"></i>
    <i class="fas fa-seedling leaf-decoration leaf-2 floating" style="animation-delay: 0.5s;"></i>

    <div class="content">
        <h2><i class="fas fa-user-circle"></i> Bienvenue dans l'espace Utilisateur</h2>
        
        <button id="showModalBtn" class="elegant-btn">
            <i class="fas fa-info-circle"></i> Bon à savoir
        </button>
        
        <!-- Welcome Card -->
        <div class="welcome-card">
            <h3><i class="fas fa-handshake"></i> Bienvenue dans la communauté GO-FAR</h3>
            <p>Nous sommes ravis de vous accueillir dans votre espace personnel. Ici, vous pouvez gérer vos contributions, suivre vos prêts et interagir avec notre communauté solidaire. Profitez de tous les avantages que GO-FAR offre à ses membres engagés.</p>
        </div>
        
        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <i class="fas fa-piggy-bank"></i>
                <div class="stat-value"><%= activeTontines %></div>
                <h4>Tontines active</h4>
                <p>le totale des tontine</p>
            </div>
            
            <div class="stat-card">
                <i class="fas fa-hand-holding-usd"></i>
                <div class="stat-value"><%=totalContributions %>FCFA</div>
                <h4>Total Cotisations</h4>
                <p>Montant que vous avez cotiser</p>
            </div>
            
            <div class="stat-card">
                <i class="fas fa-users"></i>
                <div class="stat-value"><%= totalSubscribers %></div>
                <h4>Nombre total de souscripteurs</h4>
                <p>Dans votre groupe de tontine</p>
            </div>
            
            <div class="stat-card">
                <i class="fas fa-calendar-check"></i>
                <div class="stat-value"><%= activeMembers %></div>
                <h4>Membres Actifs</h4>
                <p>Membres actif de l'association</p>
            </div>
        </div>
    </div>

    <!-- About Modal -->
    <div id="aboutModal" class="modal">
        <div class="modal-content">
            <span class="close-btn">&times;</span>
            <h2><i class="fas fa-info-circle"></i> À propos de GO-FAR</h2>
            <p><strong>GO-FAR</strong> est une tontine innovante qui vise à rassembler des individus autour d'un objectif commun de solidarité financière. En permettant à ses membres de contribuer régulièrement à un fonds commun, GO-FAR offre des opportunités d'épargne et de prêts à des conditions avantageuses.</p>
            <p>Ce système favorise non seulement l'entraide entre les membres, mais aussi la création d'un réseau social solide. Grâce à une gestion transparente et des outils numériques modernes, GO-FAR s'engage à maximiser les bénéfices pour ses participants tout en promouvant une culture d'épargne responsable.</p>

            <h3><i class="fas fa-star"></i> Caractéristiques de GO-FAR</h3>
            <ul>
                <li><i class="fas fa-check-circle"></i> <strong>Contributions régulières :</strong> Les membres s'engagent à verser des montants fixes à intervalles réguliers, ce qui permet de constituer un capital commun.</li>
                <li><i class="fas fa-check-circle"></i> <strong>Prêts accessibles :</strong> Les fonds accumulés peuvent être utilisés pour accorder des prêts à des membres dans le besoin, à des taux d'intérêt réduits.</li>
                <li><i class="fas fa-check-circle"></i> <strong>Gestion transparente :</strong> GO-FAR utilise des outils numériques pour assurer une gestion claire et accessible des contributions et des prêts.</li>
                <li><i class="fas fa-check-circle"></i> <strong>Communauté solidaire :</strong> En rejoignant GO-FAR, les membres intègrent une communauté qui valorise l'entraide et le soutien mutuel.</li>
                <li><i class="fas fa-check-circle"></i> <strong>Éducation financière :</strong> GO-FAR propose également des ateliers et des ressources pour aider ses membres à mieux gérer leurs finances personnelles.</li>
            </ul>

            <h2><i class="fas fa-globe"></i> About GO-FAR</h2>
            <p><strong>GO-FAR</strong> is an innovative tontine designed to bring individuals together around a common goal of financial solidarity. By allowing its members to contribute regularly to a communal fund, GO-FAR provides opportunities for savings and loans under favorable conditions.</p>
            <p>This system not only encourages mutual support among members but also fosters a strong social network. With transparent management and modern digital tools, GO-FAR is committed to maximizing benefits for its participants while promoting a culture of responsible saving.</p>

            <h3><i class="fas fa-gem"></i> Features of GO-FAR</h3>
            <ul>
                <li><i class="fas fa-check"></i> <strong>Regular contributions:</strong> Members commit to depositing fixed amounts at regular intervals, allowing for the accumulation of a communal capital.</li>
                <li><i class="fas fa-check"></i> <strong>Accessible loans:</strong> The accumulated funds can be used to provide loans to members in need, at reduced interest rates.</li>
                <li><i class="fas fa-check"></i> <strong>Transparent management:</strong> GO-FAR employs digital tools to ensure clear and accessible management of contributions and loans.</li>
                <li><i class="fas fa-check"></i> <strong>Supportive community:</strong> By joining GO-FAR, members become part of a community that values mutual assistance and support.</li>
                <li><i class="fas fa-check"></i> <strong>Financial education:</strong> GO-FAR also offers workshops and resources to help its members better manage their personal finances.</li>
            </ul>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Modal functionality
            const showModalBtn = document.getElementById("showModalBtn");
            const modal = document.getElementById("aboutModal");
            const closeModal = document.querySelector(".close-btn");

            if (showModalBtn) {
                showModalBtn.addEventListener("click", () => {
                    modal.style.display = "block";
                    document.body.style.overflow = "hidden";
                });
            }

            if (closeModal) {
                closeModal.addEventListener("click", () => {
                    modal.style.display = "none";
                    document.body.style.overflow = "auto";
                });
            }

            window.addEventListener("click", (event) => {
                if (event.target === modal) {
                    modal.style.display = "none";
                    document.body.style.overflow = "auto";
                }
            });

            // Add animation to stat cards on scroll
            const statCards = document.querySelectorAll('.stat-card');
            
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.animation = 'slideInUp 0.8s ease forwards';
                        observer.unobserve(entry.target);
                    }
                });
            }, { threshold: 0.1 });

            statCards.forEach(card => {
                observer.observe(card);
            });
        });
    </script>
</body>
</html>