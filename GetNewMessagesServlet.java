package servlets;

import java.io.*;
import java.util.List;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import models.Message;
import org.json.JSONObject;
import org.json.JSONArray;

@WebServlet("/GetNewMessagesServlet")
public class GetNewMessagesServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        JSONArray messagesArray = new JSONArray();
        
        try {
            int discussionId = Integer.parseInt(request.getParameter("discussion_id"));
            int lastMessageId = Integer.parseInt(request.getParameter("last_message_id"));
            
            // Récupérer les nouveaux messages depuis la base de données
            List<Message> newMessages = Message.getNewMessages(discussionId, lastMessageId);
            
            for (Message message : newMessages) {
                JSONObject msgJson = new JSONObject();
                msgJson.put("id", message.getId());
                msgJson.put("content", message.getContent());
                msgJson.put("sender_type", message.getSenderType());
                msgJson.put("sender_id", message.getSenderId());
                msgJson.put("sender_name", message.getSenderName());
                msgJson.put("sender_avatar", message.getSenderAvatar());
                msgJson.put("formatted_time", message.getFormattedTime());
                
                messagesArray.put(msgJson);
            }
            
            jsonResponse.put("success", true);
            jsonResponse.put("messages", messagesArray);
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}