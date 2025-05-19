<%@page import="java.util.List"%>
<%@page import="models.Discussion"%>
<%@page import="models.Messages"%>
<%@page import="models.Message"%>
<%@page import="models.Member"%>
<%@page import="models.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Espace Discussion Membre</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        /* Variables CSS */
        :root {
            --primary-color: #4a6baf;
            --primary-light: #6d8bd6;
            --primary-dark: #2a4a8a;
            --secondary-color: #ffffff;
            --accent-color: #6a9bd4;
            --text-dark: #333333;
            --text-light: #f5f5f5;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
        }

        /* Reset et styles de base */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: #f9f9f9;
            color: var(--text-dark);
            overflow-x: hidden;
        }

        /* Conteneur principal */
        .member-container {
            display: flex;
            min-height: 100vh;
        }

        /* Barre latérale */
        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: var(--secondary-color);
            padding: 20px 0;
            transition: all 0.3s ease;
            box-shadow: var(--shadow);
            z-index: 10;
        }

        .sidebar-header {
            display: flex;
            align-items: center;
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header img {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            object-fit: cover;
            border: 2px solid var(--accent-color);
        }

        .sidebar-header h3 {
            font-size: 18px;
            font-weight: 600;
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            margin: 5px 0;
            cursor: pointer;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .menu-item:hover, .menu-item.active {
            background-color: rgba(255, 255, 255, 0.1);
            border-left: 3px solid var(--accent-color);
        }

        .menu-item i {
            margin-right: 15px;
            font-size: 18px;
        }

        /* Contenu principal */
        .main-content {
            flex: 1;
            padding: 20px;
            background-color: var(--secondary-color);
            transition: all 0.3s ease;
        }

        /* En-tête */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }

        .header h1 {
            color: var(--primary-color);
            font-size: 28px;
            font-weight: 600;
        }

        .user-info {
            display: flex;
            align-items: center;
        }

        .user-info img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }

        .notification-bell {
            position: relative;
            margin-right: 20px;
            cursor: pointer;
        }

        .notification-bell i {
            font-size: 20px;
            color: var(--primary-color);
        }

        .notification-count {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: #ff5252;
            color: white;
            border-radius: 50%;
            width: 18px;
            height: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: bold;
        }

        /* Conteneur de discussion */
        .discussion-container {
            display: flex;
            height: calc(100vh - 150px);
            background-color: var(--secondary-color);
            border-radius: 10px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        /* Liste des discussions */
        .discussions-list {
            width: 300px;
            border-right: 1px solid #eee;
            overflow-y: auto;
            background-color: #f5f5f5;
        }

        .discussions-list-header {
            padding: 15px;
            background-color: var(--primary-color);
            color: white;
            font-weight: 600;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .search-bar {
            padding: 10px;
            background-color: #f5f5f5;
            border-bottom: 1px solid #eee;
        }

        .search-bar input {
            width: 100%;
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 20px;
            outline: none;
            font-size: 14px;
        }

        .discussion-category {
            padding: 10px 15px;
            font-weight: 600;
            color: var(--primary-color);
            background-color: #e8f5e9;
            border-bottom: 1px solid #eee;
        }

        .discussion-item {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 1px solid #eee;
        }

        .discussion-item:hover {
            background-color: #e8f5e9;
        }

        .discussion-item.active {
            background-color: #c8e6c9;
        }

        .discussion-item img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }

        .discussion-info-small {
            flex: 1;
        }

        .discussion-info-small h4 {
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 3px;
        }

        .discussion-info-small p {
            font-size: 12px;
            color: #666;
        }

        .discussion-status {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background-color: #4caf50;
        }

        .discussion-status.offline {
            background-color: #9e9e9e;
        }

        /* Zone de chat */
        .chat-area {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .chat-header {
            padding: 15px;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            align-items: center;
            border-bottom: 1px solid #eee;
        }

        .chat-header img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }

        .chat-header-info {
            flex: 1;
        }

        .chat-header-info h3 {
            font-size: 16px;
            font-weight: 600;
        }

        .chat-header-info p {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.8);
        }

        .chat-header-actions i {
            margin-left: 15px;
            cursor: pointer;
            font-size: 18px;
        }

        .messages-container {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background-color: #f5f5f5;
        }

        .message {
            display: flex;
            margin-bottom: 15px;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.received {
            justify-content: flex-start;
        }

        .message.sent {
            justify-content: flex-end;
        }

        .message-avatar {
            margin-right: 10px;
        }

        .message-avatar img {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
        }

        .message-content {
            max-width: 60%;
        }

        .message.received .message-content {
            background-color: white;
            color: var(--text-dark);
            border-radius: 0 15px 15px 15px;
            padding: 10px 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .message.sent .message-content {
            background-color: var(--primary-light);
            color: white;
            border-radius: 15px 0 15px 15px;
            padding: 10px 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .message-info {
            display: flex;
            justify-content: space-between;
            margin-top: 5px;
            font-size: 11px;
            color: #999;
        }

        .message.sent .message-info {
            color: rgba(255, 255, 255, 0.7);
        }

        .message-time {
            margin-left: 10px;
        }

        .message-attachment {
            margin-top: 10px;
            border-radius: 10px;
            overflow: hidden;
        }

        .message-attachment img {
            max-width: 100%;
            max-height: 200px;
            border-radius: 10px;
        }

        .chat-input {
            display: flex;
            padding: 15px;
            background-color: white;
            border-top: 1px solid #eee;
        }

        .chat-input input {
            flex: 1;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 30px;
            outline: none;
            font-size: 14px;
            margin-right: 10px;
        }

        .chat-input button {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background-color: var(--primary-color);
            color: white;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .chat-input button:hover {
            background-color: var(--primary-dark);
            transform: scale(1.05);
        }

        .chat-input button i {
            font-size: 18px;
        }

        /* Aucune discussion sélectionnée */
        .no-discussion-selected {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            text-align: center;
        }

        .no-discussion-selected h3 {
            margin-bottom: 10px;
            color: var(--primary-color);
        }

        /* Styles responsives */
        @media (max-width: 1200px) {
            .info-panel {
                display: none;
            }
        }

        @media (max-width: 992px) {
            .sidebar {
                width: 80px;
                overflow: hidden;
            }
            .sidebar-header h3, .menu-item span {
                display: none;
            }
            .menu-item {
                justify-content: center;
            }
            .menu-item i {
                margin-right: 0;
            }
        }

        @media (max-width: 768px) {
            .discussions-list {
                width: 250px;
            }
        }

        @media (max-width: 576px) {
            .member-container {
                flex-direction: column;
            }
            .sidebar {
                width: 100%;
                height: 60px;
                display: flex;
                align-items: center;
                padding: 0 15px;
            }
            .sidebar-header {
                padding: 0;
                border-bottom: none;
            }
            .sidebar-menu {
                display: flex;
                padding: 0;
                margin-left: auto;
            }
            .menu-item {
                padding: 0 15px;
                border-left: none;
                border-bottom: 3px solid transparent;
            }
            .menu-item:hover, .menu-item.active {
                border-left: none;
                border-bottom: 3px solid var(--accent-color);
            }
            .main-content {
                padding: 15px;
            }
            .discussion-container {
                flex-direction: column;
                height: auto;
            }
            .discussions-list {
                width: 100%;
                height: 300px;
                border-right: none;
                border-bottom: 1px solid #eee;
            }
            .chat-area {
                height: 400px;
            }
        }
    </style>
</head>
<body>
    <div class="member-container">
        <!-- Barre latérale -->
        <div class="sidebar">
            <div class="sidebar-header">
                <img src="<%= ((User)session.getAttribute("currentUser")).getAvatar() %>" alt="Membre Avatar">
                <h3><%= ((User)session.getAttribute("currentUser")).getFullName() %></h3>
            </div>
            <div class="sidebar-menu">
                <div class="menu-item active">
                    <i class="fas fa-comments"></i>
                    <span>Discussion</span>
                </div>
                <div class="menu-item">
                    <i class="fas fa-user-friends"></i>
                    <span>Profil</span>
                </div>
                <div class="menu-item">
                    <i class="fas fa-hand-holding-usd"></i>
                    <span>Mes Tontines</span>
                </div>
                <div class="menu-item">
                    <i class="fas fa-money-bill-wave"></i>
                    <span>Mes Paiements</span>
                </div>
                <div class="menu-item">
                    <i class="fas fa-shield-alt"></i>
                    <span>Mes Assurances</span>
                </div>
                <div class="menu-item">
                    <i class="fas fa-cog"></i>
                    <span>Paramètres</span>
                </div>
            </div>
        </div>

        <!-- Contenu principal -->
        <div class="main-content">
            <div class="header">
                <h1><i class="fas fa-comments"></i> Messagerie</h1>
                <div class="user-info">
                    <div class="notification-bell">
                        <i class="fas fa-bell"></i>
                        <span class="notification-count"><%= Discussion.getMemberUnreadCount(((User)session.getAttribute("currentUser")).getId()) %></span>
                    </div>
                    <img src="<%= ((User)session.getAttribute("currentUser")).getAvatar() %>" alt="User Avatar">
                    <span><%= ((User)session.getAttribute("currentUser")).getFullName() %></span>
                </div>
            </div>

            <div class="discussion-container">
                <!-- Liste des discussions -->
                <div class="discussions-list">
                    <div class="discussions-list-header">
                        <span>Conversations</span>
                        <i class="fas fa-ellipsis-v"></i>
                    </div>
                    <div class="search-bar">
                        <input type="text" placeholder="Rechercher une conversation...">
                    </div>
                    
                    <div class="discussion-category"> 
                        <i class="fas fa-circle"></i> Actives (<%= Discussion.getMemberActiveDiscussions(((User)session.getAttribute("currentUser")).getId()).size() %>)
                    </div>
                    
                    <% List<Discussion> activeDiscussions = Discussion.getMemberActiveDiscussions(((User)session.getAttribute("currentUser")).getId()); %>
                    <% for(Discussion discussion : activeDiscussions) { %>
                    <div class="discussion-item <%= discussion.getId() == Integer.parseInt(request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "0") ? "active" : "" %>" 
                         data-discussion-id="<%= discussion.getId() %>">
                        <img src="<%= discussion.getAvatar() %>" alt="<%= discussion.getTitle() %>">
                        <div class="discussion-info-small">
                            <h4><%= discussion.getTitle() %></h4>
                            <p>Dernier message: <%= discussion.getLastMessageTime() %></p>
                        </div>
                        <% if(discussion.getUnreadCount() > 0) { %>
                        <div class="discussion-status"></div>
                        <% } %>
                    </div>
                    <% } %>
                    
                    <div class="discussion-category"> 
                        <i class="fas fa-circle"></i> Archivées (<%= Discussion.getMemberArchivedDiscussions(((User)session.getAttribute("currentUser")).getId()).size() %>)
                    </div>
                    
                    <% List<Discussion> archivedDiscussions = Discussion.getMemberArchivedDiscussions(((User)session.getAttribute("currentUser")).getId()); %>
                    <% for(Discussion discussion : archivedDiscussions) { %>
                    <div class="discussion-item">
                        <img src="<%= discussion.getAvatar() %>" alt="<%= discussion.getTitle() %>">
                        <div class="discussion-info-small">
                            <h4><%= discussion.getTitle() %></h4>
                            <p>Dernier message: <%= discussion.getLastMessageTime() %></p>
                        </div>
                        <div class="discussion-status offline"></div>
                    </div>
                    <% } %>
                </div>

                <!-- Zone de chat -->
                <div class="chat-area">
                    <% if(request.getParameter("discussion_id") != null) { 
                        Discussion currentDiscussion = Discussion.getById(Integer.parseInt(request.getParameter("discussion_id"))); %>
                    <div class="chat-header">
                        <img src="<%= currentDiscussion.getAvatar() %>" alt="Admin Avatar">
                        <div class="chat-header-info">
                            <h3><%= currentDiscussion.getTitle() %></h3>
                            <p>En ligne</p>
                        </div>
                        <div class="chat-header-actions">
                            <i class="fas fa-info-circle"></i>
                        </div>
                    </div>
                    
                    <div class="messages-container">
                        <% List<Message> messages = Messages.getByDiscussion(currentDiscussion.getId()); %>
                        <% for(Message message : messages) { %>
                        <div class="message <%= message.getSenderType().equals("member") && message.getSenderId() == ((User)session.getAttribute("currentUser")).getId() ? "sent" : "received" %>">
                            <% if(!message.getSenderType().equals("member") || message.getSenderId() != ((User)session.getAttribute("currentUser")).getId()) { %>
                            <div class="message-avatar">
                                <img src="<%= message.getSenderAvatar() %>" alt="Sender">
                            </div>
                            <% } %>
                            <div class="message-content">
                                <p><%= message.getContent() %></p>
                                <div class="message-info">
                                    <span><%= message.getSenderName() %></span>
                                    <span class="message-time"><%= message.getFormattedTime() %></span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="chat-input">
                        <input type="text" id="message-input" placeholder="Écrire un message...">
                        <button type="button" id="send-button"><i class="fas fa-paper-plane"></i></button>
                    </div>
                    <% } else { %>
                    <div class="no-discussion-selected">
                        <i class="fas fa-comments" style="font-size: 50px; color: #ccc; margin-bottom: 20px;"></i>
                        <h3>Sélectionnez une conversation</h3>
                        <p>Choisissez une conversation existante ou créez-en une nouvelle</p>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
    $(document).ready(function() {
        // Sélection d'une discussion
        $('.discussion-item').click(function() {
            const discussionId = $(this).data('discussion-id');
            window.location.href = 'member_discussion.jsp?discussion_id=' + discussionId;
        });
        
        // Envoi de message
        $('#send-button').click(sendMessage);
        $('#message-input').keypress(function(e) {
            if(e.which === 13) {
                sendMessage();
            }
        });
        
        function sendMessage() {
            const input = $('#message-input');
            const message = input.val().trim();
            const discussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
            
            if(message && discussionId) {
                $.post('SendMessageServlet', {
                    discussion_id: discussionId,
                    content: message,
                    sender_type: 'member',
                    sender_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                }, function(response) {
                    if(response.success) {
                        const time = new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                        
                        var newMessage = '<div class="message sent">' +
                            '<div class="message-content">' +
                            '<p>' + message + '</p>' +
                            '<div class="message-info">' +
                            '<span>Vous</span>' +
                            '<span class="message-time">' + time + '</span>' +
                            '</div>' +
                            '</div>' +
                            '</div>';
                        
                        $('.messages-container').append(newMessage);
                        
                        input.val('');
                        scrollToBottom();
                        updateLastMessageInList(discussionId, message, time);
                    } else {
                        alert("Erreur lors de l'envoi du message: " + (response.error || "Erreur inconnue"));
                    }
                }).fail(function() {
                    alert("Erreur de connexion au serveur");
                });
            }
        }
        
        function updateLastMessageInList(discussionId, message, time) {
            $('.discussion-item[data-discussion-id="' + discussionId + '"] .discussion-info-small p')
                .text('Dernier message: ' + time);
        }
        
        function scrollToBottom() {
            const container = $('.messages-container');
            container.scrollTop(container[0].scrollHeight);
        }
        
        // Fonction pour créer le HTML d'un message
        function createMessageHtml(message, isSent) {
            var html = '<div class="message ' + (isSent ? 'sent' : 'received') + '">';
            
            if(!isSent) {
                html += '<div class="message-avatar">' +
                       '<img src="' + message.sender_avatar + '" alt="Sender">' +
                       '</div>';
            }
            
            html += '<div class="message-content">' +
                   '<p>' + message.content + '</p>' +
                   '<div class="message-info">' +
                   '<span>' + message.sender_name + '</span>' +
                   '<span class="message-time">' + message.formatted_time + '</span>' +
                   '</div>' +
                   '</div>' +
                   '</div>';
            
            return html;
        }
        
        // Actualisation périodique des messages
        setInterval(function() {
            const discussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
            if(discussionId) {
                $.get('GetNewMessagesServlet', {
                    discussion_id: discussionId,
                    last_message_id: getLastMessageId(),
                    user_type: 'member',
                    user_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                }, function(response) {
                    if(response.messages && response.messages.length > 0) {
                        response.messages.forEach(function(message) {
                            const isSent = message.sender_type === 'member' && message.sender_id === <%= ((User)session.getAttribute("currentUser")).getId() %>;
                            $('.messages-container').append(createMessageHtml(message, isSent));
                        });
                        scrollToBottom();
                        
                        // Marquer les messages comme lus
                        if(response.messages.length > 0) {
                            markMessagesAsRead(discussionId);
                        }
                    }
                });
            }
        }, 3000); // Actualisation toutes les 3 secondes
        
        function getLastMessageId() {
            const lastMessage = $('.message').last();
            return lastMessage.length ? (lastMessage.data('message-id') || 0) : 0;
        }
        
        // Marquer les messages comme lus
        function markMessagesAsRead(discussionId) {
            if(discussionId) {
                $.post('MarkMessagesAsReadServlet', {
                    discussion_id: discussionId,
                    user_type: 'member',
                    user_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                });
                $('.discussion-item[data-discussion-id="' + discussionId + '"] .discussion-status')
                    .removeClass('unread').addClass('read');
            }
        }
        
        // Marquer les messages comme lus au chargement
        const currentDiscussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
        if(currentDiscussionId) {
            markMessagesAsRead(currentDiscussionId);
        }
    });
    </script>
</body>
</html>