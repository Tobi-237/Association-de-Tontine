<%@ page import="java.sql.*" %>
<%@ page import="utils.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.io.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<%@ page import="java.nio.file.Paths" %>
<%@ page session="true" %>

<%
    // Vérifier si l'utilisateur (membre) est connecté
    Integer memberId = (Integer) session.getAttribute("memberId");
    if (memberId == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Montant fixe de la souscription
    final BigDecimal SOUSCRIPTION_AMOUNT = new BigDecimal("10000");
    
    // Configuration du répertoire d'upload
    String uploadPath = getServletContext().getRealPath("/") + "uploads";
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) uploadDir.mkdir();
    
    // Gérer le paiement de souscription
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Variables pour stocker les données du formulaire
        String paymentMethod = request.getParameter("payment_method");
        String reference = request.getParameter("reference");
        BigDecimal montant = SOUSCRIPTION_AMOUNT;
        String montantParam = request.getParameter("montant");
        if (montantParam != null && !montantParam.isEmpty()) {
            montant = new BigDecimal(montantParam);
        }
        
        // Gestion de l'upload de fichier
        String fileName = null;
        Part filePart = request.getPart("preuve");
        if (filePart != null && filePart.getSize() > 0) {
            fileName = System.currentTimeMillis() + "_" + Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            filePart.write(uploadPath + File.separator + fileName);
        }
        
        // Validation des données
        if (montant.compareTo(SOUSCRIPTION_AMOUNT) < 0) {
            session.setAttribute("errorMessage", "Le montant doit être d'au moins " + SOUSCRIPTION_AMOUNT + " FCFA");
            response.sendRedirect("souscription.jsp");
            return;
        }
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Démarrer une transaction
            
            // 1. Vérifier que le membre existe
            String checkMemberSql = "SELECT id FROM members WHERE id = ?";
            try (PreparedStatement checkMemberPs = conn.prepareStatement(checkMemberSql)) {
                checkMemberPs.setInt(1, memberId);
                ResultSet memberRs = checkMemberPs.executeQuery();
                
                if (!memberRs.next()) {
                    session.setAttribute("errorMessage", "Erreur : Votre compte membre n'existe pas.");
                    response.sendRedirect("souscription.jsp");
                    return;
                }
            }
            
            // 2. Enregistrer le paiement
            String insertPaymentSql = "INSERT INTO paiements (member_id, montant, type_paiement, date_paiement, methode_paiement, reference, statut) " +
                                    "VALUES (?, ?, 'SOUSCRIPTION', NOW(), ?, ?, 'COMPLETED')";
            int paymentId = 0;
            
            try (PreparedStatement insertPaymentPs = conn.prepareStatement(insertPaymentSql, Statement.RETURN_GENERATED_KEYS)) {
                insertPaymentPs.setInt(1, memberId);
                insertPaymentPs.setBigDecimal(2, montant);
                insertPaymentPs.setString(3, paymentMethod);
                insertPaymentPs.setString(4, reference);
                
                int affectedRows = insertPaymentPs.executeUpdate();
                
                if (affectedRows == 0) {
                    throw new SQLException("Échec de l'insertion du paiement, aucune ligne affectée.");
                }
                
                try (ResultSet generatedKeys = insertPaymentPs.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        paymentId = generatedKeys.getInt(1);
                    }
                }
            }
            
            // 3. Enregistrer la souscription dans la table mutuelle
            String insertMutuelleSql = "INSERT INTO mutuelle (member_id, montant, payment_id, statut, preuve_souscription) " +
                                     "VALUES (?, ?, ?, 'ACTIVE', ?)";
            
            try (PreparedStatement insertMutuellePs = conn.prepareStatement(insertMutuelleSql)) {
                insertMutuellePs.setInt(1, memberId);
                insertMutuellePs.setBigDecimal(2, montant);
                insertMutuellePs.setInt(3, paymentId);
                
                if (fileName != null) {
                    insertMutuellePs.setString(4, fileName);
                } else {
                    insertMutuellePs.setNull(4, Types.VARCHAR);
                }
                
                insertMutuellePs.executeUpdate();
            }
            
            // 4. Envoyer un message à l'administrateur
            String messageSql = "INSERT INTO messages (sender_id, receiver_id, subject, content, related_payment_id) " +
                             "VALUES (?, 1, 'Nouveau paiement de souscription', ?, ?)";
            try (PreparedStatement messagePs = conn.prepareStatement(messageSql)) {
                messagePs.setInt(1, memberId);
                messagePs.setString(2, "Le membre ID " + memberId + " a effectué un paiement de souscription de " + 
                                      montant + " FCFA. Méthode: " + paymentMethod + ", Référence: " + reference);
                messagePs.setInt(3, paymentId);
                messagePs.executeUpdate();
            }
            
            conn.commit(); // Valider la transaction
            
            session.setAttribute("successMessage", "Paiement de souscription effectué avec succès! Vous êtes maintenant membre actif.");
            response.sendRedirect("souscription.jsp");
            return;
            
        } catch(Exception e) {
            if (conn != null) {
                conn.rollback(); // Annuler la transaction en cas d'erreur
            }
            e.printStackTrace();
            session.setAttribute("errorMessage", "Erreur lors du paiement: " + e.getMessage());
            response.sendRedirect("souscription.jsp");
            return;
        } finally {
            if (conn != null) {
                try { conn.close(); } catch(SQLException e) {}
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Paiement Souscription - Tontine GO-FAR</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    <style>
       /* BASE STYLES */
:root {
  --primary-color: #27ae60;
  --primary-dark: #219653;
  --primary-light: #e8f5e9;
  --secondary-color: #2c3e50;
  --accent-color: #f39c12;
  --light-color: #ffffff;
  --dark-color: #333333;
  --gray-light: #f5f5f5;
  --gray-medium: #95a5a6;
  --gray-dark: #7f8c8d;
  --error-color: #e74c3c;
  --success-color: #27ae60;
  --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  --transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Poppins', sans-serif;
  background: linear-gradient(135deg, #f5f7fa 0%, #e4efe9 100%);
  color: var(--secondary-color);
  line-height: 1.6;
  min-height: 100vh;
  overflow-x: hidden;
}

/* SIDEBAR STYLES */
.sidebar {
  width: 280px;
  background: linear-gradient(to bottom, var(--secondary-color), #1a252f);
  color: var(--light-color);
  height: 100vh;
  position: fixed;
  z-index: 1000;
  box-shadow: 4px 0 15px rgba(0, 0, 0, 0.1);
  transition: var(--transition);
}

.sidebar-header {
  padding: 20px;
  background: rgba(0, 0, 0, 0.2);
  text-align: center;
}

.sidebar-brand {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--light-color);
  text-decoration: none;
  font-size: 1.5rem;
  font-weight: 600;
}

.sidebar-brand i {
  margin-right: 10px;
  color: var(--primary-color);
  font-size: 1.8rem;
}

/* MAIN CONTENT STYLES */
.content {
  flex: 1;
  padding: 40px;
  margin-left: 280px;
  width: calc(100% - 280px);
  min-height: 100vh;
  transition: var(--transition);
}

/* HEADER STYLES */
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 15px;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.page-title {
  font-size: 2rem;
  color: var(--secondary-color);
  position: relative;
  display: inline-flex;
  align-items: center;
}

.page-title i {
  margin-right: 15px;
  color: var(--primary-color);
  font-size: 1.8rem;
}

.page-title::after {
  content: '';
  position: absolute;
  bottom: -15px;
  left: 0;
  width: 60px;
  height: 4px;
  background: linear-gradient(to right, var(--primary-color), var(--accent-color));
  border-radius: 2px;
}

/* CARD STYLES */
.card {
  background: var(--light-color);
  border-radius: 15px;
  box-shadow: var(--box-shadow);
  overflow: hidden;
  margin-bottom: 30px;
  transition: var(--transition);
}

.card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.15);
}

.card-header {
  padding: 20px 25px;
  background: linear-gradient(to right, var(--primary-color), var(--primary-dark));
  color: var(--light-color);
  display: flex;
  align-items: center;
}

.card-header i {
  font-size: 1.8rem;
  margin-right: 15px;
}

.card-title {
  font-size: 1.4rem;
  font-weight: 500;
}

.card-body {
  padding: 25px;
}

/* PAYMENT STYLES */
.payment-container {
  max-width: 700px;
  margin: 0 auto;
}

.payment-header {
  text-align: center;
  margin-bottom: 30px;
  position: relative;
}

.payment-icon {
  font-size: 3rem;
  color: var(--primary-color);
  margin-bottom: 15px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0% { transform: scale(1); }
  50% { transform: scale(1.1); }
  100% { transform: scale(1); }
}

.payment-amount {
  font-size: 2.5rem;
  font-weight: 700;
  color: var(--primary-color);
  margin: 15px 0;
  position: relative;
  display: inline-block;
}

.payment-amount::after {
  content: '';
  position: absolute;
  bottom: -10px;
  left: 50%;
  transform: translateX(-50%);
  width: 80px;
  height: 3px;
  background: linear-gradient(to right, var(--primary-color), var(--accent-color));
}

.payment-description {
  color: var(--gray-medium);
  font-size: 1rem;
}

/* FORM STYLES */
.form-group {
  margin-bottom: 25px;
  position: relative;
}

.form-group label {
  display: block;
  margin-bottom: 10px;
  font-weight: 500;
  color: var(--secondary-color);
  display: flex;
  align-items: center;
}

.form-group label i {
  margin-right: 10px;
  color: var(--primary-color);
  font-size: 1.2rem;
}

.form-control {
  width: 100%;
  padding: 15px 20px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1rem;
  transition: var(--transition);
  background-color: #f9f9f9;
}

.form-control:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(39, 174, 96, 0.2);
  outline: none;
  background-color: var(--light-color);
}

