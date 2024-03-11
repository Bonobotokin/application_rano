class ClientModel {
  final int id;
  final String nom;
  final String prenom;
  final String adresse;
  final String commune;
  final String region;
  final String telephone_1;
  final String? telephone_2;
  final int actif;

  ClientModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.commune,
    required this.region,
    required this.telephone_1,
    required this.telephone_2,
    required this.actif,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']  ?? 0,
      nom: json['nom']  ?? 0,
      prenom: json['prenom']  ?? 0,
      adresse: json['adresse'] ?? 0,
      commune: json['commune'] ?? 0,
      region: json['region'] ?? 0,
      telephone_1: json['tephone1'] ?? 0,
      telephone_2: json['tephone2'] ?? 0,
      actif: json['actif'] ?? 0,
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
