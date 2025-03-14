class CommentaireModel {
  final int? id;
  final int idMc;
  final int idSuivie;
  final DateTime dateSuivie;
  final String commentaireSuivie;
  final int statut;

  CommentaireModel({
    this.id,
    required this.idMc,
    required this.idSuivie,
    required this.dateSuivie,
    required this.commentaireSuivie,
    required this.statut,
  });

  factory CommentaireModel.fromJson(Map<String, dynamic> json) {
    return CommentaireModel(
      id: json['id'] ?? 0,
      idMc: json['id_mc'] ?? 0,
      idSuivie: json['id_suivie'] ?? 0,
      dateSuivie: DateTime.parse(json['date_suivie']),
      commentaireSuivie: json['commentaire_suivie'] ?? '',
      statut: json['statut'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_mc': idMc,
      'id_suivie': idSuivie,
      'date_suivie': dateSuivie.toIso8601String(),
      'commentaire_suivie': commentaireSuivie,
      'statut': statut,
    };
  }
  Map<String, dynamic> toMapWithoutId() {
    return {
      'id_mc': idMc,
      'id_suivie': idSuivie,
      'date_suivie': dateSuivie.toIso8601String(),
      'commentaire_suivie': commentaireSuivie,
      'statut': statut,
    };
  }
  factory CommentaireModel.fromMap(Map<String, dynamic> map) {
    return CommentaireModel(
      id: map['id'] ?? 0,
      idMc: map['id_mc'] ?? 0,
      idSuivie: map['id_suivie'] ?? 0,
      dateSuivie: DateTime.parse(map['date_suivie']),
      commentaireSuivie: map['commentaire_suivie'] ?? '',
      statut: map['statut'] ?? 0,
    );
  }

  CommentaireModel copy({
    int? id,
    int? idMc,
    int? idSuivie,
    DateTime? dateSuivie,
    String? commentaireSuivie,
    int? statut,
  }) {
    return CommentaireModel(
      id: id ?? this.id,
      idMc: idMc ?? this.idMc,
      idSuivie: idSuivie ?? this.idSuivie,
      dateSuivie: dateSuivie ?? this.dateSuivie,
      commentaireSuivie: commentaireSuivie ?? this.commentaireSuivie,
      statut: statut ?? this.statut,
    );
  }

  @override
  String toString() {
    return 'Commentaire{id: $id, idMc: $idMc, idSuivie: $idSuivie, dateSuivie: $dateSuivie, commentaireSuivie: $commentaireSuivie, statut: $statut}';
  }
}
