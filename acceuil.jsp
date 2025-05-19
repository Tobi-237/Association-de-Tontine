<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="GO-FAR - Association reconnue par l'État pour le développement personnel et professionnel">
    <title>GO-FAR - Association Reconnue par l'État</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #2e7d32;
            --primary-light: #60ad5e;
            --primary-dark: #005005;
            --secondary-color: #f5f5f5;
            --white: #ffffff;
            --text-color: #333;
            --gray-light: #e0e0e0;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: var(--white);
            color: var(--text-color);
            overflow-x: hidden;
            line-height: 1.6;
        }

        /* Accessibilité : augmentation de la taille de police de base */
        html {
            font-size: 16px;
        }

        /* Amélioration des contrastes pour l'accessibilité */
        a, button {
            color: var(--primary-dark);
        }

        .hero {
            position: relative;
            height: 100vh;
            min-height: 600px;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: white;
            overflow: hidden;
        }

        .hero::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)), 
                        url('WhatsApp Image 2025-04-21 à 17.16.15_c4f43f4a.jpg') no-repeat center center/cover;
            z-index: -1;
        }

        .hero-content {
            max-width: 800px;
            padding: 0 2rem;
            animation: fadeInUp 1s ease;
        }

        .hero h1 {
            font-size: clamp(2.5rem, 5vw, 3.5rem);
            margin-bottom: 1.5rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.5);
            animation: pulse 2s infinite;
        }

        .hero p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
        }

        .btn {
            display: inline-block;
            padding: 0.75rem 1.875rem;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .btn:hover, .btn:focus {
            background-color: var(--primary-dark);
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
            outline: none;
        }

        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            padding: 1.25rem 3.125rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: rgba(255, 255, 255, 0.95);
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            transition: all 0.3s ease;
        }

        .navbar.scrolled {
            padding: 0.9375rem 3.125rem;
            background-color: rgba(46, 125, 50, 0.95);
        }

        .navbar.scrolled .nav-links a,
        .navbar.scrolled .social-icons a {
            color: white;
        }

        .logo-tobi {
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            padding: 0.3125rem;
        }

        .logo-img {
            width: 3.75rem;
            height: auto;
            border-radius: 0.5rem;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease;
        }

        .logo-tobi:hover .logo-img {
            transform: scale(1.05);
        }

        .navbar.scrolled .logo-img {
            filter: brightness(0) invert(1);
        }

        .nav-links {
            display: flex;
            gap: 1.875rem;
        }

        .nav-links a {
            color: var(--text-color);
            text-decoration: none;
            font-weight: 500;
            transition: color 0.3s ease;
            padding: 0.5rem 0;
            position: relative;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 0;
            height: 2px;
            background-color: var(--primary-color);
            transition: width 0.3s ease;
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        .nav-links a:hover {
            color: var(--primary-color);
        }

        .navbar.scrolled .nav-links a:hover {
            color: #d1ffd6;
        }

        .navbar.scrolled .nav-links a::after {
            background-color: #d1ffd6;
        }

        .social-icons {
            display: flex;
            gap: 1.25rem;
            align-items: center;
        }

        .social-icons a {
            color: var(--text-color);
            font-size: 1.2rem;
            transition: all 0.3s ease;
        }

        .social-icons a:hover, .social-icons a:focus {
            color: var(--primary-color);
            transform: translateY(-3px);
            outline: none;
        }

        .navbar.scrolled .social-icons a:hover {
            color: #d1ffd6;
        }

        .search-box {
            position: relative;
            margin-left: 1.25rem;
        }

        .search-box input {
            padding: 0.5rem 0.9375rem 0.5rem 2.1875rem;
            border: 1px solid var(--gray-light);
            border-radius: 50px;
            outline: none;
            transition: all 0.3s ease;
            width: 12.5rem;
        }

        .search-box input:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(46, 125, 50, 0.2);
        }

        .search-box i {
            position: absolute;
            left: 0.75rem;
            top: 50%;
            transform: translateY(-50%);
            color: #777;
        }

        .features {
            padding: 6.25rem 3.125rem;
            background-color: var(--white);
        }

        .section-title {
            text-align: center;
            margin-bottom: 3.75rem;
            color: var(--primary-color);
            font-size: clamp(1.8rem, 4vw, 2.5rem);
            position: relative;
        }

        .section-title::after {
            content: '';
            position: absolute;
            bottom: -0.9375rem;
            left: 50%;
            transform: translateX(-50%);
            width: 5rem;
            height: 0.25rem;
            background-color: var(--primary-color);
            border-radius: 0.125rem;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(18.75rem, 1fr));
            gap: 2.5rem;
            margin-top: 3.125rem;
        }

        .feature-card {
            background-color: white;
            border-radius: 0.625rem;
            padding: 1.875rem;
            box-shadow: 0 0.625rem 1.875rem rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
            text-align: center;
            border-top: 0.25rem solid var(--primary-color);
        }

        .feature-card:hover {
            transform: translateY(-0.625rem);
            box-shadow: 0 0.9375rem 2.5rem rgba(0, 0, 0, 0.1);
        }

        .feature-icon {
            font-size: 3rem;
            color: var(--primary-color);
            margin-bottom: 1.25rem;
            transition: all 0.3s ease;
        }

        .feature-card:hover .feature-icon {
            transform: scale(1.1);
        }

        .feature-image-container {
            width: 15.625rem;
            height: 5rem;
            margin: 0 auto 1.25rem;
            overflow: hidden;
            border-radius: 0.5rem;
            box-shadow: 0 0.25rem 0.5rem rgba(0,0,0,0.1);
        }

        .feature-image {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }

        .feature-card:hover .feature-image {
            transform: scale(1.05);
        }

        .feature-title {
            font-size: 1.5rem;
            margin-bottom: 0.9375rem;
            color: var(--primary-color);
        }

        .feature-desc {
            color: #666;
            line-height: 1.6;
        }

        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            border-radius: 0.625rem;
            width: 90%;
            max-width: 50rem;
            max-height: 90vh;
            overflow-y: auto;
            padding: 1.875rem;
            position: relative;
            animation: modalFadeIn 0.5s ease;
        }

        @keyframes modalFadeIn {
            from {
                opacity: 0;
                transform: translateY(-3.125rem);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .close-modal {
            position: absolute;
            top: 1.25rem;
            right: 1.25rem;
            font-size: 1.5rem;
            color: #777;
            cursor: pointer;
            transition: color 0.3s ease;
            background: none;
            border: none;
        }

        .close-modal:hover, .close-modal:focus {
            color: var(--primary-color);
            outline: none;
        }

        .modal-title {
            color: var(--primary-color);
            margin-bottom: 1.25rem;
            text-align: center;
            font-size: 2rem;
        }

        .modal-body {
            line-height: 1.8;
        }

        .modal-body h3 {
            color: var(--primary-color);
            margin: 1.25rem 0 0.625rem;
        }

        .modal-body ul {
            margin-bottom: 1.25rem;
            padding-left: 1.25rem;
        }

        .modal-body li {
            margin-bottom: 0.5rem;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(1.875rem);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes pulse {
            0% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
            100% {
                transform: scale(1);
            }
        }

        .gallery {
            padding: 3.125rem;
            background-color: var(--secondary-color);
        }

        .gallery-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(15.625rem, 1fr));
            gap: 1.25rem;
            margin-top: 2.5rem;
        }

        .gallery-item {
            background: white;
            border-radius: 0.625rem;
            overflow: hidden;
            box-shadow: 0 0.3125rem 0.9375rem rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .gallery-item:hover {
            transform: translateY(-0.5rem);
        }

        .gallery-image {
            width: 100%;
            height: 12.5rem;
            object-fit: cover;
        }

        .gallery-caption {
            padding: 0.9375rem;
        }

        .gallery-caption h3 {
            color: var(--primary-color);
            margin-bottom: 0.625rem;
        }

        .gallery-caption p {
            color: #666;
        }

        footer {
            background-color: var(--primary-color);
            color: white;
            padding: 3.125rem;
            text-align: center;
        }

        .footer-logo {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1.25rem;
        }

        .footer-links {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 1.875rem;
            margin-bottom: 1.875rem;
        }

        .footer-links a {
            color: white;
            text-decoration: none;
            transition: color 0.3s ease;
            padding: 0.5rem 0;
        }

        .footer-links a:hover, .footer-links a:focus {
            color: #d1ffd6;
            outline: none;
        }

        .footer-social {
            display: flex;
            justify-content: center;
            gap: 1.25rem;
            margin-bottom: 1.875rem;
        }

        .footer-social a {
            color: white;
            font-size: 1.5rem;
            transition: all 0.3s ease;
        }

        .footer-social a:hover, .footer-social a:focus {
            color: #d1ffd6;
            transform: translateY(-0.3125rem);
            outline: none;
        }

        .copyright {
            font-size: 0.9rem;
            opacity: 0.8;
        }

        /* Skip to content link for accessibility */
        .skip-link {
            position: absolute;
            top: -3.125rem;
            left: 0;
            background: var(--primary-color);
            color: white;
            padding: 0.5rem 1rem;
            z-index: 1001;
            transition: top 0.3s;
        }

        .skip-link:focus {
            top: 0;
        }

        /* Responsive Design */
        @media (max-width: 64rem) {
            .navbar {
                flex-direction: column;
                padding: 1rem 1.25rem;
                gap: 1rem;
            }
            
            .nav-links {
                gap: 1rem;
            }
            
            .search-box {
                margin: 0.5rem 0;
                width: 100%;
            }
            
            .search-box input {
                width: 100%;
            }
            
            .features {
                padding: 3.75rem 1.25rem;
            }
            
            .gallery {
                padding: 3.125rem 1.25rem;
            }
            
            .hero h1 {
                font-size: 2.2rem;
            }
            
            .section-title {
                font-size: 2rem;
            }
        }

        @media (max-width: 48rem) {
            .hero {
                min-height: 500px;
            }
            
            .hero-content {
                padding: 0 1rem;
            }
            
            .features-grid {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .footer-links {
                flex-direction: column;
                gap: 0.5rem;
            }
        }

        /* Print styles */
        @media print {
            .navbar, .hero, .footer-social, .btn {
                display: none !important;
            }
            
            body {
                background: white;
                color: black;
                font-size: 12pt;
            }
            
            .features, .gallery {
                padding: 1rem;
                page-break-inside: avoid;
            }
            
            a::after {
                content: " (" attr(href) ")";
                font-size: 0.8em;
                font-weight: normal;
            }
        }
    </style>
</head>
<body>
    <!-- Skip to content link for keyboard users -->
    <a href="#main-content" class="skip-link">Aller au contenu principal</a>

    <!-- Navigation Bar -->
    <nav class="navbar" aria-label="Navigation principale">
        <a href="#" class="logo-tobi" aria-label="Retour à l'accueil">
            <img src="Capture d’écran 2025-04-22 125810.jpg" alt="Logo GO-FAR" class="logo-img">
        </a>
        <div class="nav-links">
            <a href="#" aria-current="page">Accueil</a>
            <a href="#about">À propos</a>
            <a href="#contact">Contact</a>
        </div>
        <div class="search-box">
            <i class="fas fa-search" aria-hidden="true"></i>
            <input type="text" placeholder="Rechercher..." aria-label="Rechercher sur le site">
        </div>
        <div class="social-icons">
            <a href="https://facebook.com" target="_blank" aria-label="Facebook"><i class="fab fa-facebook-f" aria-hidden="true"></i></a>
                       <a href="https://wa.me/+237695050801" target="_blank" rel="noopener noreferrer" aria-label="WhatsApp">
  <i class="fab fa-whatsapp"></i></a>
            <a href="login.jsp" class="btn" style="padding: 0.5rem 1.25rem;">Connexion</a>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero" id="main-content">
        <div class="hero-content">
            <h1>BIENVENUE DANS NOTRE ASSOCIATION (NDE DE MABANDA)</h1>
            <p>Développez une passion pour apprendre de nouvelles choses. Avec un engagement continu, nous célébrons chaque découverte et chaque progrès.</p>
            <button class="btn" id="openModalBtn">Voir notre reconnaissance</button>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features" id="about">
        <h2 class="section-title">Nos Valeurs</h2>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon" aria-hidden="true">
                    <i class="fas fa-certificate"></i>
                </div>
                <div class="feature-image-container">
                    <img src="WhatsApp Image 2025-04-21 à 17.16.13_99f50d69.jpg" 
                         alt="Certification officielle de l'association" 
                         class="feature-image">
                </div>
                <h3 class="feature-title">Certification</h3>
                <p class="feature-desc">Notre association est officiellement reconnue par l'État avec tous les documents légaux nécessaires pour opérer en toute transparence.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon" aria-hidden="true">
                    <i class="fas fa-chalkboard-teacher"></i>
                </div>
                <div class="feature-image-container">
                    <img src="1ea6a3_08a03d5d836441f88a4651aa7d383543~mv2.jpg" 
                         alt="Experts en formation professionnelle" 
                         class="feature-image">
                </div>
                <h3 class="feature-title">Experts Qualifiés</h3>
                <p class="feature-desc">Nous travaillons avec des professionnels expérimentés dans leurs domaines pour vous offrir le meilleur accompagnement possible.</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon" aria-hidden="true">
                    <i class="fas fa-globe"></i>
                </div>
                <div class="feature-image-container">
                    <img src="OIP (12).jpeg" 
                         alt="Accessibilité pour tous" 
                         class="feature-image">
                </div>
                <h3 class="feature-title">Accessibilité</h3>
                <p class="feature-desc">Nos services sont accessibles partout, que vous soyez en ville ou en campagne, nous trouvons des solutions adaptées.</p>
            </div>
        </div>
    </section>

    <!-- Gallery Section -->
    <section class="gallery" aria-labelledby="gallery-title">
        <h2 class="section-title" id="gallery-title"> Nos Tontines</h2>
        <div class="gallery-grid">
            <div class="gallery-item">
                <img src="OIP (13).jpeg" alt="tontine de presence de l'association" class="gallery-image">
                <div class="gallery-caption">
                    <h3>PRESENCE</h3>
                    <p>Elle est obligatoire , le taux est de 1000FCFA a chaque seance de reuinion 
                    ,pour Beneficier de cette presence ont procede a un tirage au sort dans lequel
                     on choisit deux adherents qui vont beneficier. </p>
                </div>
            </div>
            <div class="gallery-item">
                <img src="Nigeria_Header_Community-volunteers-from-local-NGO-Heal-the-Land-Initiative-HELIN-provide-free-HIV-tests-at-the-local-market-in-Eyokponung-Rivers-State-in-2014.-Photo-by-Gwenn-Dubourthournieu-1024x683.jpg" alt="tontine hebdomadaire de l'association" class="gallery-image">
                <div class="gallery-caption">
                    <h3>Tontine Hebdomadaire</h3>
                    <p>C'elle-ci n'est pas obligatoire et le taux varie de 5.000FCFA a 10.000FCFA chaque samedi.
                    Pour Beneficier de cette tontine ont procede a un tirage au sort dans lequel on
                    choisi deux adherents qui vont beneficier .</p>
                </div>
            </div>
            <div class="gallery-item">
                <img src="OIP (14).jpeg" alt="Tontines mensuelles de l'association" class="gallery-image">
                <div class="gallery-caption">
                    <h3>Tontines mensuelles </h3>
                    <p>Elle se tiens tous les derniers samedis du mois le taux varie de 15.000FCFA a 20.000FCFA
                    et l'adhesion a cette tontine n'est  pas obligatoire.Pour Beneficier de cette Tontine ont procede a un tirage au sort dans lequel
                    on choisi deux adherents qui vont beneficier .</p>
                </div>
            </div>
            <div class="gallery-item">
                <img src="don_orphelinat4-1024x683.jpg" alt="Projet fin d'année de l'association" class="gallery-image">
                <div class="gallery-caption">
                    <h3>Actions sociales</h3>
                    <p>Chaque fin d'année l'association aporte son soutient aux enfants demunis .</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Modal -->
    <div class="modal" id="recognitionModal" role="dialog" aria-labelledby="modalTitle" aria-modal="true">
        <div class="modal-content">
            <button class="close-modal" id="closeModalBtn" aria-label="Fermer la fenêtre">&times;</button>
            <h2 class="modal-title" id="modalTitle">Reconnaissance Officielle</h2>
            <div class="modal-body">
                <p>L'association GO-FAR(NDE DE MANBANDA) est officiellement reconnue par l'État sous le numéro W092456789, enregistrée le 15 janvier 1980.</p>
                
                <h3>Documents Officiels</h3>
                <ul>
                    <li>Déclaration au Journal Officiel n°092 du 20/01/1779 portant autorisations des applications</li>
                    <li>Agrément préfectoral n°1779-567</li>
                    <li>Statuts déposés en préfecture le 10/01/2020</li>
                    <li>Reçu de déclaration de création</li>
                </ul>
                
                <h3>Regroupement Statutaires</h3>
                <p>Cette association regroupe :</p>
                <ul>
                    <li>Elle regroupe les fils </li>
                    <li>regroupe les filles des 13 villages du departement du Ndé </li>
                    
                </ul>
                
                <h3>Bon a savoir </h3>
                <p>Elle est apolitique son but est non lucratif mais plus tot culturel, elle est rigie 
                par un reglement interieur(ce reglement interieur est dans espace reservé pour chaque 
                adherent de l'association ).</p>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer id="contact">
        <div class="footer-logo">GO-FAR</div>
        <div class="footer-links">
            <a href="acceuil.jsp">Accueil</a>
            <a href="#about">À propos</a>
            <a href="events.jsp">Événements</a>
            <a href="https://wa.me/+237695050801">Contact</a>
            <a href="#legal">Mentions légales</a>
        </div>
        <div class="footer-social">
            <a href="https://facebook.com" target="_blank" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
            <a href="https://wa.me/+237695050801" target="_blank" rel="noopener noreferrer" aria-label="WhatsApp">
  <i class="fab fa-whatsapp"></i>
</a>
        </div>
        <p class="copyright">© 2023 Association GO-FAR. Tous droits réservés.</p>
    </footer>

    <script>
        // Navbar scroll effect
        window.addEventListener('scroll', function() {
            const navbar = document.querySelector('.navbar');
            if (window.scrollY > 50) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
        });

        // Modal functionality
        const modal = document.getElementById('recognitionModal');
        const openBtn = document.getElementById('openModalBtn');
        const closeBtn = document.getElementById('closeModalBtn');

        function openModal() {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            document.addEventListener('keydown', handleEscape);
        }

        function closeModal() {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
            document.removeEventListener('keydown', handleEscape);
        }

        function handleEscape(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        }

        openBtn.addEventListener('click', openModal);
        closeBtn.addEventListener('click', closeModal);

        window.addEventListener('click', function(e) {
            if (e.target === modal) {
                closeModal();
            }
        });

        // Focus trap for modal
        modal.addEventListener('keydown', function(e) {
            if (e.key === 'Tab') {
                const focusableElements = modal.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
                const firstElement = focusableElements[0];
                const lastElement = focusableElements[focusableElements.length - 1];

                if (e.shiftKey) {
                    if (document.activeElement === firstElement) {
                        lastElement.focus();
                        e.preventDefault();
                    }
                } else {
                    if (document.activeElement === lastElement) {
                        firstElement.focus();
                        e.preventDefault();
                    }
                }
            }
        });

        // Animation on scroll
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -100px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('animate');
                }
            });
        }, observerOptions);

        document.querySelectorAll('.feature-card, .gallery-item').forEach(item => {
            observer.observe(item);
        });

        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                
                const targetId = this.getAttribute('href');
                if (targetId === '#') return;
                
                const targetElement = document.querySelector(targetId);
                if (targetElement) {
                    targetElement.scrollIntoView({
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Lazy loading for images
        if ('loading' in HTMLImageElement.prototype) {
            const lazyImages = document.querySelectorAll('img[loading="lazy"]');
            lazyImages.forEach(img => {
                img.loading = 'lazy';
            });
        } else {
            // Fallback for browsers that don't support lazy loading
            const lazyLoad = function() {
                const lazyImages = document.querySelectorAll('img[loading="lazy"]');
                
                const lazyImageObserver = new IntersectionObserver(function(entries) {
                    entries.forEach(function(entry) {
                        if (entry.isIntersecting) {
                            const lazyImage = entry.target;
                            lazyImage.src = lazyImage.dataset.src;
                            lazyImageObserver.unobserve(lazyImage);
                        }
                    });
                });

                lazyImages.forEach(function(lazyImage) {
                    lazyImageObserver.observe(lazyImage);
                });
            };

            document.addEventListener('DOMContentLoaded', lazyLoad);
        }
    </script>
</body>
</html>