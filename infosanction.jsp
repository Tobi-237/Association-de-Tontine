<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notification de Sanction</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #2e7d32;
            --primary-light: #4caf50;
            --primary-dark: #1b5e20;
            --accent-color: #8bc34a;
            --text-dark: #263238;
            --text-light: #eceff1;
            --background: #f5f5f5;
            --card-bg: #ffffff;
            --error-color: #d32f2f;
            --warning-color: #ffa000;
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
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background-image: linear-gradient(135deg, rgba(46, 125, 50, 0.1) 0%, rgba(255, 255, 255, 1) 100%);
        }

        .notification-container {
            max-width: 800px;
            width: 90%;
            background: var(--card-bg);
            padding: 40px;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            position: relative;
            overflow: hidden;
            text-align: center;
            animation: fadeInUp 0.8s ease-out;
        }

        .notification-container::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 8px;
            height: 100%;
            background: linear-gradient(to bottom, var(--error-color), var(--warning-color));
        }

        h1 {
            color: var(--error-color);
            font-size: 2.5rem;
            margin-bottom: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 15px;
        }

        .notification-icon {
            font-size: 5rem;
            color: var(--error-color);
            margin: 20px 0;
            animation: pulse 1.5s infinite;
        }

        .sanction-details {
            background: #fff8e1;
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid var(--warning-color);
            margin: 25px 0;
            text-align: left;
        }

        .sanction-details h3 {
            color: var(--warning-color);
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .sanction-details p {
            margin-bottom: 10px;
            line-height: 1.7;
        }

        .action-buttons {
            margin-top: 30px;
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            display: inline-flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            color: white;
            border: none;
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(46, 125, 50, 0.3);
        }

        .btn-secondary {
            background: white;
            color: var(--primary-dark);
            border: 2px solid var(--primary-light);
        }

        .btn-secondary:hover {
            background: #f1f8e9;
            transform: translateY(-3px);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        @media (max-width: 768px) {
            .notification-container {
                padding: 25px;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .action-buttons {
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
    <div class="notification-container">
        <div class="notification-icon">
            <i class="fas fa-exclamation-circle"></i>
        </div>
        
        <h1><i class="fas fa-gavel"></i> Notification de Sanction</h1>
        
        <p>Cher membre, vous avez reçu une sanction en raison du non-respect des règles de notre communauté.</p>
        
        <div class="sanction-details">
            <h3><i class="fas fa-info-circle"></i> Détails de la sanction</h3>
            <p><strong>Type :</strong> <%= request.getParameter("sanctionType") != null ? request.getParameter("sanctionType") : "Non spécifié" %></p>
            <p><strong>Motif :</strong> <%= request.getParameter("details") != null ? request.getParameter("details") : "Non spécifié" %></p>
            <% if (request.getParameter("duration") != null && !request.getParameter("duration").isEmpty()) { %>
                <p><strong>Durée :</strong> <%= request.getParameter("duration") %></p>
            <% } %>
            <% if (request.getParameter("amount") != null && !request.getParameter("amount").isEmpty()) { %>
                <p><strong>Montant :</strong> <%= request.getParameter("amount") %> FCFA</p>
            <% } %>
            <p><strong>Date :</strong> <%= new java.util.Date().toLocaleString() %></p>
        </div>
        
        <p>Veuillez prendre les mesures nécessaires pour régulariser votre situation.</p>
        
        <div class="action-buttons">
            <a href="contact.jsp" class="btn btn-primary">
                <i class="fas fa-headset"></i> Contacter le support
            </a>
            <a href="reglement.jsp" class="btn btn-secondary">
                <i class="fas fa-file-alt"></i> Voir le règlement
            </a>
        </div>
    </div>
    
    <script>
        // Add animation to elements
        document.addEventListener('DOMContentLoaded', function() {
            const elements = document.querySelectorAll('.sanction-details, .action-buttons');
            elements.forEach((el, index) => {
                el.style.animation = `fadeInUp 0.6s ease-out ${index * 0.2 + 0.3}s forwards`;
                el.style.opacity = '0';
            });
        });
    </script>
</body>
</html>