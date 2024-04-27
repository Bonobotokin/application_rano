class PhotoAnomalieModel {
  int? id;
  String? photoAnomalie1;
  String? photoAnomalie2;
  String? photoAnomalie3;
  String? photoAnomalie4;
  String? photoAnomalie5;
  int? mainCouranteId;

  PhotoAnomalieModel({
    this.id,
    this.photoAnomalie1,
    this.photoAnomalie2,
    this.photoAnomalie3,
    this.photoAnomalie4,
    this.photoAnomalie5,
    this.mainCouranteId,
  });

  factory PhotoAnomalieModel.fromJson(Map<String, dynamic> json) {
    return PhotoAnomalieModel(
      id: json['id'] ?? 0,
      photoAnomalie1: json['photo_anomalie_1'] ?? '',
      photoAnomalie2: json['photo_anomalie_2'] ?? '',
      photoAnomalie3: json['photo_anomalie_3'] ?? '',
      photoAnomalie4: json['photo_anomalie_4'] ?? '',
      photoAnomalie5: json['photo_anomalie_5'] ?? '',
      mainCouranteId: json['main_courante_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photo_anomalie_1': photoAnomalie1,
      'photo_anomalie_2': photoAnomalie2,
      'photo_anomalie_3': photoAnomalie3,
      'photo_anomalie_4': photoAnomalie4,
      'photo_anomalie_5': photoAnomalie5,
      'main_courante_id': mainCouranteId,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'photo_anomalie_1': photoAnomalie1,
      'photo_anomalie_2': photoAnomalie2,
      'photo_anomalie_3': photoAnomalie3,
      'photo_anomalie_4': photoAnomalie4,
      'photo_anomalie_5': photoAnomalie5,
      'main_courante_id': mainCouranteId,
    };
  }

  factory PhotoAnomalieModel.fromMap(Map<String, dynamic> map) {
    return PhotoAnomalieModel(
      id: map['id'],
      photoAnomalie1: map['photo_anomalie_1'],
      photoAnomalie2: map['photo_anomalie_2'],
      photoAnomalie3: map['photo_anomalie_3'],
      photoAnomalie4: map['photo_anomalie_4'],
      photoAnomalie5: map['photo_anomalie_5'],
      mainCouranteId: map['main_courante_id'],
    );
  }

  @override
  String toString() {
    return 'PhotoAnomalieModel{id: $id,photoAnomalie1: $photoAnomalie1, photoAnomalie2: $photoAnomalie2, '
        'photoAnomalie3: $photoAnomalie3, photoAnomalie4: $photoAnomalie4, photoAnomalie5: $photoAnomalie5, mainCouranteId: $mainCouranteId}';
  }
}
