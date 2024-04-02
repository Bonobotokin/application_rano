class HomeModel {
  final int nonTraite;
  final int enCours;
  final int totaleAnomalie;
  final int realise;
  final int nombreTotalCompteur;
  final int nombreReleverEffectuer;
  final int nombreTotalFactureImpayer;
  final int nombreTotalFacturePayer;

  HomeModel({
    required this.nonTraite,
    required this.enCours,
    required this.totaleAnomalie,
    required this.realise,
    required this.nombreTotalCompteur,
    required this.nombreReleverEffectuer,
    required this.nombreTotalFactureImpayer,
    required this.nombreTotalFacturePayer,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      nonTraite: json['non_traite'],
      enCours: json['en_cours'],
      totaleAnomalie: json['totale_anomalie'],
      realise: json['realise'],
      nombreTotalCompteur: json['nombre_total_compteur'],
      nombreReleverEffectuer: json['nombre_relever_effectuer'],
      nombreTotalFactureImpayer: json['nombre_total_facture_impayer'],
      nombreTotalFacturePayer: json['nombre_total_facture_payer'],
    );
  }

  factory HomeModel.fromMap(Map<String, dynamic> map) {
    return HomeModel(
      nonTraite: map['non_traite'],
      enCours: map['en_cours'],
      totaleAnomalie: map['totale_anomalie'],
      realise: map['realise'],
      nombreTotalCompteur: map['nombre_total_compteur'],
      nombreReleverEffectuer: map['nombre_relever_effectuer'],
      nombreTotalFactureImpayer: map['nombre_total_facture_impayer'],
      nombreTotalFacturePayer: map['nombre_total_facture_payer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'non_traite': nonTraite,
      'en_cours': enCours,
      'totale_anomalie': totaleAnomalie,
      'realise': realise,
      'nombre_total_compteur': nombreTotalCompteur,
      'nombre_relever_effectuer': nombreReleverEffectuer,
      'nombre_total_facture_impayer': nombreTotalFactureImpayer,
      'nombre_total_facture_payer': nombreTotalFacturePayer,
    };
  }

  @override
  String toString() {
    return 'ClientModel{nonTraite: $nonTraite, enCours: $enCours, totaleAnomalie: $totaleAnomalie, realise: $realise, nombreTotalCompteur: $nombreTotalCompteur, nombreReleverEffectuer: $nombreReleverEffectuer, nombreTotalFactureImpayer: $nombreTotalFactureImpayer, nombreTotalFacturePayer: $nombreTotalFacturePayer}';
  }
}
