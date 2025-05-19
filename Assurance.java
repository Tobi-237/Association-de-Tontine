package models;

import java.security.Timestamp;
import java.sql.Date;
import java.text.NumberFormat;
import java.util.Locale;

public class Assurance {
    private int id;
    private int memberId;
    private String typeAssurance;
    private double montantCouverture;
    private double primeMensuelle;
    private Date dateDebut;
    private Date dateFin;
    private String statut;
    private Integer compagnieId;
    private String notes;
    private Timestamp createdAt;
    private Timestamp dateCreation;
    
    
    
    public Assurance(int id, int memberId, String typeAssurance, double montantCouverture, double primeMensuelle,
			Date dateDebut, Date dateFin, String statut, Integer compagnieId, String notes, Timestamp createdAt,
			Timestamp dateCreation) {
		super();
		this.id = id;
		this.memberId = memberId;
		this.typeAssurance = typeAssurance;
		this.montantCouverture = montantCouverture;
		this.primeMensuelle = primeMensuelle;
		this.dateDebut = dateDebut;
		this.dateFin = dateFin;
		this.statut = statut;
		this.compagnieId = compagnieId;
		this.notes = notes;
		this.createdAt = createdAt;
		this.dateCreation = dateCreation;
	}

    
	public int getId() {
		return id;
	}


	public void setId(int id) {
		this.id = id;
	}


	public int getMemberId() {
		return memberId;
	}


	public void setMemberId(int memberId) {
		this.memberId = memberId;
	}


	public String getTypeAssurance() {
		return typeAssurance;
	}


	public void setTypeAssurance(String typeAssurance) {
		this.typeAssurance = typeAssurance;
	}


	public double getMontantCouverture() {
		return montantCouverture;
	}


	public void setMontantCouverture(double montantCouverture) {
		this.montantCouverture = montantCouverture;
	}


	public double getPrimeMensuelle() {
		return primeMensuelle;
	}


	public void setPrimeMensuelle(double primeMensuelle) {
		this.primeMensuelle = primeMensuelle;
	}


	public Date getDateDebut() {
		return dateDebut;
	}


	public void setDateDebut(Date dateDebut) {
		this.dateDebut = dateDebut;
	}


	public Date getDateFin() {
		return dateFin;
	}


	public void setDateFin(Date dateFin) {
		this.dateFin = dateFin;
	}


	public String getStatut() {
		return statut;
	}


	public void setStatut(String statut) {
		this.statut = statut;
	}


	public Integer getCompagnieId() {
		return compagnieId;
	}


	public void setCompagnieId(Integer compagnieId) {
		this.compagnieId = compagnieId;
	}


	public String getNotes() {
		return notes;
	}


	public void setNotes(String notes) {
		this.notes = notes;
	}


	public Timestamp getCreatedAt() {
		return createdAt;
	}


	public void setCreatedAt(Timestamp createdAt) {
		this.createdAt = createdAt;
	}


	public Timestamp getDateCreation() {
		return dateCreation;
	}


	public void setDateCreation(Timestamp dateCreation) {
		this.dateCreation = dateCreation;
	}


	// Getters et setters
    public String getType() {
        return typeAssurance;
    }
    
    public String getCoverage() {
        return NumberFormat.getNumberInstance(Locale.FRENCH).format(montantCouverture);
    }
    
    public String getPremium() {
        return NumberFormat.getNumberInstance(Locale.FRENCH).format(primeMensuelle);
    }
    
    public boolean isActive() {
        return "ACTIVE".equals(statut);
    }


	@Override
	public String toString() {
		return "Assurance [id=" + id + ", memberId=" + memberId + ", typeAssurance=" + typeAssurance
				+ ", montantCouverture=" + montantCouverture + ", primeMensuelle=" + primeMensuelle + ", dateDebut="
				+ dateDebut + ", dateFin=" + dateFin + ", statut=" + statut + ", compagnieId=" + compagnieId
				+ ", notes=" + notes + ", createdAt=" + createdAt + ", dateCreation=" + dateCreation + "]";
	}
    
    // ...
    
}