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
    <title>Messagerie - Espace Membre</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-light: #4895ef;
            --primary-dark: #3a0ca3;
            --secondary-color: #ffffff;
            --accent-color: #4cc9f0;
            --text-dark: #2b2d42;
            --text-light: #f8f9fa;
            --success-color: #4caf50;
            --warning-color: #ff9800;
            --error-color: #f44336;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            --border-radius: 8px;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: #f5f7fa;
            color: var(--text-dark);
        }

        /* Layout principal */
        .member-app {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar */
        .member-sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
            color: var(--secondary-color);
            padding: 20px 0;
            box-shadow: var(--shadow);
            position: relative;
            z-index: 10;
        }

        .member-profile {
            display: flex;
            align-items: center;
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }

        .member-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            object-fit: cover;
            border: 2px solid var(--accent-color);
        }

        .member-name {
            font-size: 16px;
            font-weight: 600;
        }

        .member-status {
            font-size: 12px;
            color: var(--accent-color);
            display: flex;
            align-items: center;
        }

        .member-status::before {
            content: "";
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--accent-color);
            margin-right: 6px;
        }

        .nav-menu {
            padding: 0 10px;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 12px 15px;
            margin: 5px 0;
            border-radius: var(--border-radius);
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .nav-item:hover, .nav-item.active {
            background-color: rgba(255, 255, 255, 0.1);
        }

        .nav-item i {
            width: 24px;
            text-align: center;
            margin-right: 12px;
            font-size: 18px;
        }

        /* Contenu principal */
        .member-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        /* Header */
        .member-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 15px 25px;
            background-color: var(--secondary-color);
            box-shadow: var(--shadow);
            z-index: 5;
        }

        .page-title {
            color: var(--primary-color);
            font-size: 22px;
            font-weight: 600;
        }

        .header-actions {
            display: flex;
            align-items: center;
        }

        .notification-btn {
            position: relative;
            margin-right: 20px;
            cursor: pointer;
            color: var(--primary-color);
        }

        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: var(--error-color);
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

        .user-menu {
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .user-menu-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }

        /* Conteneur de messagerie */
        .messaging-container {
            flex: 1;
            display: flex;
            padding: 20px;
            gap: 20px;
        }

        /* Liste des conversations */
        .conversations-panel {
            width: 350px;
            background-color: var(--secondary-color);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .conversations-header {
            padding: 15px;
            background-color: var(--primary-color);
            color: white;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .conversations-title {
            font-weight: 600;
        }

        .new-chat-btn {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 16px;
        }

        .conversations-search {
            padding: 15px;
            border-bottom: 1px solid #eee;
        }

        .search-input {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 20px;
            outline: none;
            font-size: 14px;
        }

        .conversations-list {
            flex: 1;
            overflow-y: auto;
        }

        .conversation-item {
            display: flex;
            align-items: center;
            padding: 15px;
            cursor: pointer;
            transition: all 0.3s ease;
            border-bottom: 1px solid #f0f0f0;
        }

        .conversation-item:hover {
            background-color: #f9f9f9;
        }

        .conversation-item.active {
            background-color: #e3f2fd;
        }

        .conversation-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            margin-right: 12px;
            object-fit: cover;
        }

        .conversation-info {
            flex: 1;
            min-width: 0;
        }

        .conversation-name {
            font-weight: 600;
            margin-bottom: 3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .conversation-preview {
            font-size: 13px;
            color: #666;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .conversation-meta {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
        }

        .conversation-time {
            font-size: 11px;
            color: #999;
            margin-bottom: 5px;
        }

        .unread-count {
            background-color: var(--primary-color);
            color: white;
            border-radius: 50%;
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            font-weight: bold;
        }

        /* Zone de chat */
        .chat-panel {
            flex: 1;
            display: flex;
            flex-direction: column;
            background-color: var(--secondary-color);
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .chat-header {
            display: flex;
            align-items: center;
            padding: 15px;
            background-color: var(--primary-color);
            color: white;
        }

        .chat-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            margin-right: 12px;
            object-fit: cover;
        }

        .chat-info {
            flex: 1;
        }

        .chat-title {
            font-weight: 600;
            margin-bottom: 3px;
        }

        .chat-status {
            font-size: 12px;
            color: rgba(255, 255, 255, 0.8);
        }

        .chat-actions {
            display: flex;
            gap: 15px;
        }

        .chat-action-btn {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            font-size: 16px;
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

        .message-received {
            justify-content: flex-start;
        }

        .message-sent {
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
            max-width: 70%;
        }

        .message-received .message-content {
            background-color: white;
            color: var(--text-dark);
            border-radius: 0 15px 15px 15px;
            padding: 12px 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .message-sent .message-content {
            background-color: var(--primary-light);
            color: white;
            border-radius: 15px 0 15px 15px;
            padding: 12px 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
        }

        .message-text {
            word-wrap: break-word;
            line-height: 1.4;
        }

        .message-meta {
            display: flex;
            justify-content: space-between;
            margin-top: 5px;
            font-size: 11px;
        }

        .message-sender {
            font-weight: 500;
        }

        .message-time {
            margin-left: 10px;
            opacity: 0.8;
        }

        .message-sent .message-meta {
            color: rgba(255, 255, 255, 0.8);
        }

        .chat-input-area {
            display: flex;
            padding: 15px;
            background-color: white;
            border-top: 1px solid #eee;
        }

        .message-input {
            flex: 1;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 30px;
            outline: none;
            font-size: 14px;
            margin-right: 10px;
            resize: none;
            height: 45px;
            max-height: 120px;
        }

        .send-btn {
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

        .send-btn:hover {
            background-color: var(--primary-dark);
            transform: scale(1.05);
        }

        .send-btn i {
            font-size: 18px;
        }

        /* Aucune conversation sélectionnée */
        .no-conversation {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100%;
            color: #999;
            text-align: center;
            padding: 30px;
        }

        .no-conversation-icon {
            font-size: 60px;
            color: #ddd;
            margin-bottom: 20px;
        }

        .no-conversation-title {
            font-size: 20px;
            color: var(--primary-color);
            margin-bottom: 10px;
        }

        /* Styles responsives */
        @media (max-width: 992px) {
            .member-sidebar {
                width: 80px;
            }
            .member-name, .member-status, .nav-item span {
                display: none;
            }
            .nav-item {
                justify-content: center;
            }
            .nav-item i {
                margin-right: 0;
            }
        }

        @media (max-width: 768px) {
            .conversations-panel {
                width: 300px;
            }
            .messaging-container {
                padding: 10px;
            }
        }

        @media (max-width: 576px) {
            .member-app {
                flex-direction: column;
            }
            .member-sidebar {
                width: 100%;
                height: auto;
                padding: 10px;
            }
            .member-profile {
                padding: 0 10px 10px;
            }
            .nav-menu {
                display: flex;
                overflow-x: auto;
                padding: 5px;
            }
            .nav-item {
                padding: 8px 12px;
                margin: 0 5px;
                white-space: nowrap;
            }
            .messaging-container {
                flex-direction: column;
                height: auto;
            }
            .conversations-panel {
                width: 100%;
                height: 300px;
            }
            .chat-panel {
                height: 400px;
            }
        }
    </style>
</head>
<body>
    <div class="member-app">
        <!-- Barre latérale -->
        <div class="member-sidebar">
            <div class="member-profile">
                <img src="<%= ((User)session.getAttribute("currentUser")).getAvatar() %>" alt="Avatar" class="member-avatar">
                <div>
                    <div class="member-name"><%= ((User)session.getAttribute("currentUser")).getFullName() %></div>
                    <div class="member-status">En ligne</div>
                </div>
            </div>
            
            <nav class="nav-menu">
                <div class="nav-item active">
                    <i class="fas fa-comments"></i>
                    <span>Messagerie</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-user"></i>
                    <span>Mon Profil</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-users"></i>
                    <span>Mes Groupes</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-hand-holding-usd"></i>
                    <span>Mes Tontines</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-file-invoice-dollar"></i>
                    <span>Mes Paiements</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-cog"></i>
                    <span>Paramètres</span>
                </div>
                <div class="nav-item">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Déconnexion</span>
                </div>
            </nav>
        </div>

        <!-- Contenu principal -->
        <div class="member-content">
            <header class="member-header">
                <h1 class="page-title"><i class="fas fa-comments"></i> Messagerie</h1>
                <div class="header-actions">
                    <div class="notification-btn">
                        <i class="fas fa-bell"></i>
                        <span class="notification-badge"><%= Discussion.getMemberUnreadCount(((User)session.getAttribute("currentUser")).getId()) %></span>
                    </div>
                    <div class="user-menu">
                        <img src="<%= ((User)session.getAttribute("currentUser")).getAvatar() %>" alt="Avatar" class="user-menu-avatar">
                        <span><%= ((User)session.getAttribute("currentUser")).getFirstName() %></span>
                    </div>
                </div>
            </header>

            <div class="messaging-container">
                <!-- Liste des conversations -->
                <div class="conversations-panel">
                    <div class="conversations-header">
                        <h3 class="conversations-title">Conversations</h3>
                        <button class="new-chat-btn" title="Nouvelle conversation">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                    
                    <div class="conversations-search">
                        <input type="text" class="search-input" placeholder="Rechercher une conversation...">
                    </div>
                    
                    <div class="conversations-list">
                        <% List<Discussion> activeDiscussions = Discussion.getMemberActiveDiscussions(((User)session.getAttribute("currentUser")).getId()); %>
                        <% for(Discussion discussion : activeDiscussions) { 
                            boolean isActive = discussion.getId() == Integer.parseInt(request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "0");
                        %>
                        <div class="conversation-item <%= isActive ? "active" : "" %>" data-discussion-id="<%= discussion.getId() %>">
                            <img src="<%= discussion.getAvatar() %>" alt="Avatar" class="conversation-avatar">
                            <div class="conversation-info">
                                <div class="conversation-name"><%= discussion.getTitle() %></div>
                                <div class="conversation-preview"><%= discussion.getLastMessagePreview() %></div>
                            </div>
                            <div class="conversation-meta">
                                <div class="conversation-time"><%= discussion.getLastMessageTime() %></div>
                                <% if(discussion.getUnreadCount() > 0) { %>
                                <div class="unread-count"><%= discussion.getUnreadCount() %></div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Zone de chat -->
                <% if(request.getParameter("discussion_id") != null) { 
                    Discussion currentDiscussion = Discussion.getById(Integer.parseInt(request.getParameter("discussion_id"))); 
                    List<Message> messages = Messages.getByDiscussion(currentDiscussion.getId());
                %>
                <div class="chat-panel">
                    <div class="chat-header">
                        <img src="<%= currentDiscussion.getAvatar() %>" alt="Avatar" class="chat-avatar">
                        <div class="chat-info">
                            <h3 class="chat-title"><%= currentDiscussion.getTitle() %></h3>
                            <div class="chat-status">En ligne</div>
                        </div>
                        <div class="chat-actions">
                            <button class="chat-action-btn" title="Informations">
                                <i class="fas fa-info-circle"></i>
                            </button>
                        </div>
                    </div>
                    
                    <div class="messages-container">
                        <% for(Message message : messages) { 
                            boolean isSent = message.getSenderType().equals("member") && message.getSenderId() == ((User)session.getAttribute("currentUser")).getId();
                        %>
                        <div class="message <%= isSent ? "message-sent" : "message-received" %>">
                            <% if(!isSent) { %>
                            <div class="message-avatar">
                                <img src="<%= message.getSenderAvatar() %>" alt="Avatar">
                            </div>
                            <% } %>
                            <div class="message-content">
                                <div class="message-text"><%= message.getContent() %></div>
                                <div class="message-meta">
                                    <span class="message-sender"><%= isSent ? "Vous" : message.getSenderName() %></span>
                                    <span class="message-time"><%= message.getFormattedTime() %></span>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="chat-input-area">
                        <textarea class="message-input" placeholder="Écrivez votre message..." rows="1"></textarea>
                        <button class="send-btn" id="send-button">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </div>
                </div>
                <% } else { %>
                <div class="no-conversation">
                    <div class="no-conversation-icon">
                        <i class="fas fa-comments"></i>
                    </div>
                    <h3 class="no-conversation-title">Aucune conversation sélectionnée</h3>
                    <p>Sélectionnez une conversation existante ou démarrez une nouvelle discussion</p>
                    <button class="new-chat-btn" style="margin-top: 20px; padding: 10px 20px; border-radius: 20px; background-color: var(--primary-color); color: white; border: none; cursor: pointer;">
                        <i class="fas fa-plus"></i> Nouvelle conversation
                    </button>
                </div>
                <% } %>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
    $(document).ready(function() {
        // Sélection d'une conversation
        $('.conversation-item').click(function() {
            const discussionId = $(this).data('discussion-id');
            window.location.href = 'member_messaging.jsp?discussion_id=' + discussionId;
        });
        
        // Gestion de la zone de texte qui s'agrandit
        $('.message-input').on('input', function() {
            this.style.height = 'auto';
            this.style.height = (this.scrollHeight) + 'px';
        });
        
        // Envoi de message avec Entrée (sans shift)
        $('.message-input').keydown(function(e) {
            if(e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
        
        // Envoi de message avec le bouton
        $('#send-button').click(sendMessage);
        
        function sendMessage() {
            const input = $('.message-input');
            const message = input.val().trim();
            const discussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
            
            if(message && discussionId) {
                // Ajout temporaire du message (optimiste)
                const time = new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                const tempId = 'temp-' + Date.now();
                
                const messageHtml = `
                    <div class="message message-sent" id="${tempId}">
                        <div class="message-content">
                            <div class="message-text">${message}</div>
                            <div class="message-meta">
                                <span class="message-sender">Vous</span>
                                <span class="message-time">${time}</span>
                            </div>
                        </div>
                    </div>
                `;
                
                $('.messages-container').append(messageHtml);
                input.val('');
                input.height('auto');
                scrollToBottom();
                
                // Envoi au serveur
                $.post('SendMessageServlet', {
                    discussion_id: discussionId,
                    content: message,
                    sender_type: 'member',
                    sender_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                }, function(response) {
                    if(response.success) {
                        // Remplace le message temporaire par la version définitive
                        const finalMessageHtml = `
                            <div class="message message-sent" data-message-id="${response.message_id}">
                                <div class="message-content">
                                    <div class="message-text">${message}</div>
                                    <div class="message-meta">
                                        <span class="message-sender">Vous</span>
                                        <span class="message-time">${time}</span>
                                    </div>
                                </div>
                            </div>
                        `;
                        
                        $('#' + tempId).replaceWith(finalMessageHtml);
                        updateConversationList(discussionId, message, time);
                    } else {
                        // Affiche une erreur si l'envoi a échoué
                        alert("Erreur: " + (response.error || "Impossible d'envoyer le message"));
                        $('#' + tempId).find('.message-content')
                            .css('background-color', '#ffebee')
                            .css('color', '#c62828');
                    }
                }).fail(function() {
                    alert("Erreur de connexion au serveur");
                    $('#' + tempId).find('.message-content')
                        .css('background-color', '#ffebee')
                        .css('color', '#c62828');
                });
            }
        }
        
        function updateConversationList(discussionId, message, time) {
            // Met à jour la dernière conversation dans la liste
            const conversationItem = $('.conversation-item[data-discussion-id="' + discussionId + '"]');
            conversationItem.find('.conversation-preview').text(message.length > 30 ? message.substring(0, 30) + '...' : message);
            conversationItem.find('.conversation-time').text(time);
            conversationItem.find('.unread-count').remove();
            
            // Déplace la conversation en haut de la liste
            conversationItem.prependTo('.conversations-list');
        }
        
        function scrollToBottom() {
            const container = $('.messages-container');
            container.scrollTop(container[0].scrollHeight);
        }
        
        // Actualisation périodique des messages
        function refreshMessages() {
            const discussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
            if(discussionId) {
                const lastMessageId = $('.message').last().data('message-id') || 0;
                
                $.get('GetNewMessagesServlet', {
                    discussion_id: discussionId,
                    last_message_id: lastMessageId,
                    user_type: 'member',
                    user_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                }, function(response) {
                    if(response.messages && response.messages.length > 0) {
                        response.messages.forEach(function(message) {
                            const isSent = message.sender_type === 'member' && message.sender_id === <%= ((User)session.getAttribute("currentUser")).getId() %>;
                            
                            const messageHtml = `
                                <div class="message ${isSent ? 'message-sent' : 'message-received'}" data-message-id="${message.id}">
                                    {!isSent ? 
                                    <div class="message-avatar">
                                        <img src="${message.sender_avatar}" alt="Avatar">
                                    </div>
                                     : ''}
                                    <div class="message-content">
                                        <div class="message-text">${message.content}</div>
                                        <div class="message-meta">
                                            <span class="message-sender">${isSent ? 'Vous' : message.sender_name}</span>
                                            <span class="message-time">${message.formatted_time}</span>
                                        </div>
                                    </div>
                                </div>
                            `;
                            
                            $('.messages-container').append(messageHtml);
                        });
                        
                        scrollToBottom();
                        markMessagesAsRead(discussionId);
                    }
                });
            }
        }
        
        // Marquer les messages comme lus
        function markMessagesAsRead(discussionId) {
            if(discussionId) {
                $.post('MarkMessagesAsReadServlet', {
                    discussion_id: discussionId,
                    user_type: 'member',
                    user_id: <%= ((User)session.getAttribute("currentUser")).getId() %>
                });
                
                // Mettre à jour l'interface
                $('.conversation-item[data-discussion-id="' + discussionId + '"] .unread-count').remove();
                $('.notification-badge').text(parseInt($('.notification-badge').text()) - 1);
            }
        }
        
        // Actualisation toutes les 3 secondes
        setInterval(refreshMessages, 3000);
        
        // Marquage initial des messages comme lus
        const currentDiscussionId = <%= request.getParameter("discussion_id") != null ? request.getParameter("discussion_id") : "null" %>;
        if(currentDiscussionId) {
            markMessagesAsRead(currentDiscussionId);
            scrollToBottom();
        }
    });
    </script>
</body>
</html>