/* PAYMENT METHODS */
.payment-methods {
  margin: 30px 0;
}

.payment-method {
  display: flex;
  align-items: center;
  padding: 20px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  margin-bottom: 15px;
  cursor: pointer;
  transition: var(--transition);
  background-color: #f9f9f9;
}

.payment-method:hover {
  border-color: var(--primary-color);
  background-color: rgba(39, 174, 96, 0.05);
  transform: translateY(-3px);
}

.payment-method.active {
  border-color: var(--primary-color);
  background-color: var(--primary-light);
  box-shadow: 0 5px 15px rgba(39, 174, 96, 0.1);
}

.payment-method i {
  font-size: 2rem;
  margin-right: 20px;
  color: var(--primary-color);
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: rgba(39, 174, 96, 0.1);
  border-radius: 50%;
  transition: var(--transition);
}

.payment-method.active i {
  background-color: var(--primary-color);
  color: var(--light-color);
}

.method-info {
  flex: 1;
}

.method-name {
  font-weight: 600;
  color: var(--secondary-color);
  margin-bottom: 5px;
}

.method-description {
  font-size: 0.9rem;
  color: var(--gray-medium);
}

/* FILE UPLOAD */
.file-upload {
  position: relative;
  margin: 25px 0;
}

.file-upload-label {
  display: block;
  padding: 30px;
  border: 2px dashed #d1d9e6;
  border-radius: 10px;
  text-align: center;
  cursor: pointer;
  transition: var(--transition);
  background-color: #f9f9f9;
}

