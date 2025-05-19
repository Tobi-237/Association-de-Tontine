package models;

import java.security.Timestamp;
import java.sql.Date;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class Sanction {
    private int id;
    private String typeSanction;
    private String details;
    private String duree;
    private double montant;
    private Timestamp dateCreation;
    private Integer memberId;
    private Date dateSanction;
    private String motif;
    private String statut;
    private Timestamp dateFin;
    
    
    
    public Sanction(int id, String typeSanction, String details, String duree, double montant, Timestamp dateCreation,
			Integer memberId, Date dateSanction, String motif, String statut, Timestamp dateFin) {
		super();
		this.id = id;
		this.typeSanction = typeSanction;
		this.details = details;
		this.duree = duree;
		this.montant = montant;
		this.dateCreation = dateCreation;
		this.memberId = memberId;
		this.dateSanction = dateSanction;
		this.motif = motif;
		this.statut = statut;
		this.dateFin = dateFin;
	}
    
    

	public int getId() {
		return id;
	}



	public void setId(int id) {
		this.id = id;
	}



	public String getTypeSanction() {
		return typeSanction;
	}



	public void setTypeSanction(String typeSanction) {
		this.typeSanction = typeSanction;
	}



	public String getDetails() {
		return details;
	}



	public void setDetails(String details) {
		this.details = details;
	}



	public String getDuree() {
		return duree;
	}



	public void setDuree(String duree) {
		this.duree = duree;
	}



	public double getMontant() {
		return montant;
	}



	public void setMontant(double montant) {
		this.montant = montant;
	}



	public Timestamp getDateCreation() {
		return dateCreation;
	}



	public void setDateCreation(Timestamp dateCreation) {
		this.dateCreation = dateCreation;
	}



	public Integer getMemberId() {
		return memberId;
	}



	public void setMemberId(Integer memberId) {
		this.memberId = memberId;
	}



	public Date getDateSanction() {
		return dateSanction;
	}



	public void setDateSanction(Date dateSanction) {
		this.dateSanction = dateSanction;
	}



	public String getMotif() {
		return motif;
	}



	public void setMotif(String motif) {
		this.motif = motif;
	}



	public String getStatut() {
		return statut;
	}



	public void setStatut(String statut) {
		this.statut = statut;
	}



	public Timestamp getDateFin() {
		return dateFin;
	}



	public void setDateFin(Timestamp dateFin) {
		this.dateFin = dateFin;
	}



	// Getters et setters
    public String getDate() {
        return new SimpleDateFormat("dd/MM/yyyy").format(dateSanction);
    }
    
    public String getAmount() {
        return NumberFormat.getNumberInstance(Locale.FRENCH).format(montant);
    }
    
    public String getType() {
        return typeSanction;
    }
    
    public boolean isActive() {
        return "active".equals(statut);
    }



	@Override
	public String toString() {
		return "Sanction [id=" + id + ", typeSanction=" + typeSanction + ", details=" + details + ", duree=" + duree
				+ ", montant=" + montant + ", dateCreation=" + dateCreation + ", memberId=" + memberId
				+ ", dateSanction=" + dateSanction + ", motif=" + motif + ", statut=" + statut + ", dateFin=" + dateFin
				+ "]";
	}
    
    // ...
    
}