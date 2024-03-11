class CompteurModel {
  final int? id;
  final String marque;
  final String modele;


  CompteurModel({required this.id, required this.marque, required this.modele});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marque': marque,
      'modele': modele,
    };
  }
  factory CompteurModel.fromJson(Map<String, dynamic> json) {
    return CompteurModel(
      id: json['id'],
      marque: json['marque'],
      modele: json['modele'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'marque': marque,
    'modele': modele,
  };


  @override
  String toString() {
    return 'CompteurModel{id: $id, marque: $marque, modele: $modele}';
  }
}