.file-upload-label:hover {
  border-color: var(--primary-color);
  background-color: rgba(39, 174, 96, 0.05);
}

.file-upload-icon {
  font-size: 2.5rem;
  color: var(--primary-color);
  margin-bottom: 15px;
}

.file-upload-text {
  font-size: 1.1rem;
  color: var(--secondary-color);
  margin-bottom: 10px;
}

.file-upload-input {
  position: absolute;
  left: 0;
  top: 0;
  opacity: 0;
  width: 100%;
  height: 100%;
  cursor: pointer;
}

.file-name {
  margin-top: 15px;
  font-size: 0.9rem;
  color: var(--gray-dark);
  word-break: break-all;
}

.file-preview {
  max-width: 100%;
  max-height: 200px;
  margin-top: 15px;
  border-radius: 8px;
  display: none;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
}

/* BUTTON STYLES */
.btn {
  padding: 16px 30px;
  border-radius: 10px;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  border: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  font-size: 1.1rem;
  width: 100%;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.btn-primary {
  background: linear-gradient(to right, var(--primary-color), var(--primary-dark));
  color: var(--light-color);
  box-shadow: 0 4px 15px rgba(39, 174, 96, 0.3);
}

.btn-primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(39, 174, 96, 0.4);
  background: linear-gradient(to right, var(--primary-dark), var(--primary-color));
}

.btn-primary i {
  font-size: 1.3rem;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 20%, 50%, 80%, 100% {transform: translateY(0);}
  40% {transform: translateY(-10px);}
  60% {transform: translateY(-5px);}
}

