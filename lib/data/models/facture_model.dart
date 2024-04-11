class FactureModel {
  int? id;
  int? relevecompteurId;
  String? numFacture;
  int? numCompteur;
  String? dateFacture;
  double? totalConsoHT;
  double? tarifM3;
  // List<dynamic> taxes;
  double? avoirAvant;
  double? avoirUtilise;
  double? restantPrecedant;
  double? montantTotalTTC;
  String? statut;

  FactureModel({
    this.id,
    this.relevecompteurId,
    this.numFacture,
    this.numCompteur,
    this.dateFacture,
    this.totalConsoHT,
    this.tarifM3,
    // required this.taxes,
    this.avoirAvant,
    this.avoirUtilise,
    this.restantPrecedant,
    this.montantTotalTTC,
    this.statut,
  });

  factory FactureModel.fromMap(Map<String, dynamic> map) {
    return FactureModel(
      id: map['id'],
      relevecompteurId: map['relevecompteur_id'],
      numFacture: map['num_facture'],
      numCompteur: map['num_compteur'], // Convertir en chaîne
      dateFacture: map['date_facture'],
      totalConsoHT: map['total_conso_ht'],
      tarifM3: map['tarif_m3'],
      // taxes: map['taxes'],
      avoirAvant: map['avoir_avant'] ?? 0, // Valeur par défaut si nulle
      avoirUtilise: map['avoir_utilise'] ?? 0,
      restantPrecedant: map['restant_precedant'] ?? 0,
      montantTotalTTC: map['montant_total_ttc'] ?? 0,
      statut: map['statut'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'relevecompteur_id': relevecompteurId,
      'num_facture': numFacture,
      'num_compteur': numCompteur,
      'date_facture': dateFacture,
      'total_conso_ht': totalConsoHT,
      'tarif_m3': tarifM3,
      // 'taxes': jsonEncode(taxes), // Convertir en chaîne JSON
      'avoir_avant': avoirAvant,
      'avoir_utilise': avoirUtilise,
      'restant_precedant': restantPrecedant,
      'montant_total_ttc': montantTotalTTC,
      'statut': statut,
    };
  }

  factory FactureModel.fromJson(Map<String, dynamic> json) {
    return FactureModel(
      id: json['id'],
      relevecompteurId: json['relevecompteur_id'],
      numFacture: json['num_facture'],
      numCompteur: json['num_compteur'],
      dateFacture: json['date_facture'],
      totalConsoHT: json['total_conso_ht'],
      tarifM3: json['tarif_m3'],
      avoirAvant: json['avoir_avant'] ?? 0,
      avoirUtilise: json['avoir_utilise'] ?? 0,
      restantPrecedant: json['restant_precedant'] ?? 0,
      montantTotalTTC: json['montant_total_ttc'] ?? 0,
      statut: json['statut'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'relevecompteur_id': relevecompteurId,
      'num_facture': numFacture,
      'num_compteur': numCompteur,
      'date_facture': dateFacture,
      'total_conso_ht': totalConsoHT,
      'tarif_m3': tarifM3,
      'avoir_avant': avoirAvant,
      'avoir_utilise': avoirUtilise,
      'restant_precedant': restantPrecedant,
      'montant_total_ttc': montantTotalTTC,
      'statut': statut,
    };
  }

  @override
  String toString() {
    return 'FactureModel{id: $id, nomClient: $relevecompteurId, num_facture: $numFacture, num_compteur: $numCompteur, date_facture: $dateFacture, '
        'total_conso_ht: $totalConsoHT, tarif_m3: $tarifM3, avoir_avant: $avoirAvant, avoir_utilise: $avoirUtilise, '
        'restant_precedant: $restantPrecedant, montant_total_ttc: $montantTotalTTC, statut: $statut }';
  }
}
