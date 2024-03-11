class FactureModel {
  int releveCompteurId;
  String numFacture;
  String numCompteur;
  String dateFacture;
  double totalConsoHT;
  double totalTaxeCoHT;
  double totalRedevanceBsHT;
  double totalRedevanceFrHT;
  double tarifM3;
  double avoirAvant;
  double avoirUtilise;
  double restantPrecedant;
  double montantTotalTTC;
  String statut;

  FactureModel({
    required this.releveCompteurId,
    required this.numFacture,
    required this.numCompteur,
    required this.dateFacture,
    required this.totalConsoHT,
    required this.totalTaxeCoHT,
    required this.totalRedevanceBsHT,
    required this.totalRedevanceFrHT,
    required this.tarifM3,
    required this.avoirAvant,
    required this.avoirUtilise,
    required this.restantPrecedant,
    required this.montantTotalTTC,
    required this.statut,
  });

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      releveCompteurId: json['facture']['relevecompteur_id'],
      numFacture: json['facture']['num_facture'],
      numCompteur: json['facture']['num_compteur'],
      dateFacture: json['facture']['date_facture'],
      totalConsoHT: json['facture']['total_conso_ht'],
      totalTaxeCoHT: json['facture']['total_taxe_co_ht'],
      totalRedevanceBsHT: json['facture']['total_redevance_bs_ht'],
      totalRedevanceFrHT: json['facture']['total_redevance_fr_ht'],
      tarifM3: json['facture']['tarif_m3'],
      avoirAvant: json['facture']['avoir_avant'],
      avoirUtilise: json['facture']['avoir_utilise'],
      restantPrecedant: json['facture']['restant_precedant'],
      montantTotalTTC: json['facture']['montant_total_ttc'],
      statut: json['facture']['statut'],
    );
  }
}
