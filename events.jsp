<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Événements - GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #2e7d32;
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
        }

        .events-container {
            padding: 3rem 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-title {
            text-align: center;
            margin-bottom: 3rem;
            color: var(--primary-color);
            font-size: 2.5rem;
        }

        .videos-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 2rem;
            margin-top: 2rem;
        }

        .video-card {
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }

        .video-card:hover {
            transform: translateY(-5px);
        }

        .video-container {
            position: relative;
            padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
            height: 0;
            overflow: hidden;
        }

        .video-container iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: none;
        }

        .video-info {
            padding: 1.5rem;
        }

        .video-title {
            color: var(--primary-color);
            margin-bottom: 0.5rem;
            font-size: 1.2rem;
        }

        .video-date {
            color: #666;
            font-size: 0.9rem;
            margin-bottom: 1rem;
        }

        .video-desc {
            color: #444;
            line-height: 1.6;
        }

        @media (max-width: 768px) {
            .videos-grid {
                grid-template-columns: 1fr;
            }
            
            .section-title {
                font-size: 2rem;
            }
        }
    </style>
</head>
<body>
    <div class="events-container">
        <h1 class="section-title">Nos Événements en Vidéo</h1>
        
        <div class="videos-grid">
            <!-- Vidéo 1 -->
            <div class="video-card">
                <div class="video-container">
                    <iframe src="https://www.youtube.com/embed/VIDEO_ID_1" 
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen
                            aria-label="Vidéo de notre dernier séminaire"></iframe>
                </div>
                <div class="video-info">
                    <h3 class="video-title">Séminaire Annuel 2023</h3>
                    <p class="video-date">15 Mars 2023</p>
                    <p class="video-desc">Revivez les moments forts de notre séminaire annuel avec des interventions inspirantes.</p>
                </div>
            </div>
            
            <!-- Vidéo 2 -->
            <div class="video-card">
                <div class="video-container">
                    <iframe src="https://www.youtube.com/embed/VIDEO_ID_2" 
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen
                            aria-label="Vidéo de l'atelier de formation"></iframe>
                </div>
                <div class="video-info">
                    <h3 class="video-title">Atelier de Formation</h3>
                    <p class="video-date">22 Juin 2023</p>
                    <p class="video-desc">Découvrez notre atelier de formation sur le développement personnel.</p>
                </div>
            </div>
            
            <!-- Vidéo 3 -->
            <div class="video-card">
                <div class="video-container">
                    <iframe src="https://www.youtube.com/embed/VIDEO_ID_3" 
                            frameborder="0" 
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
                            allowfullscreen
                            aria-label="Vidéo de l'événement caritatif"></iframe>
                </div>
                <div class="video-info">
                    <h3 class="video-title">Action Caritative</h3>
                    <p class="video-date">5 Décembre 2023</p>
                    <p class="video-desc">Retour sur notre action caritative de fin d'année à l'orphelinat local.</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>