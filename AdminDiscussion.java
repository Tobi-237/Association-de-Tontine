package models;

import java.util.ArrayList;
import java.util.List;

public class AdminDiscussion {
    public static List<Member> getOnlineMembers() {
        // Impl�mentez la logique pour r�cup�rer les membres en ligne depuis la base de donn�es
        return new ArrayList<>();
    }
    
    public static List<Member> getOfflineMembers() {
        // Impl�mentez la logique pour r�cup�rer les membres hors ligne depuis la base de donn�es
        return new ArrayList<>();
    }
    
    public static List<Message> getMessages(int memberId) {
        // Impl�mentez la logique pour r�cup�rer les messages avec un membre sp�cifique
        return new ArrayList<>();
    }
    
    public static List<TontineAdherent> getSubscriptions(int memberId) {
        // Impl�mentez la logique pour r�cup�rer les souscriptions d'un membre
        return new ArrayList<>();
    }
    
    public static List<Paiement> getPayments(int memberId) {
        // Impl�mentez la logique pour r�cup�rer les paiements d'un membre
        return new ArrayList<>();
    }
    
    public static List<Sanction> getSanctions(int memberId) {
        // Impl�mentez la logique pour r�cup�rer les sanctions d'un membre
        return new ArrayList<>();
    }
    
    public static List<Assurance> getInsurances(int memberId) {
        // Impl�mentez la logique pour r�cup�rer les assurances d'un membre
        return new ArrayList<>();
    }
}