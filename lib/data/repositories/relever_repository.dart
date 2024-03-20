import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/models/releves_model.dart';

class ReleverRepository {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<void> getReleverByDate() async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM releves
      ''');
      print("Relever Data getByDate: $rows");
      if (rows.isNotEmpty) {
        final releves = rows.map((row) => RelevesModel(
          id: row['id'],
          compteurId: int.parse(row['compteur_id'].toString()),
          contratId: row['contrat_id'],
          clientId: row['client_id'],
          dateReleve: row['date_releve'] ?? '',
          volume: row['volume'] ?? 0,
          conso: row['conso'] ?? 0,
        )).toList();
        // return {'releves': releves};
      } else {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (e) {
      print('Error fetching releves: $e');
      throw Exception('Failed to get releves data by date from local database: $e');
    }
  }
}
