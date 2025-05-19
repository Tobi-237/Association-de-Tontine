package models;

import java.security.Timestamp;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Locale;

public class Paiement {
    private int id;
    private int memberId;
    private double montant;
    private String typePaiement;
    private Timestamp datePaiement;
    private String methodePaiement;
    private String reference;
    private String statut;
    private String moisAnnee;
    private Integer tontineId;
    private String modePaiement;
    
    
    public Paiement(int id, int memberId, double montant, String typePaiement, Timestamp datePaiement,
			String methodePaiement, String reference, String statut, String moisAnnee, Integer tontineId,
			String modePaiement) {
		super();
		this.id = id;
		this.memberId = memberId;
		this.montant = montant;
		this.typePaiement = typePaiement;
		this.datePaiement = datePaiement;
		this.methodePaiement = methodePaiement;
		this.reference = reference;
		this.statut = statut;
		this.moisAnnee = moisAnnee;
		this.tontineId = tontineId;
		this.modePaiement = modePaiement;
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



	public double getMontant() {
		return montant;
	}



	public void setMontant(double montant) {
		this.montant = montant;
	}



	public String getTypePaiement() {
		return typePaiement;
	}



	public void setTypePaiement(String typePaiement) {
		this.typePaiement = typePaiement;
	}



	public Timestamp getDatePaiement() {
		return datePaiement;
	}



	public void setDatePaiement(Timestamp datePaiement) {
		this.datePaiement = datePaiement;
	}



	public String getMethodePaiement() {
		return methodePaiement;
	}



	public void setMethodePaiement(String methodePaiement) {
		this.methodePaiement = methodePaiement;
	}



	public String getReference() {
		return reference;
	}



	public void setReference(String reference) {
		this.reference = reference;
	}



	public String getStatut() {
		return statut;
	}



	public void setStatut(String statut) {
		this.statut = statut;
	}



	public String getMoisAnnee() {
		return moisAnnee;
	}



	public void setMoisAnnee(String moisAnnee) {
		this.moisAnnee = moisAnnee;
	}



	public Integer getTontineId() {
		return tontineId;
	}



	public void setTontineId(Integer tontineId) {
		this.tontineId = tontineId;
	}



	public String getModePaiement() {
		return modePaiement;
	}



	public void setModePaiement(String modePaiement) {
		this.modePaiement = modePaiement;
	}



	// Getters et setters
    public String getDate() {
        return new SimpleDateFormat("dd/MM/yyyy").format(datePaiement);
    }
    
    public String getAmount() {
        return NumberFormat.getNumberInstance(Locale.FRENCH).format(montant);
    }
    
    public String getType() {
        return typePaiement;
    }
    
    public boolean isCompleted() {
        return "COMPLETED".equals(statut);
    }



	@Override
	public String toString() {
		return "Paiement [id=" + id + ", memberId=" + memberId + ", montant=" + montant + ", typePaiement="
				+ typePaiement + ", datePaiement=" + datePaiement + ", methodePaiement=" + methodePaiement
				+ ", reference=" + reference + ", statut=" + statut + ", moisAnnee=" + moisAnnee + ", tontineId="
				+ tontineId + ", modePaiement=" + modePaiement + "]";
	}
    
    // ...
    
}