/* ALERT STYLES */
.alert {
  padding: 18px 20px;
  border-radius: 10px;
  margin-bottom: 25px;
  display: flex;
  align-items: center;
  gap: 15px;
  position: relative;
  overflow: hidden;
}

.alert::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  width: 5px;
  height: 100%;
}

.alert-success {
  background-color: rgba(39, 174, 96, 0.1);
  color: var(--success-color);
}

.alert-success::before {
  background-color: var(--success-color);
}

.alert-error {
  background-color: rgba(231, 76, 60, 0.1);
  color: var(--error-color);
}

.alert-error::before {
  background-color: var(--error-color);
}

.alert i {
  font-size: 1.5rem;
}

/* ANIMATIONS */
@keyframes float {
  0% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
  100% { transform: translateY(0px); }
}

.floating {
  animation: float 3s ease-in-out infinite;
}

/* RESPONSIVE STYLES */
@media (max-width: 992px) {
  .sidebar {
    width: 250px;
    transform: translateX(-250px);
  }
  
  .sidebar.active {
    transform: translateX(0);
  }
  
  .content {
    margin-left: 0;
    width: 100%;
  }
  
  .payment-method {
    padding: 15px;
  }
}

@media (max-width: 768px) {
  .content {
    padding: 25px;
  }
  
  .page-title {
    font-size: 1.6rem;
  }
  
  .card-header {
    padding: 15px 20px;
  }
  
  .card-title {
    font-size: 1.2rem;
  }
  
  .payment-amount {
    font-size: 2rem;
  }
}

@media (max-width: 576px) {
  .content {
    padding: 20px 15px;
  }
  
  .payment-method {
    flex-direction: column;
    text-align: center;
  }
  
  .payment-method i {
    margin-right: 0;
    margin-bottom: 15px;
  }
  
  .btn {
    padding: 14px 20px;
    font-size: 1rem;
  }
}

/* SPECIAL EFFECTS */
.glow-text {
  text-shadow: 0 0 10px rgba(39, 174, 96, 0.5);
}

.hover-grow {
  transition: var(--transition);
}

.hover-grow:hover {
  transform: scale(1.05);
}

/* DECORATIVE ELEMENTS */
.decorative-circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(39, 174, 96, 0.1);
  z-index: -1;
}

.circle-1 {
  width: 300px;
  height: 300px;
  top: -150px;
  right: -150px;
}

.circle-2 {
  width: 200px;
  height: 200px;
  bottom: -100px;
  left: -100px;
  background: rgba(243, 156, 18, 0.1);
}

/* LOADING ANIMATION */
.loading-spinner {
  display: inline-block;
  width: 20px;
  height: 20px;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  border-top-color: var(--light-color);
  animation: spin 1s ease-in-out infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}
    </style>
