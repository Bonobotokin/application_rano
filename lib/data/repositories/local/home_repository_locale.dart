import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/home_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class HomeRepositoryLocale {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<HomeModel>> getAcceuilData() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('acceuil');
      print("verrifiHome $maps");
      return List.generate(maps.length, (i) {
        return HomeModel(
          nonTraite: maps[i]['non_traite'],
          enCours: maps[i]['en_cours'],
          totaleAnomalie: maps[i]['totale_anomalie'],
          realise: maps[i]['realise'],
          nombreTotalCompteur: maps[i]['nombre_total_compteur'],
          nombreReleverEffectuer: maps[i]['nombre_relever_effectuer'],
          nombreTotalFactureImpayer: maps[i]['nombre_total_facture_impayer'],
          nombreTotalFacturePayer: maps[i]['nombre_total_facture_payer'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get acceuil data: $e");
    }
  }
}
