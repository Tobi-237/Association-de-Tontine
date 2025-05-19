package models;

import java.util.ArrayList;
import java.util.List;

public class AdminDiscussion {
    public static List<Member> getOnlineMembers() {
        // Implémentez la logique pour récupérer les membres en ligne depuis la base de données
        return new ArrayList<>();
    }
    
    public static List<Member> getOfflineMembers() {
        // Implémentez la logique pour récupérer les membres hors ligne depuis la base de données
        return new ArrayList<>();
    }
    
    public static List<Message> getMessages(int memberId) {
        // Implémentez la logique pour récupérer les messages avec un membre spécifique
        return new ArrayList<>();
    }
    
    public static List<TontineAdherent> getSubscriptions(int memberId) {
        // Implémentez la logique pour récupérer les souscriptions d'un membre
        return new ArrayList<>();
    }
    
    public static List<Paiement> getPayments(int memberId) {
        // Implémentez la logique pour récupérer les paiements d'un membre
        return new ArrayList<>();
    }
    
    public static List<Sanction> getSanctions(int memberId) {
        // Implémentez la logique pour récupérer les sanctions d'un membre
        return new ArrayList<>();
    }
    
    public static List<Assurance> getInsurances(int memberId) {
        // Implémentez la logique pour récupérer les assurances d'un membre
        return new ArrayList<>();
    }
}