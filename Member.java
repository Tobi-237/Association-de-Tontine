package models;

import java.security.Timestamp;
import java.text.SimpleDateFormat;

public class Member {
    private int id;
    private String memberId;
    private String nom;
    private String prenom;
    private String email;
    private String inscription;
    private String numero;
    private String localisation;
    private String password;
    private Timestamp createdAt;
    private boolean isMember;
    private String statut;
    private String avatar;
    private String lastLogin;
    
    
    
    public Member(int id, String memberId, String nom, String prenom, String email, String inscription, String numero,
			String localisation, String password, Timestamp createdAt, boolean isMember, String statut, String avatar,
			String lastLogin) {
		super();
		this.id = id;
		this.memberId = memberId;
		this.nom = nom;
		this.prenom = prenom;
		this.email = email;
		this.inscription = inscription;
		this.numero = numero;
		this.localisation = localisation;
		this.password = password;
		this.createdAt = createdAt;
		this.isMember = isMember;
		this.statut = statut;
		this.avatar = avatar;
		this.lastLogin = lastLogin;
	}



	public int getId() {
		return id;
	}



	public void setId(int id) {
		this.id = id;
	}



	public String getMemberId() {
		return memberId;
	}



	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}



	public String getNom() {
		return nom;
	}



	public void setNom(String nom) {
		this.nom = nom;
	}



	public String getPrenom() {
		return prenom;
	}



	public void setPrenom(String prenom) {
		this.prenom = prenom;
	}



	public String getEmail() {
		return email;
	}



	public void setEmail(String email) {
		this.email = email;
	}



	public String getInscription() {
		return inscription;
	}



	public void setInscription(String inscription) {
		this.inscription = inscription;
	}



	public String getNumero() {
		return numero;
	}



	public void setNumero(String numero) {
		this.numero = numero;
	}



	public String getLocalisation() {
		return localisation;
	}



	public void setLocalisation(String localisation) {
		this.localisation = localisation;
	}



	public String getPassword() {
		return password;
	}



	public void setPassword(String password) {
		this.password = password;
	}



	public Timestamp getCreatedAt() {
		return createdAt;
	}



	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}



	public boolean isMember() {
		return isMember;
	}



	public void setMember(boolean isMember) {
		this.isMember = isMember;
	}



	public String getStatut() {
		return statut;
	}



	public void setStatut(String statut) {
		this.statut = statut;
	}



	public String getAvatar() {
		return avatar;
	}



	public void setAvatar(String avatar) {
		this.avatar = avatar;
	}



	public String getLastLogin() {
		return lastLogin;
	}



	public void setLastLogin(String lastLogin) {
		this.lastLogin = lastLogin;
	}



	// Getters et setters
    public String getFullName() {
        return prenom + " " + nom;
    }
    
 // Ajoutez ces méthodes manquantes
    public String getJoinDate() {
        return new SimpleDateFormat("dd/MM/yyyy").format(createdAt);
    }
 // Dans configurerSessionMembre()
    public Member() {
        // Constructeur par défaut
    }


	@Override
	public String toString() {
		return "Member [id=" + id + ", memberId=" + memberId + ", nom=" + nom + ", prenom=" + prenom + ", email="
				+ email + ", inscription=" + inscription + ", numero=" + numero + ", localisation=" + localisation
				+ ", password=" + password + ", createdAt=" + createdAt + ", isMember=" + isMember + ", statut="
				+ statut + ", avatar=" + avatar + ", lastLogin=" + lastLogin + "]";
	}
    
    // ...
    
}
