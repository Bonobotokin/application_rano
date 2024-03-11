class ContratModel {
  final int id; // Changer en int
  final String numeroContrat;
  final int clientId;
  final String dateDebut;
  final String? dateFin;
  final String adresseContrat;
  final String paysContrat;

  ContratModel({
    required this.id,
    required this.numeroContrat,
    required this.clientId,
    required this.dateDebut,
    this.dateFin,
    required this.adresseContrat,
    required this.paysContrat,
  });

  // factory ContratModel.fromJson(Map<String, dynamic> json) {
  //   return ContratModel(
  //     id: json['id'],
  //     numeroContrat: json['numero_contrat'],
  //     dateDebut: json['date_debut'],
  //     dateFin: json['date_fin'] != '' ? json['date_fin'] : null,
  //     adresseContrat: json['adresse_contrat'],
  //     paysContrat: json['pays_contrat'],
  //   );
  // }
  factory ContratModel.fromJson(Map<String, dynamic> json) {
    return ContratModel(
      id: json['id'] != null ? (json['id'] is String ? int.tryParse(json['id'] ?? '0') ?? 0 : json['id']) : 0,
      numeroContrat: json['numero_contrat'] ?? '',
      clientId: json['client_id'],
      dateDebut: json['date_debut'] ?? '',
      dateFin: json['date_fin'] != null ? json['date_fin'] : null,
      adresseContrat: json['adresse_contrat'] ?? '',
      paysContrat: json['pays_contrat'] ?? '',
    );
  }



  Map<String, dynamic> toJson() => {
    'id': id,
    'numero_contrat': numeroContrat,
    'client_id': clientId,
    'date_debut': dateDebut,
    'date_fin': dateFin,
    'adresse_contrat': adresseContrat,
    'pays_contrat': paysContrat,
  };

  Map<String, dynamic> toMap()  {
    return {
      'id': id,
      'numero_contrat': numeroContrat,
      'client_id': clientId,
      'date_debut': dateDebut,
      'date_fin': dateFin,
      'adresse_contrat': adresseContrat,
      'pays_contrat': paysContrat,
    };
  }
  @override
  String toString() {
    return 'ContratModel{id: $id, numeroContrat: $numeroContrat, clientId: $clientId, dateDebut: $dateDebut, dateFin: $dateFin, adresseContrat: $adresseContrat, paysContrat: $paysContrat}';
  }
}
