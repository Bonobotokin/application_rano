class RelevesModel {
  final int? id;
  final int? idReleve;
  final int compteurId;
  final int contratId;
  final int clientId;
  final String dateReleve;
  final int volume;
  final int conso;
  final String etatFacture;
  final String imageCompteur;

  RelevesModel({
    this.id,
    required this.idReleve,
    required this.compteurId,
    required this.contratId,
    required this.clientId,
    required this.dateReleve,
    required this.volume,
    required this.conso,
    required this.etatFacture,
    required this.imageCompteur,
  });

  factory RelevesModel.fromMap(Map<String, dynamic> map) {
    return RelevesModel(
      id: map['id'],
      idReleve: map['id_releve'],
      compteurId: map['compteur_id'],
      contratId: map['contrat_id'],
      clientId: map['client_id'],
      dateReleve: map['date_releve'],
      volume: map['volume'],
      conso: map['conso'],
      etatFacture: map['etatFacture'],
      imageCompteur: map['image_compteur'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_releve': idReleve,
      'compteur_id': compteurId,
      'contrat_id': contratId,
      'client_id': clientId,
      'date_releve': dateReleve,
      'volume': volume,
      'conso': conso,
      'etatFacture': etatFacture,
      'image_compteur': imageCompteur, //
    };
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_releve': idReleve,
      'compteur_id': compteurId,
      'contrat_id': contratId,
      'client_id': clientId,
      'date_releve': dateReleve,
      'volume': volume,
      'conso': conso,
      'etatFacture': etatFacture,
      'image_compteur': imageCompteur,
    };
  }

  factory RelevesModel.fromJson(Map<String, dynamic> json) {
    return RelevesModel(
      id: json['id'] ?? 0,
      idReleve: json['id_releve'] ?? 0,
      compteurId: json['compteur_id'] ?? 0,
      contratId: json['contrat_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      dateReleve: json['date_releve'] ?? '',
      volume: json['volume'] ?? 0,
      conso: json['conso'] ?? 0,
      etatFacture: json['etatFacture'] ?? '',
      imageCompteur: json['image_compteur'] ?? '',
    );
  }

  @override
  String toString() {
    return 'RelevesModel{id: $id, idReleve: $idReleve, compteur_id: $compteurId, contrat_id: $contratId, client_id: $clientId, '
        'date_releve: $dateReleve, volume: $volume, conso: $conso , etatFacture: $etatFacture, image_compteur: $imageCompteur }';
  }
}
