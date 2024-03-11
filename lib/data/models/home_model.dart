class HomeModel {
  final int totaleAnomalie;
  final int realise;
  final int nombreTotalCompteur;
  final int nombreReleverEffectuer;

  HomeModel({
    required this.totaleAnomalie,
    required this.realise,
    required this.nombreTotalCompteur,
    required this.nombreReleverEffectuer,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      totaleAnomalie: json['totale_anomalie'],
      realise: json['realise'],
      nombreTotalCompteur: json['nombre_total_compteur'],
      nombreReleverEffectuer: json['nombre_relever_effectuer'],
    );
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      totaleAnomalie: map['totale_anomalie'],
      realise: map['realise'],
      nombreTotalCompteur: map['nombre_total_compteur'],
      nombreReleverEffectuer: map['nombre_relever_effectuer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totale_anomalie': totaleAnomalie,
      'realise': realise,
      'nombre_total_compteur': nombreTotalCompteur,
      'nombre_relever_effectuer': nombreReleverEffectuer,
    };
  }
}
