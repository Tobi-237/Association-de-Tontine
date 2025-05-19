package servlets;


import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import java.util.Properties;

public class EmailService {
    
    // Configuration SMTP
    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int SMTP_PORT = 587;
    private static final String USERNAME = "gofarassociation@gmail.com";
    private static final String PASSWORD = "dcpp ljll tnxf hejw";
    private static final boolean SMTP_AUTH = true;
    private static final boolean STARTTLS_ENABLE = true;
    
    private EmailService() {
        // Empêche l'instanciation de la classe
    }
    
    public static void sendEmail(String toEmail, String subject, String content) {
        // Configuration des propriétés
        Properties props = new Properties();
        props.put("mail.smtp.auth", SMTP_AUTH);
        props.put("mail.smtp.starttls.enable", STARTTLS_ENABLE);
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", SMTP_PORT);
        
        // Création de la session
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(USERNAME, PASSWORD);
            }
        });
        
        try {
            // Création du message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(USERNAME));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setText(content);
            
            // Envoi du message
            Transport.send(message);
            
            System.out.println("Email envoyé avec succès à " + toEmail);
            
        } catch (MessagingException e) {
            throw new RuntimeException("Erreur lors de l'envoi de l'email à " + toEmail, e);
        }
    }
}