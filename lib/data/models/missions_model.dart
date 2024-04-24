class MissionModel {
  int? id;
  String? nomClient;
  String? prenomClient;
  String? adresseClient;
  int? numCompteur;
  int? consoDernierReleve;
  int? volumeDernierReleve;
  String? dateReleve;
  int? statut;

  MissionModel({
    this.id,
    this.nomClient,
    this.prenomClient,
    this.adresseClient,
    this.numCompteur,
    this.consoDernierReleve,
    this.volumeDernierReleve,
    this.dateReleve,
    this.statut,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      nomClient: json['nom_client'],
      prenomClient: json['prenom_client'],
      adresseClient: json['adresse_client'],
      numCompteur: json['num_compteur'] is String ? int.tryParse(json['num_compteur']) : json['num_compteur'],
      consoDernierReleve: json['conso_dernier_releve'] is String ? int.tryParse(json['conso_dernier_releve']) : json['conso_dernier_releve'],
      volumeDernierReleve: json['volume_dernier_releve'] is String ? int.tryParse(json['volume_dernier_releve']) : json['volume_dernier_releve'],
      dateReleve: json['date_releve'],
      statut: json['statut'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_client': nomClient,
      'prenom_client': prenomClient,
      'adresse_client': adresseClient,
      'num_compteur': numCompteur,
      'conso_dernier_releve': consoDernierReleve,
      'volume_dernier_releve': volumeDernierReleve,
      'date_releve': dateReleve,
      'statut': statut,
    };
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom_client': nomClient,
      'prenom_client': prenomClient,
      'adresse_client': adresseClient,
      'num_compteur': numCompteur,
      'conso_dernier_releve': consoDernierReleve,
      'volume_dernier_releve': volumeDernierReleve,
      'date_releve': dateReleve,
      'statut': statut,
    };
  }

  @override
  String toString() {
    return 'MissionModel{id: $id, nomClient: $nomClient, prenomClient: $prenomClient, adresseClient: $adresseClient, numCompteur: $numCompteur, consoDernierReleve: $consoDernierReleve, '
        'volumeDernierReleve: $volumeDernierReleve, dateReleve: $dateReleve, '
        'statut: $statut';
  }
}
