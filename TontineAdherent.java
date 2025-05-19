package models;

import java.security.Timestamp;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class TontineAdherent {
    private int id;
    private int tontineId;
    private int memberId;
    private Timestamp dateSouscription;
    private double montantSouscription;
    private int nombreDePart;
    private int nombrePartsMax;
    private Timestamp dateAdhesion;
    private String tontineName;
    private boolean isActive;
    
    
    public TontineAdherent(int id, int tontineId, int memberId, Timestamp dateSouscription, double montantSouscription,
			int nombreDePart, int nombrePartsMax, Timestamp dateAdhesion, String tontineName, boolean isActive) {
		super();
		this.id = id;
		this.tontineId = tontineId;
		this.memberId = memberId;
		this.dateSouscription = dateSouscription;
		this.montantSouscription = montantSouscription;
		this.nombreDePart = nombreDePart;
		this.nombrePartsMax = nombrePartsMax;
		this.dateAdhesion = dateAdhesion;
		this.tontineName = tontineName;
		this.isActive = isActive;
	}
    
    

	public int getId() {
		return id;
	}



	public void setId(int id) {
		this.id = id;
	}



	public int getTontineId() {
		return tontineId;
	}



	public void setTontineId(int tontineId) {
		this.tontineId = tontineId;
	}



	public int getMemberId() {
		return memberId;
	}



	public void setMemberId(int memberId) {
		this.memberId = memberId;
	}



	public Timestamp getDateSouscription() {
		return dateSouscription;
	}



	public void setDateSouscription(Timestamp dateSouscription) {
		this.dateSouscription = dateSouscription;
	}



	public double getMontantSouscription() {
		return montantSouscription;
	}



	public void setMontantSouscription(double montantSouscription) {
		this.montantSouscription = montantSouscription;
	}



	public int getNombreDePart() {
		return nombreDePart;
	}



	public void setNombreDePart(int nombreDePart) {
		this.nombreDePart = nombreDePart;
	}



	public int getNombrePartsMax() {
		return nombrePartsMax;
	}



	public void setNombrePartsMax(int nombrePartsMax) {
		this.nombrePartsMax = nombrePartsMax;
	}



	public Timestamp getDateAdhesion() {
		return dateAdhesion;
	}



	public void setDateAdhesion(Timestamp dateAdhesion) {
		this.dateAdhesion = dateAdhesion;
	}



	public String getTontineName() {
		return tontineName;
	}



	public void setTontineName(String tontineName) {
		this.tontineName = tontineName;
	}



	public boolean isActive() {
		return isActive;
	}



	public void setActive(boolean isActive) {
		this.isActive = isActive;
	}



	// Getters et setters
    public String getDate() {
        return new SimpleDateFormat("dd/MM/yyyy").format(dateSouscription);
    }
    
    public String getAmount() {
        return NumberFormat.getNumberInstance(Locale.FRENCH).format(montantSouscription);
    }



	@Override
	public String toString() {
		return "TontineAdherent [id=" + id + ", tontineId=" + tontineId + ", memberId=" + memberId
				+ ", dateSouscription=" + dateSouscription + ", montantSouscription=" + montantSouscription
				+ ", nombreDePart=" + nombreDePart + ", nombrePartsMax=" + nombrePartsMax + ", dateAdhesion="
				+ dateAdhesion + ", tontineName=" + tontineName + ", isActive=" + isActive + "]";
	}
    
    // ...
    
}
