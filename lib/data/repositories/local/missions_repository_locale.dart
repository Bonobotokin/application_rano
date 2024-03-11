import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class MissionsRepositoryLocale {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<MissionModel>> getMissionsDataFromLocalDatabase() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('missions');

      return List.generate(maps.length, (i) {
        return MissionModel(
          id: maps[i]['id'],
          nomClient: maps[i]['nom_client'],
          prenomClient: maps[i]['prenom_client'],
          adresseClient: maps[i]['adresse_client'],
          numCompteur: maps[i]['num_compteur'],
          consoDernierReleve: maps[i]['conso_dernier_releve'],
          volumeDernierReleve: maps[i]['volume_dernier_releve'],
          dateReleve: maps[i]['date_releve'],
          statut: maps[i]['statut'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get missions data from local database: $e");
    }
  }
}
