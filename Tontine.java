package servlets;
	import java.math.BigDecimal;
	import java.time.LocalDate;
	import java.sql.ResultSet;
	import java.sql.SQLException;

	public class Tontine {
	    // Attributs correspondant à votre table SQL
	    private int id;
	    private int memberId;
	    private String nom;
	    private String description;
	    private BigDecimal montantMensuel;
	    private LocalDate dateDebut;
	    private LocalDate dateFin;
	    private String etat;  // ACTIVE, COMPLETED, CANCELLED

	    // Constructeurs
	    public Tontine() {}

	    // Méthode pour créer un objet depuis un ResultSet
	    public static Tontine fromResultSet(ResultSet rs) throws SQLException {
	        Tontine tontine = new Tontine();
	        tontine.setId(rs.getInt("id"));
	        tontine.setMemberId(rs.getInt("member_id"));
	        tontine.setNom(rs.getString("nom"));
	        tontine.setDescription(rs.getString("description"));
	        tontine.setMontantMensuel(rs.getBigDecimal("montant_mensuel"));
	        tontine.setDateDebut(rs.getObject("date_debut", LocalDate.class));
	        tontine.setDateFin(rs.getObject("date_fin", LocalDate.class));
	        tontine.setEtat(rs.getString("etat"));
	        return tontine;
	    }

	    // Getters et Setters (générés avec IDE ou manuellement)
	    public int getId() { return id; }
	    public void setId(int id) { this.id = id; }
	    
	    public int getMemberId() { return memberId; }
	    public void setMemberId(int memberId) { this.memberId = memberId; }
	    
	    public String getNom() { return nom; }
	    public void setNom(String nom) { this.nom = nom; }

		public String getDescription() {
			return description;
		}

		public void setDescription(String description) {
			this.description = description;
		}

		public BigDecimal getMontantMensuel() {
			return montantMensuel;
		}

		public void setMontantMensuel(BigDecimal montantMensuel) {
			this.montantMensuel = montantMensuel;
		}

		public LocalDate getDateDebut() {
			return dateDebut;
		}

		public void setDateDebut(LocalDate dateDebut) {
			this.dateDebut = dateDebut;
		}

		public LocalDate getDateFin() {
			return dateFin;
		}

		public void setDateFin(LocalDate dateFin) {
			this.dateFin = dateFin;
		}

		public String getEtat() {
			return etat;
		}

		public void setEtat(String etat) {
			this.etat = etat;
		}
	    

}
