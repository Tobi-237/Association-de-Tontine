package servlets;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import models.Message;
import org.json.JSONObject;

import com.itextpdf.awt.geom.misc.Messages;

@WebServlet("/SendMessageServlet")
public class SendMessageServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        JSONObject jsonResponse = new JSONObject();
        
        try {
            int discussionId = Integer.parseInt(request.getParameter("discussion_id"));
            String content = request.getParameter("content");
            String senderType = request.getParameter("sender_type");
            int senderId = Integer.parseInt(request.getParameter("sender_id"));
            
            // Enregistrer le message en base de données
            Message messages = new Message();
            messages.setDiscussionId(discussionId);
            messages.setContent(content);
            messages.setSenderType(senderType);
            messages.setSenderId(senderId);
            
            boolean success = messages.save(); // Méthode à implémenter
            
            jsonResponse.put("success", success);
        } catch (Exception e) {
            jsonResponse.put("success", false);
            jsonResponse.put("error", e.getMessage());
        }
        
        out.print(jsonResponse.toString());
        out.flush();
    }
}