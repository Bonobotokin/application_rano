class RelevesModel {
  final int? id;
  final int compteurId;
  final int contratId;
  final int clientId;
  final String dateReleve;
  final int volume;
  final int conso;

  RelevesModel({
    this.id,
    required this.compteurId,
    required this.contratId,
    required this.clientId,
    required this.dateReleve,
    required this.volume,
    required this.conso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'compteur_id': compteurId,
      'contrat_id': contratId,
      'client_id': clientId,
      'date_releve': dateReleve,
      'volume': volume,
      'conso': conso,
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'compteur_id': compteurId,
      'contrat_id': contratId,
      'client_id': clientId,
      'date_releve': dateReleve,
      'volume': volume,
      'conso': conso,
    };
  }

  factory RelevesModel.fromJson(Map<String, dynamic> json) {
    return RelevesModel(
      id: json['id_releve'] != null ? json['id_releve'] : 0,
      compteurId: json['compteur_id'] != null ? json['compteur_id'] : 0,
      contratId: json['contrat_id'] != null ? json['contrat_id'] : 0,
      clientId: json['client_id'] != null ? json['client_id'] : 0,
      dateReleve: json['date_releve'] != null ? json['date_releve'] : '',
      volume: json['volume'] != null ? json['volume'] : 0,
      conso: json['conso'] != null ? json['conso'] : 0,
    );
  }



  String toString() {
    return 'RelevesModel{id: $id, compteur_id: $compteurId, contrat_id: $contratId, client_id: $clientId, date_releve: $dateReleve, volume: $volume, conso: $conso}';
  }
}
