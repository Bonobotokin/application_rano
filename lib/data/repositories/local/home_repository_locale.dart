import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/home_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class HomeRepositoryLocale {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<HomeModel>> getAcceuilData() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('acceuil');

      return List.generate(maps.length, (i) {
        return HomeModel(
          totaleAnomalie: maps[i]['totale_anomalie'],
          realise: maps[i]['realise'],
          nombreTotalCompteur: maps[i]['nombre_total_compteur'],
          nombreReleverEffectuer: maps[i]['nombre_relever_effectuer'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get acceuil data: $e");
    }
  }
}
