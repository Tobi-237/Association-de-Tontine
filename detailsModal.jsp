<%@page import="java.sql.Connection"%>
<%@page import="utils.DBConnection"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.ResultSet"%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Details</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }

        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.5);
            backdrop-filter: blur(5px);
            animation: backgroundFadeIn 0.3s ease-out;
        }

        .modal-content {
            position: relative;
            background: linear-gradient(135deg, #ffffff 0%, #f5f9f0 100%);
            margin: 5% auto;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 100, 0, 0.2);
            width: 90%;
            max-width: 600px;
             position: relative;
            border: 1px solid #e0e8d9;
            transform-origin: center;
            overflow: hidden;
           
        }

        .modal-content::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(90deg, #4CAF50, #8BC34A, #CDDC39);
            animation: rainbow 8s linear infinite;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-50px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }

        @keyframes backgroundFadeIn {
            from { background-color: rgba(0,0,0,0); }
            to { background-color: rgba(0,0,0,0.5); }
        }

        @keyframes rainbow {
            0% { background-position: 0% 50%; }
            100% { background-position: 100% 50%; }
        }

        .close-btn {
            position: absolute;
            top: 15px;
            right: 25px;
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .close-btn:hover {
            color: #4CAF50;
            transform: rotate(90deg) scale(1.2);
        }

        #modalTitle, h2 {
            color: #2E7D32;
            text-align: center;
            margin-bottom: 25px;
            font-size: 24px;
            position: relative;
            padding-bottom: 15px;
        }

        #modalTitle::after, h2::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 3px;
            background: linear-gradient(90deg, #4CAF50, #8BC34A);
            border-radius: 3px;
        }

        #modalTitle i, h2 i {
            margin-right: 10px;
            color: #4CAF50;
        }

        .details-container {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .detail-item {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-start;
            padding: 10px 0;
            border-bottom: 1px solid #e0e8d9;
        }

        .detail-item.full-width {
            flex-direction: column;
        }

        .detail-label {
            font-weight: 600;
            color: #4a614d;
            min-width: 150px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-label i {
            width: 20px;
            text-align: center;
            color: #689F38;
        }

        .detail-value {
            flex: 1;
            color: #333;
            word-break: break-word;
        }

        .detail-actions {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
        }

        .btn {
            padding: 12px 25px;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            border: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .btn i {
            font-size: 14px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #4CAF50, #8BC34A);
            color: white;
            box-shadow: 0 4px 6px rgba(76, 175, 80, 0.2);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #43A047, #7CB342);
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(76, 175, 80, 0.3);
        }

        @media (max-width: 768px) {
            .modal-content {
                margin: 10% auto;
                width: 95%;
                padding: 20px;
            }
            
            .btn {
                padding: 10px 20px;
            }
            
            .detail-item {
                flex-direction: column;
                gap: 5px;
            }
            
            .detail-label {
                min-width: 100%;
            }
        }
    </style>
</head>
<body>
    <div id="detailsModal" class="modal">
        <div class="modal-content">
            <span class="close-btn" onclick="closeDetailsModal()">&times;</span>
            <h2><i class="fas fa-info-circle"></i> Détails de la sanction</h2>
            
            <div class="details-container">
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-user"></i> Membre:</span>
                    <span id="detailMember" class="detail-value"></span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-exclamation-circle"></i> Type:</span>
                    <span id="detailType" class="detail-value"></span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-money-bill-wave"></i> Montant:</span>
                    <span id="detailAmount" class="detail-value"></span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-calendar-alt"></i> Date sanction:</span>
                    <span id="detailDate" class="detail-value"></span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-calendar-times"></i> Date fin:</span>
                    <span id="detailEndDate" class="detail-value"></span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label"><i class="fas fa-info-circle"></i> Statut:</span>
                    <span id="detailStatus" class="detail-value"></span>
                </div>
                
                <div class="detail-item full-width">
                    <span class="detail-label"><i class="fas fa-comment-alt"></i> Motif:</span>
                    <p id="detailReason" class="detail-value"></p>
                </div>
                
                <div class="detail-actions">
                    <button class="btn btn-primary" onclick="closeDetailsModal()">
                        <i class="fas fa-times"></i> Fermer
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function closeDetailsModal() {
            document.getElementById('detailsModal').style.display = 'none';
        }
        
        // Example function to show modal with data
        function showDetailsModal(data) {
            document.getElementById('detailMember').textContent = data.member || 'Non spécifié';
            document.getElementById('detailType').textContent = data.type || 'Non spécifié';
            document.getElementById('detailAmount').textContent = data.amount || 'Non spécifié';
            document.getElementById('detailDate').textContent = data.date || 'Non spécifié';
            document.getElementById('detailEndDate').textContent = data.endDate || 'Non spécifié';
            document.getElementById('detailStatus').textContent = data.status || 'Non spécifié';
            document.getElementById('detailReason').textContent = data.reason || 'Aucun motif spécifié';
            
            document.getElementById('detailsModal').style.display = 'block';
        }
        
        // You can call showDetailsModal() with your data when needed
        // Example: showDetailsModal({
        //     member: "John Doe",
        //     type: "Retard de paiement",
        //     amount: "50 000 FCFA",
        //     date: "15/10/2023",
        //     endDate: "15/11/2023",
        //     status: "Active",
        //     reason: "Paiement en retard de plus de 15 jours"
        // });
    </script>
</body>
</html>