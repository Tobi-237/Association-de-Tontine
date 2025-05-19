<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Formulaire de Connexion et d'Inscription - Go-Far</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2ecc71;
            --primary-dark: #27ae60;
            --light-color: #ecf0f1;
            --white: #ffffff;
            --shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            --transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            color: #333;
        }
        
        .container {
            position: relative;
            width: 100%;
            max-width: 1000px;
            min-height: 600px;
            background: var(--white);
            border-radius: 20px;
            box-shadow: var(--shadow);
            overflow: hidden;
            display: flex;
            z-index: 10;
        }
        
        .form-container {
            position: absolute;
            top: 0;
            height: 100%;
            transition: var(--transition);
            padding: 0 50px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            width: 50%;
            background: var(--white);
        }
        
        .sign-in-container {
            left: 0;
            width: 50%;
            z-index: 2;
        }
        
        .sign-up-container {
            left: 0;
            width: 50%;
            opacity: 0;
            z-index: 1;
        }
        
        .container.right-panel-active .sign-in-container {
            transform: translateX(100%);
        }
        
      .container.right-panel-active .sign-up-container {
    transform: translateX(90%) scale(0.80); /* Déplacement réduit et mise à l'échelle */
    opacity: 1;
    z-index: 5;
    animation: show 0.6s;
}

        
        @keyframes show {
            0%, 49.99% {
                opacity: 0;
                z-index: 1;
            }
            50%, 100% {
                opacity: 1;
                z-index: 5;
            }
        }
        
        .overlay-container {
            position: absolute;
            top: 0;
            left: 50%;
            width: 50%;
            height: 100%;
            overflow: hidden;
            transition: var(--transition);
            z-index: 100;
        }
        
        .container.right-panel-active .overlay-container {
            transform: translateX(-100%);
        }
        
        .overlay {
            background: linear-gradient(to right, var(--primary-color), var(--primary-dark));
            background-repeat: no-repeat;
            background-size: cover;
            background-position: 0 0;
            color: var(--white);
            position: relative;
            left: -100%;
            height: 100%;
            width: 200%;
            transform: translateX(0);
            transition: var(--transition);
        }
        
        .container.right-panel-active .overlay {
            transform: translateX(50%);
        }
        
        .overlay-panel {
            position: absolute;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 40px;
            text-align: center;
            top: 0;
            height: 100%;
            width: 50%;
            transform: translateX(0);
            transition: var(--transition);
        }
        
        .overlay-left {
            transform: translateX(-20%);
        }
        
        .container.right-panel-active .overlay-left {
            transform: translateX(0);
        }
        
        .overlay-right {
            right: 0;
            transform: translateX(0);
        }
        
        .container.right-panel-active .overlay-right {
            transform: translateX(20%);
        }
        
        h1 {
            font-weight: 700;
            margin-bottom: 20px;
            font-size: 2.2rem;
        }
        
        p {
            font-size: 0.9rem;
            margin-bottom: 30px;
            line-height: 1.5;
        }
        
        span {
            font-size: 0.8rem;
            margin-bottom: 20px;
            display: block;
            color: #777;
        }
        
        input {
            background-color: #f8f9fa;
            border: none;
            padding: 15px 20px;
            margin: 8px 0;
            width: 100%;
            border-radius: 50px;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            border: 1px solid #e9ecef;
        }
        
        input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(46, 204, 113, 0.2);
        }
        
        button {
            border-radius: 50px;
            border: 1px solid var(--primary-color);
            background: var(--primary-color);
            color: var(--white);
            font-size: 0.9rem;
            font-weight: 600;
            padding: 12px 45px;
            letter-spacing: 1px;
            text-transform: uppercase;
            transition: var(--transition);
            margin-top: 15px;
            cursor: pointer;
        }
        
        button:hover {
            background: var(--primary-dark);
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        button:active {
            transform: scale(0.95);
        }
        
        button.ghost {
            background: transparent;
            border-color: var(--white);
        }
        
        button.ghost:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        
        .social-container {
            margin: 20px 0;
        }
        
        .social-container a {
            border: 1px solid #dddddd;
            border-radius: 50%;
            display: inline-flex;
            justify-content: center;
            align-items: center;
            margin: 0 5px;
            height: 40px;
            width: 40px;
            color: #333;
            transition: var(--transition);
        }
        
        .social-container a:hover {
            background: var(--primary-color);
            color: var(--white);
            border-color: var(--primary-color);
            transform: translateY(-3px);
        }
        
        .forgot {
            color: #777;
            font-size: 0.8rem;
            text-decoration: none;
            transition: all 0.3s ease;
            align-self: flex-end;
            margin: 5px 0 15px;
        }
        
        .forgot:hover {
            color: var(--primary-color);
        }
        
        /* Password toggle */
        .password-container {
            position: relative;
            width: 100%;
        }
        
        .toggle-password {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: #777;
            transition: all 0.3s ease;
        }
        
        .toggle-password:hover {
            color: var(--primary-color);
        }
        
        .password-requirements {
            font-size: 0.7rem;
            color: #777;
            margin: 5px 0 15px;
            text-align: left;
            width: 100%;
            padding-left: 15px;
        }
        
        /* Messages */
        .error-message, .success-message {
            position: fixed;
            top: 30px;
            right: 30px;
            padding: 15px 25px;
            border-radius: 10px;
            z-index: 1000;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            display: flex;
            align-items: center;
            animation: slideIn 0.5s, fadeOut 1s 4s forwards;
            max-width: 350px;
        }
        
        .error-message {
            background-color: #fff0f0;
            color: #e74c3c;
            border-left: 5px solid #e74c3c;
        }
        
        .success-message {
            background-color: #f0fff4;
            color: var(--primary-dark);
            border-left: 5px solid var(--primary-dark);
        }
        
        .message-icon {
            margin-right: 15px;
            font-size: 1.2rem;
        }
        
        @keyframes slideIn {
            from {
                transform: translateX(100%);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        
        @keyframes fadeOut {
            from {
                opacity: 1;
            }
            to {
                opacity: 0;
            }
        }
        
        /* Floating animation */
        @keyframes float {
            0% {
                transform: translateY(0px);
            }
            50% {
                transform: translateY(-10px);
            }
            100% {
                transform: translateY(0px);
            }
        }
        
        .floating-icon {
            position: absolute;
            opacity: 0.1;
            z-index: 1;
            animation: float 6s ease-in-out infinite;
        }
        
        .icon-1 {
            top: 10%;
            left: 5%;
            font-size: 5rem;
            color: var(--primary-color);
            animation-delay: 0s;
        }
        
        .icon-2 {
            bottom: 15%;
            right: 5%;
            font-size: 4rem;
            color: var(--primary-dark);
            animation-delay: 1s;
        }
        
        .icon-3 {
            top: 40%;
            right: 15%;
            font-size: 3rem;
            color: var(--primary-color);
            animation-delay: 2s;
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .container {
                flex-direction: column;
                height: auto;
                max-width: 450px;
            }
            
            .form-container {
                width: 100%;
                position: relative;
                padding: 20px;
            }
            
            .sign-up-container {
                transform: translateX(100%);
            }
            
            .container.right-panel-active .sign-up-container {
                transform: translateX(0);
            }
            
            .overlay-container {
                display: none;
            }
            
            .container.right-panel-active .sign-in-container {
                transform: translateX(0);
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Floating decorative icons -->
    <i class="fas fa-leaf floating-icon icon-1"></i>
    <i class="fas fa-seedling floating-icon icon-2"></i>
    <i class="fas fa-spa floating-icon icon-3"></i>
    
    <div class="container" id="container">
        <!-- Formulaire d'inscription -->
        <div class="form-container sign-up-container">
            <form action="RegisterServlet" method="POST" id="registerForm" onsubmit="return validateRegisterForm()">
                <h1><i class="fas fa-user-plus" style="margin-right: 10px;"></i>INSCRIPTION</h1>
                <div class="social-container">
                    <a href="#" class="social"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="social"><i class="fab fa-google"></i></a>
                    <a href="#" class="social"><i class="fab fa-linkedin-in"></i></a>
                </div>
                <span>Rejoignez notre communauté en remplissant ces informations :</span>
                
                <input type="text" placeholder="Nom" name="nom" pattern="[A-Za-zÀ-ÿ\s]{2,50}" 
                       title="Le nom doit contenir entre 2 et 50 caractères alphabétiques" required />
                
                <input type="text" placeholder="Prénom" name="prenom" pattern="[A-Za-zÀ-ÿ\s]{2,50}" 
                       title="Le prénom doit contenir entre 2 et 50 caractères alphabétiques" required />
                
                <input type="email" placeholder="Email" name="email" required />
                
                <input type="number" placeholder="Frais d'adhesion" name="Fraid_dadhesion" 
                       min="0" step="0.01" required />
                
                <input type="number" placeholder="Ex: 0701234567" name="numero" 
                       pattern="0[0-9]{9}" step="0.01" required />
                
                <input type="text" placeholder="Localisation" name="localisation" required />
                
                <div class="password-container">
                    <input type="password" placeholder="Mot de passe" name="password" 
                           id="registerPassword" pattern="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$" required />
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('registerPassword')"></i>
                </div>
                <div class="password-requirements">
                    <i class="fas fa-info-circle" style="margin-right: 5px;"></i>
                    Le mot de passe doit contenir au moins 8 caractères, incluant lettres et chiffres
                </div>
                
                <button type="submit"><i class="fas fa-user-edit" style="margin-right: 8px;"></i>S'inscrire</button>
            </form>
        </div>
        
        <!-- Formulaire de connexion -->
        <div class="form-container sign-in-container">
            <form action="LoginServlet" method="POST" id="loginForm" onsubmit="return validateLoginForm()">
                <h1><i class="fas fa-sign-in-alt" style="margin-right: 10px;"></i>CONNEXION</h1>
                <div class="social-container">
                    <a href="#" class="social"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="social"><i class="fab fa-google"></i></a>
                    <a href="#" class="social"><i class="fab fa-linkedin-in"></i></a>
                </div>
                <span>Connectez-vous pour accéder à votre espace :</span>
                
                <input type="email" placeholder="Email" name="email" required />
                
                <div class="password-container">
                    <input type="password" placeholder="Mot de passe" name="password" 
                           id="loginPassword" required />
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('loginPassword')"></i>
                </div>
                
                <a href="#" class="forgot"><i class="fas fa-key" style="margin-right: 5px;"></i>Mot de passe oublié ?</a>
                <div>
                <button type="submit"><i class="fas fa-sign-in-alt" style="margin-right: 8px;"></i>Se connecter</button>
                </div>
            </form>
        </div>
        
        <!-- Section Overlay -->
        <div class="overlay-container">
            <div class="overlay">
                <div class="overlay-panel overlay-left">
                    <h1>Content de vous revoir !</h1>
                    <p>Pour rester connecté avec nous, veuillez vous connecter avec vos informations personnelles</p>
                    <button class="ghost" id="signInBtn"><i class="fas fa-sign-in-alt" style="margin-right: 8px;"></i>Se connecter</button>
                </div>
                <div class="overlay-panel overlay-right">
                    <h1>Bienvenue chez Go-Far !</h1>
                    <p>Entrez vos informations personnelles et commencez votre voyage avec nous</p>
                    <button class="ghost" id="signUpBtn"><i class="fas fa-user-plus" style="margin-right: 8px;"></i>S'inscrire</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Messages -->
    <% if(request.getParameter("error") != null) { %>
        <div class="error-message">
            <i class="fas fa-exclamation-circle message-icon"></i>
            <div><%= request.getParameter("error") %></div>
        </div>
    <% } %>
    
    <% if(request.getParameter("success") != null) { %>
        <div class="success-message">
            <i class="fas fa-check-circle message-icon"></i>
            <div><%= request.getParameter("success") %></div>
        </div>
    <% } %>

    <script>
        // Fonction pour basculer la visibilité du mot de passe
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = event.currentTarget;
            
            if (input.type === "password") {
                input.type = "text";
                icon.classList.remove("fa-eye");
                icon.classList.add("fa-eye-slash");
            } else {
                input.type = "password";
                icon.classList.remove("fa-eye-slash");
                icon.classList.add("fa-eye");
            }
        }

        // Validation du formulaire d'inscription
        function validateRegisterForm() {
            const password = document.getElementById("registerPassword").value;
            if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$/.test(password)) {
                showCustomAlert("Le mot de passe doit contenir au moins 8 caractères, incluant lettres et chiffres", "error");
                return false;
            }
            return true;
        }

        // Validation du formulaire de connexion
        function validateLoginForm() {
            const email = document.querySelector("#loginForm input[type='email']").value;
            const password = document.getElementById("loginPassword").value;
            
            if (!email || !password) {
                showCustomAlert("Veuillez remplir tous les champs", "error");
                return false;
            }
            return true;
        }

        // Fonction pour afficher des alertes personnalisées
        function showCustomAlert(message, type) {
            const alertDiv = document.createElement('div');
            alertDiv.className = type === 'error' ? 'error-message' : 'success-message';
            alertDiv.innerHTML = `
                <i class="fas ${type == "error" ? "fa-exclamation-circle" : "fa-check-circle"}
 message-icon"></i>
                <div>${message}</div>
            `;
            
            document.body.appendChild(alertDiv);
            
            // Supprime l'alerte après 5 secondes
            setTimeout(() => {
                alertDiv.remove();
            }, 5000);
        }

        // Initialisation des événements
        document.addEventListener("DOMContentLoaded", function() {
            const container = document.getElementById("container");
            const signUpBtn = document.getElementById("signUpBtn");
            const signInBtn = document.getElementById("signInBtn");

            // Animation pour le bouton d'inscription
            signUpBtn.addEventListener("click", () => {
                container.classList.add("right-panel-active");
            });
            
            // Animation pour le bouton de connexion
            signInBtn.addEventListener("click", () => {
                container.classList.remove("right-panel-active");
            });
            
            // Afficher le formulaire d'inscription s'il y a une erreur d'inscription
            <% if(request.getParameter("error") != null && 
                  request.getParameter("error").contains("Registration")) { %>
                container.classList.add("right-panel-active");
            <% } %>

            // Ajout d'effets hover supplémentaires
            const buttons = document.querySelectorAll('button');
            buttons.forEach(button => {
                button.addEventListener('mouseenter', () => {
                    button.style.transform = 'translateY(-3px)';
                    button.style.boxShadow = '0 7px 20px rgba(0, 0, 0, 0.15)';
                });
                
                button.addEventListener('mouseleave', () => {
                    button.style.transform = 'translateY(0)';
                    button.style.boxShadow = '0 5px 15px rgba(0, 0, 0, 0.1)';
                });
            });
        });
    </script>
</body>
</html>