import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:sqflite/sqflite.dart';

class AnomalieRepositoryLoale {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<AnomalieModel>> getAnomalieDataFromLocalDatabase() async {

    final Database db = await _niaDatabases.database;
    final List<Map<String, dynamic>> maps = await db.query('anomalie');
    return List.generate(maps.length, (i) {
      return AnomalieModel(
          id: maps[i]['id'],
          idMc: maps[i]['id_mc'],
          typeMc: maps[i]['type_mc'],
          dateDeclaration: maps[i]['date_declaration'],
          longitudeMc: maps[i]['longitude_mc'],
          latitudeMc: maps[i]['latitude_mc'],
          descriptionMc: maps[i]['description_mc'],
          clientDeclare: maps[i]['client_declare'],
          cpCommune: maps[i]['cp_commune'],
          commune: maps[i]['commune'],
          status: maps[i]['status']
      );
    });
  }
}