class ClientModel {
  final int? id;
  final String nom;
  final String prenom;
  final String adresse;
  final String commune;
  final String region;
  final String telephone_1;
  String? telephone_2;
  final int actif;

  ClientModel({
    this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.commune,
    required this.region,
    required this.telephone_1,
    this.telephone_2,
    required this.actif,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      adresse: json['adresse'] ?? '',
      commune: json['commune'] ?? '',
      region: json['region'] ?? '',
      telephone_1: json['telephone_1'] ?? '',
      telephone_2: json['telephone_2'],
      actif: json['actif'] ?? 0,
    );
  }
  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? 0,
      nom: map['nom'] ?? '',
      prenom: map['prenom'] ?? '',
      adresse: map['adresse'] ?? '',
      commune: map['commune'] ?? '',
      region: map['region'] ?? '',
      telephone_1: map['telephone_1'] ?? '',
      telephone_2: map['telephone_2'],
      actif: map['actif'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'adresse': adresse,
    'commune': commune,
    'region': region,
    'telephone_1': telephone_1,
    'telephone_2': telephone_2,
    'actif': actif,
  };

  Map<String, dynamic> toMap() => {

    'id': id,
    'nom': nom,
    'prenom': prenom,
    'adresse': adresse,
    'commune': commune,
    'region': region,
    'telephone_1': telephone_1,
    'telephone_2': telephone_2,
    'actif': actif,

  };
  @override
  String toString() {
    return 'ClientModel{id: $id, nom: $nom, prenom: $prenom, adresse: $adresse, commune: $commune, region: $region, telephone_1: $telephone_1, telephone_2: $telephone_2, actif: $actif}';
  }
}
