class FacturePaymentModel {
  int id;
  int factureId;
  int relevecompteurId;
  double paiement;
  String datePaiement;
  FacturePaymentModel({
    required this.id,
    required this.factureId,
    required this.relevecompteurId,
    required this.paiement,
    required this.datePaiement,
  });

  factory FacturePaymentModel.fromMap(Map<String, dynamic> map) {
    return FacturePaymentModel(
      id: map['id'] ?? 0,
      factureId: map['facture_id'] ?? 0,
      relevecompteurId: map['relevecompteur_id'] ?? 0,
      paiement: map['paiement'] ?? 0.0,
      datePaiement: map['date_paiement'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facture_id': factureId,
      'relevecompteur_id': relevecompteurId,
      'paiement': paiement,
      'date_paiement': datePaiement
    };
  }

  factory FacturePaymentModel.fromJson(Map<String, dynamic> json) {
    return FacturePaymentModel(
        id: json['id'] ?? 0,
        factureId: json['facture_id'] ?? 0,
        relevecompteurId: json['relevecompteur_id'] ?? 0,
        paiement: json['paiement'] ?? 0.0,
        datePaiement: json['date_paiement'] ?? ''
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'facture_id': factureId,
      'relevecompteur_id': relevecompteurId,
      'paiement': paiement,
      'date_paiement': datePaiement
    };
  }

  @override
  String toString() {
    return 'FactureModel{id: $id, factureId: $factureId, relevecompteurId: $relevecompteurId, paiement: $paiement, datePaiement: $datePaiement}';
  }
}