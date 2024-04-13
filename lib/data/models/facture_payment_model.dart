class FacturePaymentModel {
  int id;
  int factureId;
  int relevecompteurId;
  double paiement;
  String datePaiement;
  String? statut;
  FacturePaymentModel({
    required this.id,
    required this.factureId,
    required this.relevecompteurId,
    required this.paiement,
    required this.datePaiement,
    this.statut
  });

  factory FacturePaymentModel.fromMap(Map<String, dynamic> map) {
    return FacturePaymentModel(
      id: map['id'] ?? 0,
      factureId: map['facture_id'] ?? 0,
      relevecompteurId: map['relevecompteur_id'] ?? 0,
      paiement: map['paiement'] ?? 0.0,
      datePaiement: map['date_paiement'] ?? '',
      statut: map['statut'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facture_id': factureId,
      'relevecompteur_id': relevecompteurId,
      'paiement': paiement,
      'date_paiement': datePaiement,
      'statut': statut
    };
  }

  factory FacturePaymentModel.fromJson(Map<String, dynamic> json) {
    return FacturePaymentModel(
      id: json['id'] ?? 0,
      factureId: json['facture_id'] ?? 0,
      relevecompteurId: json['relevecompteur_id'] ?? 0,
      paiement: json['paiement'] ?? 0.0,
      datePaiement: json['date_paiement'] ?? '',
      statut: json['statut'], // Statut peut être null, pas besoin de valeur par défaut incompatible
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facture_id': factureId,
      'relevecompteur_id': relevecompteurId,
      'paiement': paiement,
      'date_paiement': datePaiement,
      'statut' : statut
    };
  }

  @override
  String toString() {
    return 'FacturePaymentModel{id: $id, factureId: $factureId, '
        'relevecompteurId: $relevecompteurId, paiement: $paiement, '
        'datePaiement: $datePaiement, statut: $statut}';
  }
}