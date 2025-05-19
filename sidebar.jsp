<%@ page import="jakarta.servlet.http.HttpSession" %>
<div class="sidebar">
    <h2>Tontine GO-FAR</h2>
 <a href="welcome.jsp" class="active"><i class="fas fa-home"></i> <span>ACCUEIL</span></a>
            <a href="adherents.jsp"><i class="fas fa-users"></i> <span>ADHERENTS</span></a>
            <a href="tontine.jsp"><i class="fas fa-piggy-bank"></i> <span>TONTINE</span></a>
            <a href="syntheseTontine.jsp"><i class="fas fa-chart-pie"></i> <span>SYNTHESE TONTINE</span></a>
            <a href="assurance.jsp"><i class="fas fa-shield-alt"></i> <span>ASSURANCE</span></a>
            <a href="messages.jsp"><i class="fas fa-envelope"></i> <span>MESSAGES</span></a>
             <a href="admin_discussion.jsp"><i class="fas fa-gavel"></i> <span>DISCUTION INFO</span></a>
            <a href="payecotisation.jsp"><i class="fas fa-graduation-cap"></i> <span>paye cotisation</span></a>
            <a href="caisse.jsp"><i class="fas fa-book"></i> <span>CAISSE</span></a>
            <a href="LogoutServlet" class="logout-btn"><i class="fas fa-sign-out-alt"></i> <span>DECONNEXION</span></a>
</div>

<style>
.sidebar {
    width: 20%;
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
}
   :root {
            --primary-color: #2ecc71;
            --primary-dark: #27ae60;
            --primary-light: #d5f5e3;
            --secondary-color: #34495e;
            --accent-color: #f1c40f;
            --light-color: #ffffff;
            --light-gray: #f5f5f5;
            --dark-gray: #95a5a6;
            --shadow: 0 10px 20px rgba(0,0,0,0.1);
            --transition: all 0.3s ease;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--light-gray);
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--secondary-color), #2c3e50);
            color: var(--light-color);
            padding: 30px 20px;
            display: flex;
            flex-direction: column;
            box-shadow: var(--shadow);
            z-index: 10;
            position: relative;
            transition: var(--transition);
        }
        
        .sidebar h2 {
            text-align: center;
            margin-bottom: 30px;
            font-size: 24px;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: center;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .sidebar h2 i {
            margin-right: 10px;
            color: var(--primary-color);
        }
        
        .sidebar-nav {
            flex: 1;
            display: flex;
            flex-direction: column;
        }
        
        .sidebar a {
            text-decoration: none;
            color: var(--light-color);
            padding: 15px 20px;
            margin: 5px 0;
            border-radius: 8px;
            font-size: 16px;
            display: flex;
            align-items: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .sidebar a i {
            width: 25px;
            font-size: 18px;
            margin-right: 15px;
            text-align: center;
        }
        
        .sidebar a:hover {
            background: rgba(255,255,255,0.1);
            transform: translateX(5px);
        }
        
        .sidebar a:hover::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 4px;
            background: var(--primary-color);
        }
        
        .sidebar a.active {
            background: var(--primary-color);
            font-weight: 500;
        }
        
        .logout-btn {
            margin-top: auto;
            background: rgba(231, 76, 60, 0.8);
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .logout-btn:hover {
            background: rgba(231, 76, 60, 1);
        }
        
        /* Main Content Styles */
        .content {
            flex: 1;
            padding: 40px;
            margin-left:-30px;
            overflow-y: auto;
            background-color: var(--light-gray);
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: var(--secondary-color);
            font-size: 28px;
            font-weight: 600;
        }
        
        .user-profile {
            display: flex;
            align-items: center;
            background: var(--light-color);
            padding: 10px 15px;
            border-radius: 30px;
            box-shadow: var(--shadow);
            cursor: pointer;
        }
        
        .user-profile img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }
        
        .user-profile span {
            font-weight: 500;
            color: var(--secondary-color);
        }
        
        /* Stats Cards */
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .stat-box {
            background: var(--light-color);
            padding: 25px;
            border-radius: 12px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }
        
        .stat-box:hover {
            transform: translateY(-5px);
        }
        
        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            background: var(--primary-light);
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 20px;
            color: var(--primary-dark);
            font-size: 24px;
        }
        
        .stat-info h3 {
            font-size: 14px;
            color: var(--dark-gray);
            font-weight: 500;
            margin-bottom: 5px;
        }
        
        .stat-info h2 {
            font-size: 28px;
            color: var(--secondary-color);
            font-weight: 600;
        }
        
        /* Table Styles */
        .table-container {
            background: var(--light-color);
            border-radius: 12px;
            box-shadow: var(--shadow);
            padding: 25px;
            margin-top: 30px;
        }
        
        .table-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .table-header h2 {
            color: var(--secondary-color);
            font-size: 22px;
            font-weight: 600;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            background: var(--primary-light);
            color: var(--secondary-color);
            font-weight: 600;
            padding: 15px;
            text-align: left;
            border-bottom: 2px solid var(--primary-color);
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #eee;
            color: var(--secondary-color);
        }
        
        tr:hover td {
            background: var(--primary-light);
        }
        
        .validate-btn {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 6px;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 500;
            display: inline-flex;
            align-items: center;
        }
        
        .validate-btn i {
            margin-right: 5px;
        }
        
        .validate-btn:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 5px 10px rgba(46, 204, 113, 0.3);
        }
        
        .empty-state {
            text-align: center;
            padding: 50px 0;
            color: var(--dark-gray);
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 20px;
            color: var(--primary-light);
        }
        
        /* Responsive Adjustments */
        @media (max-width: 992px) {
            .sidebar {
                width: 80px;
                padding: 20px 10px;
            }
            
            .sidebar h2 span, .sidebar a span {
                display: none;
            }
            
            .sidebar a {
                justify-content: center;
                padding: 15px 5px;
            }
            
            .sidebar a i {
                margin-right: 0;
                font-size: 20px;
            }
        }
        
        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }
            
            .stats-container {
                grid-template-columns: 1fr;
            }
        }

.sidebar h2 {
    text-align: center;
    margin-bottom: 20px;
    font-size: 22px;
    color: #1abc9c;
}

.sidebar a {
    text-decoration: none;
    color: white;
    padding: 12px;
    width: 100%;
    text-align: center;
    display: block;
    margin: 8px 0;
    background: #34495e;
    border-radius: 5px;
    font-size: 16px;
    transition: all 0.3s ease;
}

.sidebar a:hover {
    background: #1abc9c;
    transform: translateX(5px);
}

.sidebar a i {
    margin-right: 8px;
}
</style>