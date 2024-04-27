import 'dart:io';

class AnomalieModel{
  int? id;
  int? idMc;
  String? typeMc;
  String? dateDeclaration;
  String? longitudeMc;
  String? latitudeMc;
  String? descriptionMc;
  String? clientDeclare;
  String? cpCommune;
  String? commune;
  int? status;
  String? photoAnomalie1;
  String? photoAnomalie2;
  String? photoAnomalie3;
  String? photoAnomalie4;
  String? photoAnomalie5;

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
    this.photoAnomalie1,
    this.photoAnomalie2,
    this.photoAnomalie3,
    this.photoAnomalie4,
    this.photoAnomalie5,
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
      photoAnomalie1: json['photo_anomalie_1'] ?? '',
      photoAnomalie2: json['photo_anomalie_2'] ?? '',
      photoAnomalie3: json['photo_anomalie_3'] ?? '',
      photoAnomalie4: json['photo_anomalie_4'] ?? '',
      photoAnomalie5: json['photo_anomalie_5'] ?? '',
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
    'photo_anomalie_1': photoAnomalie1,
    'photo_anomalie_2': photoAnomalie2,
    'photo_anomalie_3': photoAnomalie3,
    'photo_anomalie_4': photoAnomalie4,
    'photo_anomalie_5': photoAnomalie5,
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
    'photo_anomalie_1': photoAnomalie1,
    'photo_anomalie_2': photoAnomalie2,
    'photo_anomalie_3': photoAnomalie3,
    'photo_anomalie_4': photoAnomalie4,
    'photo_anomalie_5': photoAnomalie5,
  };

  @override
  String toString() {
    return 'AnomalieMOdel{id: $id, idMc: $idMc, type_mc: $typeMc, date_declaration: $dateDeclaration, '
        'longitude_mc: $longitudeMc, latitudeMc: $latitudeMc, descriptionMc: $descriptionMc, clientDeclare: $clientDeclare, '
        'cpCommune: $cpCommune, commune: $commune, status: $status, photoAnomalie1: $photoAnomalie1, photoAnomalie2: $photoAnomalie2, '
        'photoAnomalie3: $photoAnomalie3, photoAnomalie4: $photoAnomalie4, photoAnomalie5: $photoAnomalie5, }';
  }
  String? getPhotoAnomalie(int index) {
    switch (index) {
      case 1:
        return photoAnomalie1;
      case 2:
        return photoAnomalie2;
      case 3:
        return photoAnomalie3;
      case 4:
        return photoAnomalie4;
      case 5:
        return photoAnomalie5;
      default:
        return null;
    }
  }
}