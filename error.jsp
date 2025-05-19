<%@page import="org.apache.tomcat.util.json.JSONParser"%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.net.URL, java.util.Scanner, java.util.ArrayList, java.util.List" %>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accès Refusé</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* Base Styles */
        :root {
            --primary-color: #2e7d32;
            --primary-light: #4caf50;
            --primary-dark: #1b5e20;
            --accent-color: #8bc34a;
            --text-dark: #263238;
            --text-light: #eceff1;
            --background: #f5f5f5;
            --card-bg: #ffffff;
            --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Montserrat', 'Segoe UI', Arial, sans-serif;
            background: var(--background);
            color: var(--text-dark);
            line-height: 1.6;
            margin: 0;
            padding: 0;
            background-image: linear-gradient(to bottom, rgba(46, 125, 50, 0.05) 0%, rgba(255, 255, 255, 1) 100%);
            min-height: 100vh;
        }

        /* Container */
        .container {
            max-width: 1200px;
            margin: 40px auto;
            background: var(--card-bg);
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
            transition: var(--transition);
        }

        .container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 8px;
            height: 100%;
            background: linear-gradient(to bottom, var(--primary-color), var(--accent-color));
        }

        /* Header */
        h1 {
            color: var(--primary-dark);
            font-size: 2.5rem;
            margin-bottom: 20px;
            position: relative;
            padding-left: 20px;
        }

        h1::before {
            content: '\f06a';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            position: absolute;
            left: -10px;
            color: var(--primary-light);
        }

        .message {
            background: #e8f5e9;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 4px solid var(--primary-color);
            font-size: 1.1rem;
            animation: fadeIn 0.8s ease-out;
        }

        /* Search Bar */
        .search-container {
            position: relative;
            margin-bottom: 30px;
        }

        .search-bar {
            width: 100%;
            padding: 15px 20px 15px 50px;
            border: 2px solid #e0e0e0;
            border-radius: 50px;
            font-size: 1rem;
            transition: var(--transition);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
        }

        .search-bar:focus {
            outline: none;
            border-color: var(--primary-light);
            box-shadow: 0 4px 15px rgba(46, 125, 50, 0.2);
        }

        .search-icon {
            position: absolute;
            left: 20px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--primary-light);
            font-size: 1.2rem;
        }

        /* News Grid */
        .news-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }

        .news-card {
            background: var(--card-bg);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            transition: var(--transition);
            position: relative;
            transform: translateY(0);
            animation: cardEntrance 0.6s ease-out forwards;
            opacity: 0;
        }

        .news-card:nth-child(1) { animation-delay: 0.1s; }
        .news-card:nth-child(2) { animation-delay: 0.2s; }
        .news-card:nth-child(3) { animation-delay: 0.3s; }
        .news-card:nth-child(4) { animation-delay: 0.4s; }
        .news-card:nth-child(5) { animation-delay: 0.5s; }
        .news-card:nth-child(6) { animation-delay: 0.6s; }

        .news-card:hover {
            transform: translateY(-10px) scale(1.02);
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
        }

        .news-card::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(to right, var(--primary-color), var(--accent-color));
            transition: var(--transition);
        }

        .news-card:hover::after {
            height: 6px;
        }

        .card-content {
            padding: 25px;
        }

        .news-title {
            color: var(--primary-dark);
            font-size: 1.3rem;
            margin-bottom: 15px;
            font-weight: 600;
            transition: var(--transition);
        }

        .news-card:hover .news-title {
            color: var(--primary-light);
        }

        .news-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 20px;
            font-size: 0.9rem;
            color: #607d8b;
        }

        .news-meta div {
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .news-meta i {
            color: var(--primary-light);
            font-size: 0.9rem;
        }

        .read-more {
            display: inline-block;
            margin-top: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
            transition: var(--transition);
            position: relative;
        }

        .read-more::after {
            content: '\f061';
            font-family: 'Font Awesome 6 Free';
            font-weight: 900;
            margin-left: 8px;
            transition: var(--transition);
            opacity: 0;
            position: absolute;
            right: -20px;
        }

        .read-more:hover {
            color: var(--primary-dark);
        }

        .read-more:hover::after {
            opacity: 1;
            right: -25px;
        }

        /* Buttons */
        .button-container {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .action-button {
            padding: 12px 25px;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 10px;
            border: none;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .back-button {
            background: #f5f5f5;
            color: var(--text-dark);
            text-decoration: none;
        }

        .back-button:hover {
            background: #e0e0e0;
            transform: translateX(-5px);
        }

        .contact-button {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            color: white;
            position: relative;
            overflow: hidden;
        }

        .contact-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(46, 125, 50, 0.3);
        }

        .contact-button::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
            transition: 0.5s;
        }

        .contact-button:hover::before {
            left: 100%;
        }

        .contact-number {
            display: none;
            margin-left: 10px;
            font-weight: 400;
            animation: fadeIn 0.5s ease-out;
        }

        .show-number .contact-number {
            display: inline-block;
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        @keyframes cardEntrance {
            from {
                opacity: 0;
                transform: translateY(30px);
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

        /* Responsive */
        @media (max-width: 768px) {
            .container {
                padding: 25px;
                margin: 20px;
            }

            .news-grid {
                grid-template-columns: 1fr;
            }

            h1 {
                font-size: 2rem;
            }
        }

        /* Loading Animation */
        .loader {
            display: none;
            text-align: center;
            margin: 30px 0;
        }

        .loader i {
            font-size: 2rem;
            color: var(--primary-light);
            animation: pulse 1.5s infinite;
        }
    </style>
</head>
<body>

<div class="container">
    <h1><i class="fas fa-lock"></i> Accès Refusé</h1>
    <p class="message">
        <i class="fas fa-hourglass-half"></i> Votre compte est en attente de validation par l'administrateur.
    </p>

    <div class="search-container">
        <i class="fas fa-search search-icon"></i>
        <input type="text" class="search-bar" placeholder="Rechercher des articles..." id="searchInput">
    </div>
    
    <div class="loader" id="loader">
        <i class="fas fa-spinner fa-spin"></i>
        <p>Chargement des actualités...</p>
    </div>
    
    <div class="news-grid">
    <%
        String[] feeds = {
            "https://news.google.com/rss/search?q=aide+humanitaire&hl=fr&gl=FR&ceid=FR:fr",
            "https://news.google.com/rss/search?q=orphelinat&hl=fr&gl=FR&ceid=FR:fr",
            "https://news.google.com/rss/search?q=santé+maladies&hl=fr&gl=FR&ceid=FR:fr",
            "https://news.google.com/rss/search?q=deuil&hl=fr&gl=FR&ceid=FR:fr"
        };

        List<String> articles = new ArrayList<>();
        
        try {
            for (String feed : feeds) {
                URL url = new URL(feed);
                Scanner scanner = new Scanner(url.openStream(), "UTF-8");
                StringBuilder content = new StringBuilder();
                
                while (scanner.hasNextLine()) {
                    content.append(scanner.nextLine());
                }
                scanner.close();
                
                // Parsing simplifié
                String[] items = content.toString().split("<item>");
                for (int i = 1; i < Math.min(items.length, 5); i++) { // 5 articles par flux
                    String item = items[i];
                    String title = extractValue(item, "title");
                    String link = extractValue(item, "link");
                    String pubDate = extractValue(item, "pubDate");
                    String source = extractValue(item, "source");
    %>
        <div class="news-card">
            <div class="card-content">
                <h3 class="news-title"><i class="fas fa-newspaper"></i> <%= title %></h3>
                <div class="news-meta">
                    <% if (source != null) { %>
                        <div><i class="fas fa-building"></i> <%= source %></div>
                    <% } %>
                    <% if (pubDate != null) { %>
                        <div><i class="far fa-calendar-alt"></i> <%= pubDate.split(" ")[0] %></div>
                    <% } %>
                </div>
                <a href="<%= link %>" target="_blank" class="read-more">Lire l'article</a>
            </div>
        </div>
    <%
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
    %>
        <div class="message">
            <i class="fas fa-exclamation-triangle"></i> Erreur de chargement des actualités
        </div>
    <%
        }
    %>
    </div>
    
    <p class="message">
    <% 
    String errorMessage = (String) request.getAttribute("errorMessage");
    if (errorMessage != null) {
        out.println("<i class='fas fa-exclamation-circle'></i> " + errorMessage);
    } else {
        out.println("<i class='fas fa-info-circle'></i> Votre compte est en attente de validation par l'administrateur.");
    }
    %>
    </p>
    
    <!-- Buttons -->
    <div class="button-container">
        <a href="login.jsp" class="action-button back-button">
            <i class="fas fa-arrow-left"></i> Retour à la connexion
        </a>
        <button class="action-button contact-button" id="showContact">
            <i class="fas fa-phone"></i> Contacter le service
            <span class="contact-number" id="contactNumber">+237 695 050 801</span>
        </button>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        // Show loader temporarily (simulating content load)
        const loader = document.getElementById('loader');
        loader.style.display = 'block';
        
        setTimeout(() => {
            loader.style.display = 'none';
        }, 1500);
        
        // Contact button functionality
        document.getElementById('showContact').addEventListener('click', function() {
            const numberElement = document.getElementById('contactNumber');
            if (numberElement.style.display === 'inline-block') {
                numberElement.style.display = 'none';
                this.classList.remove('show-number');
            } else {
                numberElement.style.display = 'inline-block';
                this.classList.add('show-number');
            }
        });
        
        // Enhanced search functionality
        document.getElementById('searchInput').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase().trim();
            const cards = document.querySelectorAll('.news-card');
            
            if (searchTerm === '') {
                cards.forEach(card => {
                    card.style.display = 'block';
                    card.style.animation = 'cardEntrance 0.6s ease-out forwards';
                });
                return;
            }
            
            cards.forEach(card => {
                const text = card.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    card.style.display = 'block';
                    card.style.animation = 'cardEntrance 0.6s ease-out forwards';
                } else {
                    card.style.display = 'none';
                }
            });
        });
        
        // Add hover effect to cards
        const cards = document.querySelectorAll('.news-card');
        cards.forEach(card => {
            card.addEventListener('mouseenter', () => {
                card.style.transform = 'translateY(-10px) scale(1.02)';
            });
            card.addEventListener('mouseleave', () => {
                card.style.transform = 'translateY(0) scale(1)';
            });
        });
    });
</script>

<%!
    // Méthode helper pour l'extraction des valeurs
    private String extractValue(String item, String tag) {
        int start = item.indexOf("<" + tag + ">");
        if (start == -1) return null;
        start += tag.length() + 2;
        int end = item.indexOf("</" + tag + ">", start);
        return end > start ? item.substring(start, end) : null;
    }
%>

</body>
</html>