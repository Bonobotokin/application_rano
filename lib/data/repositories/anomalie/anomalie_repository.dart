import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class AnomalieRepository {
  final String baseUrl;
  final NiADatabases _niaDatabases = NiADatabases();

  AnomalieRepository({required this.baseUrl});
  Future<List<AnomalieModel>> fetchAnomaleData(String accessToken) async {
    try {
      final anomalie =  getAnomalieData();

      return anomalie;

    } catch (e) {
      // En cas d'erreur lors de la requête HTTP, lancez une exception avec le message d'erreur
      throw Exception('Failed to fetch home page data: $e');
    }
  }

  Future<List<AnomalieModel>> getAnomalieData() async {
    try {
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
    } catch (e) {
      throw Exception("Failed to get acceuil data: $e");
    }
  }

}