</head>
<body>
    <%@ include file="sidebars.jsp" %>

    <div class="content">
        <h2><i class="fas fa-credit-card"></i> Paiement de la souscription</h2>
        
        <%-- Affichage des messages --%>
        <% if (session.getAttribute("successMessage") != null) { %>
            <div class="alert alert-success">
                <i class="fas fa-check-circle"></i> <%= session.getAttribute("successMessage") %>
            </div>
            <% session.removeAttribute("successMessage"); %>
        <% } %>
        
        <% if (session.getAttribute("errorMessage") != null) { %>
            <div class="alert alert-error">
                <i class="fas fa-exclamation-circle"></i> <%= session.getAttribute("errorMessage") %>
            </div>
            <% session.removeAttribute("errorMessage"); %>
        <% } %>
        
        <div class="payment-container">
            <div class="payment-header">
                <h3><i class="fas fa-hand-holding-usd"></i> Frais de souscription</h3>
                <div class="payment-amount"><%= String.format("%,d", SOUSCRIPTION_AMOUNT.intValue()) %> FCFA</div>
                <p>Ce paiement vous permet de souscrire aux tontines disponibles</p>
                <p>Montant minimum requis pour la souscription : <strong><%= String.format("%,d", SOUSCRIPTION_AMOUNT.intValue()) %> FCFA</strong></p>
            </div>
            
            <form action="ImageServlet2" method="post" enctype="multipart/form-data">
                <div class="form-group">
                    <label for="montant"><i class="fas fa-money-bill-wave"></i> Montant payé (FCFA)</label>
                    <input type="number" id="montant" name="montant" class="form-control" 
                           min="<%= SOUSCRIPTION_AMOUNT %>" step="500" 
                           value="<%= SOUSCRIPTION_AMOUNT %>" required>
                </div>
                
                <div class="payment-methods">
                    <h4><i class="fas fa-wallet"></i> Méthode de paiement</h4>
                    
                    <div class="payment-method active" onclick="selectMethod('mobile_money')">
                        <i class="fas fa-mobile-alt"></i>
                        <div>
                            <div class="method-name">Mobile Money</div>
                            <div class="method-info">ORANGEMoney,MTNMONEY</div>
                        </div>
                    </div>
                    
                    <div class="payment-method" onclick="selectMethod('bank_transfer')">
                        <i class="fas fa-university"></i>
                        <div>
                            <div class="method-name">BANQUE</div>
                            <div class="method-info">Transfert direct depuis votre banque</div>
                        </div>
                    </div>
                    
                    <div class="payment-method" onclick="selectMethod('cash')">
                        <i class="fas fa-money-bill-wave"></i>
                        <div>
                            <div class="method-name">CASH</div>
                            <div class="method-info">Paiement en main propre</div>
                        </div>
                    </div>
                    
                    <input type="hidden" id="payment_method" name="payment_method" value="mobile_money">
                </div>
                
                <div class="form-group">
                    <label for="reference"><i class="fas fa-receipt"></i> Référence du paiement</label>
                    <input type="text" id="reference" name="reference" class="form-control" 
                           placeholder="Numéro de transaction, référence, etc." required>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-file-upload"></i> Preuve de souscription (Optionnel)</label>
                    <div class="file-upload">
                        <label class="file-upload-label">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <div>Cliquez pour télécharger la preuve</div>
                            <div class="file-name" id="file-name">Aucun fichier sélectionné</div>
                            <img id="file-preview" class="file-upload-preview" src="#" alt="Aperçu">
                        </label>
                        <input type="file" id="preuve" name="preuve" class="file-upload-input" accept="image/*,.pdf">
                    </div>
                    <small>Vous pouvez uploader une capture d'écran ou scan du reçu (JPEG, PNG ou PDF)</small>
                </div>
                
                <button type="submit" class="btn btn-success">
                    <i class="fas fa-check-circle"></i> Valider le paiement
                </button>
            </form>
        </div>
    </div>

    <script>
        // Sélection de la méthode de paiement
        function selectMethod(method) {
            document.querySelectorAll('.payment-method').forEach(el => {
                el.classList.remove('active');
            });
            event.currentTarget.classList.add('active');
            document.getElementById('payment_method').value = method;
        }
        
     // Affichage du nom du fichier sélectionné et aperçu pour les images
        const fileInput = document.getElementById('preuve');
        if (fileInput) {
            fileInput.addEventListener('change', function(e) {
                const fileNameElement = document.getElementById('file-name');
                const previewElement = document.getElementById('file-preview');
                const fileUploadDiv = this.closest('.file-upload');
                
                if (this.files && this.files[0]) {
                    const fileName = this.files[0].name;
                    fileNameElement.textContent = fileName;
                    
                    // Changer la couleur de la bordure
                    if (fileUploadDiv) {
                        fileUploadDiv.style.borderColor = '#27ae60';
                    }
                    
                    // Afficher un aperçu pour les images
                    if (this.files[0].type.startsWith('image/')) {
                        const reader = new FileReader();
                        
                        reader.onload = function(e) {
                            previewElement.src = e.target.result;
                            previewElement.style.display = 'block';
                        }
                        
                        reader.readAsDataURL(this.files[0]);
                    } else {
                        previewElement.style.display = 'none';
                    }
                } else {
                    fileNameElement.textContent = 'Aucun fichier sélectionné';
                    previewElement.style.display = 'none';
                    
                    // Réinitialiser la couleur de la bordure
                    if (fileUploadDiv) {
                        fileUploadDiv.style.borderColor = '#ddd';
                    }
                }
            });
        }
        // Confirmation avant paiement
        document.querySelector('form').addEventListener('submit', function(e) {
            if (!confirm('Confirmez-vous ce paiement de ' + document.getElementById('montant').value + ' FCFA ?')) {
                e.preventDefault();
            }
        });
    </script>
</body>
</html>