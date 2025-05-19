<%@ page import="jakarta.servlet.http.HttpSession" %>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<div class="sidebar">
    <h2><i class="fas fa-users"></i> GO-FAR Utilisateur</h2>
    <a href="admin.jsp"><i class="fas fa-home"></i> ACCUEIL</a>
    <a href="adherentmember.jsp"><i class="fas fa-user-friends"></i> LES MEMBRES</a>
    
    <div class="dropdown">
        <a href="#" class="dropdown-toggle"><i class="fas fa-hand-holding-usd"></i> TONTINES <i class="fas fa-chevron-down"></i></a>
        <div class="dropdown-content">
            <a href="payementsouscription.jsp"><i class="fas fa-money-bill-wave"></i> Payé les frais de tontine</a>
            <a href="cotisation.jsp"><i class="fas fa-coins"></i> Cotisations</a>
            <a href="souscription.jsp"><i class="fas fa-list"></i> Liste des tontines</a>
        </div>
    </div>
    
    <a href="infopersonnelle.jsp"><i class="fas fa-user-circle"></i> INFORMATION PERSONNELLE</a>
    <a href="declarerSinistre.jsp"><i class="fas fa-user-circle"></i> Assurance</a>
    <a href="member_discussion.jsp"><i class="fas fa-user-circle"></i>DISCUTIONS INFO</a>
    <a href="rapport.jsp"><i class="fas fa-chart-bar"></i> RAPPORTS</a>
    <a href="propos.jsp"><i class="fas fa-info-circle"></i> A PROPOS</a>	
    <a href="LogoutServlet"><i class="fas fa-sign-out-alt"></i> Deconnexion</a>
</div>

<style>
.sidebar {
    width: 260px;
    background: rgba(44, 62, 80, 0.9);
    color: white;
    padding: 20px;
    display: flex;
    flex-direction: column;
    align-items: center;
    height: 100vh;
    position: fixed;
    left: 0;
    top: 0;
    z-index: 1000;
}

.sidebar h2 {
    text-align: center;
    margin-bottom: 20px;
    margin-left: -60px;
    font-size: 22px;
    color: #1abc9c;
    width: 100%;
}

.sidebar a {
    text-decoration: none;
    color: white;
    padding: 12px;
    width: 100%;
    text-align: left;
    display: block;
    margin: 8px 0;
    background: #34495e;
    border-radius: 5px;
    font-size: 16px;
    transition: all 0.3s ease;
    box-sizing: border-box;
}

.sidebar a:hover {
    background: #1abc9c;
    transform: translateX(5px);
}

.sidebar a i {
    margin-right: 10px;
    width: 20px;
    text-align: center;
}

/* Dropdown styles */
.dropdown {
    width: 100%;
    position: relative;
}

.dropdown-toggle {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.dropdown-content {
    display: none;
    margin-left: 15px;
    width: calc(100% - 15px);
    background: rgba(52, 73, 94, 0.8);
    border-radius: 5px;
    overflow: hidden;
    transition: all 0.3s ease;
}

.dropdown:hover .dropdown-content {
    display: block;
}

.dropdown-content a {
    background: transparent;
    margin: 4px 0;
    padding: 10px 15px;
    font-size: 14px;
}

.dropdown-content a:hover {
    background: #1abc9c;
}
</style>

<script>
// JavaScript for better dropdown functionality
document.addEventListener('DOMContentLoaded', function() {
    const dropdowns = document.querySelectorAll('.dropdown');
    
    dropdowns.forEach(dropdown => {
        const toggle = dropdown.querySelector('.dropdown-toggle');
        
        toggle.addEventListener('click', function(e) {
            e.preventDefault();
            const content = this.nextElementSibling;
            
            // Close all other dropdowns
            document.querySelectorAll('.dropdown-content').forEach(item => {
                if (item !== content) item.style.display = 'none';
            });
            
            // Toggle current dropdown
            if (content.style.display === 'block') {
                content.style.display = 'none';
            } else {
                content.style.display = 'block';
            }
        });
    });
    
    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.dropdown')) {
            document.querySelectorAll('.dropdown-content').forEach(item => {
                item.style.display = 'none';
            });
        }
    });
});
</script>