class AnomalieModel{
  int? id;
  int idMc;
  String? typeMc;
  String? dateDeclaration;
  String? longitudeMc;
  String? latitudeMc;
  String? descriptionMc;
  String? clientDeclare;
  String? cpCommune;
  String? commune;
  int? status;

  AnomalieModel({
    this.id,
    required this.idMc,
    this.typeMc,
    this.dateDeclaration,
    this.longitudeMc,
    this.latitudeMc,
    this.descriptionMc,
    this.clientDeclare,
    this.cpCommune,
    this.commune,
    this.status,
  });
  factory AnomalieModel.fromJson(Map<String, dynamic> json) {
    return AnomalieModel(
      id: json['id'] ?? 0,
      idMc: json['id_mc'] ?? 0,
      typeMc: json['type_mc'] ?? '',
      dateDeclaration: json['date_declaration'] ?? '',
      longitudeMc: json['longitude_mc'] ?? '',
      latitudeMc: json['latitude_mc'] ?? '',
      descriptionMc: json['description_mc'] ?? '',
      clientDeclare: json['client_declare'] ?? '',
      cpCommune: json['cp_commune'] ?? '',
      commune: json['commune'] ?? '',
      status: json['status'] ?? 0,
    );
  }


  Map<String, dynamic> toJson() => {
    'id': id,
    'id_mc': idMc,
    'type_mc': typeMc,
    'date_declaration': dateDeclaration,
    'longitude_mc': longitudeMc,
    'latitude_mc': latitudeMc,
    'description_mc': descriptionMc,
    'client_declare': clientDeclare,
    'cp_commune': cpCommune,
    'commune': commune,
    'status': status,
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'id_mc': idMc,
    'type_mc': typeMc,
    'date_declaration': dateDeclaration,
    'longitude_mc': longitudeMc,
    'latitude_mc': latitudeMc,
    'description_mc': descriptionMc,
    'client_declare': clientDeclare,
    'cp_commune': cpCommune,
    'commune': commune,
    'status': status,
  };

  @override
  String toString() {
    return 'AnomalieMOdel{id: $id, idMc: $idMc, type_mc: $typeMc, date_declaration: $dateDeclaration, '
        'longitude_mc: $longitudeMc, latitudeMc: $latitudeMc, descriptionMc: $descriptionMc, clientDeclare: $clientDeclare, '
        'cpCommune: $cpCommune, commune: $commune, status: $status }';
  }
}