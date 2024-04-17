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
            idMc: maps[i]['id_mc'] ?? 0 ,
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

  Future<void> createAnomalie(
      String typeMc,
      String dateDeclaration,
      String longitudeMc,
      String latitudeMc,
      String descriptionMc,
      String clientDeclare,
      String cpCommune,
      String commune,
      String status,
      ) async {
    try {
      final db = await _niaDatabases.database;
      await db.insert(
        'anomalie',
        {
          'type_mc': typeMc,
          'date_declaration': dateDeclaration,
          'longitude_mc': longitudeMc,
          'latitude_mc': latitudeMc,
          'description_mc': descriptionMc,
          'client_declare': clientDeclare,
          'cp_commune': cpCommune,
          'commune': commune,
          'status': status,
        },
      );
      await _updateAcceuil(db);
      print('Anomalie insérée avec succès dans la base de données locale');
    } catch (e) {
      print('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
      throw Exception('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
    }
  }

  Future<void> _updateAcceuil(Database db) async {
    try {
      // Récupérer le nombre total d'anomalies avec le statut 0, 1 ou 2
      final nonTraite = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (0)
    '''));
      final enCours = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (1)
    '''));
      final realiser = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie WHERE status IN (2)
    '''));

      // Récupérer le nombre total d'anomalies
      final totaleAnomalieResult = await db.rawQuery('''
      SELECT COUNT(*) FROM anomalie
    ''');
      final totaleAnomalie = Sqflite.firstIntValue(totaleAnomalieResult);

      // Mettre à jour les valeurs correspondantes dans la table "acceuil"
      await db.rawUpdate('''
      UPDATE acceuil SET non_traite = ?, en_cours = ?, realise = ?, totale_anomalie = ?
    ''', [nonTraite, enCours, realiser, totaleAnomalie]);
    } catch (e) {
      throw Exception('Échec de la mise à jour de nombre_relever_effectuer: $e');
    }
  }





}