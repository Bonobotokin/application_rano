import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint("mapas $maps");
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
            status: maps[i]['status'],
            photoAnomalie1: maps[i]['photo_anomalie_1'],
            photoAnomalie2: maps[i]['photo_anomalie_2'],
            photoAnomalie3: maps[i]['photo_anomalie_3'],
            photoAnomalie4: maps[i]['photo_anomalie_4'],
            photoAnomalie5: maps[i]['photo_anomalie_5'],
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
      List<String?> imagePaths,
      ) async {
    try {
      final db = await _niaDatabases.database;

      Map<String, dynamic>? lastAnomalie = await db.query('anomalie').then((value) => value.isNotEmpty ? value.last : null);

      if (lastAnomalie != null) {
        debugPrint("lastAnomalie ${lastAnomalie['id']}" );
        int newIdMc = lastAnomalie['id'] + 1;
        await db.insert(
          'anomalie',
          {
            'id_mc': newIdMc,
            'type_mc': typeMc,
            'date_declaration': dateDeclaration,
            'longitude_mc': longitudeMc,
            'latitude_mc': latitudeMc,
            'description_mc': descriptionMc,
            'client_declare': clientDeclare,
            'cp_commune': cpCommune,
            'commune': commune,
            'status': 4,
            'photo_anomalie_1': imagePaths.isNotEmpty ? imagePaths[0] : null,
            'photo_anomalie_2': imagePaths.length > 1 ? imagePaths[1] : null,
            'photo_anomalie_3': imagePaths.length > 2 ? imagePaths[2] : null,
            'photo_anomalie_4': imagePaths.length > 3 ? imagePaths[3] : null,
            'photo_anomalie_5': imagePaths.length > 4 ? imagePaths[4] : null,
          },
        );
        await _updateAcceuil(db);
        debugPrint('Anomalie insérée avec succès dans la base de données locale');
        // Récupérer les données insérées et les afficher
        final insertedAnomalie = await db.query('anomalie',
            orderBy: 'id DESC', limit: 1); // Récupérer la dernière anomalie insérée
        if (insertedAnomalie.isNotEmpty) {
          debugPrint('Données de la dernière anomalie insérée : $insertedAnomalie');
        } else {
          debugPrint('Aucune donnée n\'a été trouvée pour la dernière anomalie insérée');
        }
      } else {
        debugPrint("Aucune anomalie n'a été trouvée dans la base de données.");

        int newIdMc = 1;
        await db.insert(
          'anomalie',
          {
            'id_mc': newIdMc,
            'type_mc': typeMc,
            'date_declaration': dateDeclaration,
            'longitude_mc': longitudeMc,
            'latitude_mc': latitudeMc,
            'description_mc': descriptionMc,
            'client_declare': clientDeclare,
            'cp_commune': cpCommune,
            'commune': commune,
            'status': 4,
            'photo_anomalie_1': imagePaths.isNotEmpty ? imagePaths[0] : null,
            'photo_anomalie_2': imagePaths.length > 1 ? imagePaths[1] : null,
            'photo_anomalie_3': imagePaths.length > 2 ? imagePaths[2] : null,
            'photo_anomalie_4': imagePaths.length > 3 ? imagePaths[3] : null,
            'photo_anomalie_5': imagePaths.length > 4 ? imagePaths[4] : null,
          },
        );
        await _updateAcceuil(db);
        debugPrint('Anomalie insérée avec succès dans la base de données locale');
        // Récupérer les données insérées et les afficher
        final insertedAnomalie = await db.query('anomalie',
            orderBy: 'id DESC', limit: 1); // Récupérer la dernière anomalie insérée
        if (insertedAnomalie.isNotEmpty) {
          debugPrint('Données de la dernière anomalie insérée : $insertedAnomalie');
        } else {
          debugPrint('Aucune donnée n\'a été trouvée pour la dernière anomalie insérée');
        }
      }
    } catch (e) {
      debugPrint('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
      throw Exception('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
    }
  }


  Future<void> updateAnomalie(
      int? idMc,
      String? typeMc,
      String? dateDeclaration,
      String? longitudeMc,
      String? latitudeMc,
      String? descriptionMc,
      String? clientDeclare,
      String? cpCommune,
      String? commune,
      List<String?> imagePaths,
      ) async {
    try {
      final db = await _niaDatabases.database;

      if (idMc != null) {
        await db.update(
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
            'status': 4,
            'photo_anomalie_1': imagePaths.isNotEmpty ? imagePaths[0] : null,
            'photo_anomalie_2': imagePaths.length > 1 ? imagePaths[1] : null,
            'photo_anomalie_3': imagePaths.length > 2 ? imagePaths[2] : null,
            'photo_anomalie_4': imagePaths.length > 3 ? imagePaths[3] : null,
            'photo_anomalie_5': imagePaths.length > 4 ? imagePaths[4] : null,
          },
          where: 'id_mc = ?',
          whereArgs: [idMc],
        );

        await _updateAcceuil(db);
        debugPrint('Mises a jour Anomalie avec succès dans la base de données locale');
        // Récupérer les données insérées et les afficher
        final insertedAnomalie = await db.query('anomalie',
            orderBy: 'id DESC', limit: 1); // Récupérer la dernière anomalie insérée
        if (insertedAnomalie.isNotEmpty) {
          debugPrint('Données de la dernière anomalie insérée : $insertedAnomalie');
        } else {
          debugPrint('Aucune donnée n\'a été trouvée pour la dernière anomalie insérée');
        } 
      } else {
        debugPrint("Aucune anomalie n'a été trouvée dans la base de données.");
      }
    } catch (e) {
      debugPrint('Échec de l\'enregistrement de l\'anomalie dans la base de données locale: $e');
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


  Future<List<AnomalieModel>> fetchAnomaleDataByIdMc(int idMc) async {
    try {
      final anomalie =  getAnomalieByIdMc(idMc);

      return anomalie;

    } catch (e) {
      // En cas d'erreur lors de la requête HTTP, lancez une exception avec le message d'erreur
      throw Exception('Failed to fetch home page data: $e');
    }
  }

  Future<List<AnomalieModel>> getAnomalieByIdMc(int idMc) async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'anomalie',
        where: 'id_mc = ?',
        whereArgs: [idMc], // Remplacez idMc par la valeur que vous souhaitez utiliser
      );

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
          status: maps[i]['status'],
          photoAnomalie1: maps[i]['photo_anomalie_1'],
          photoAnomalie2: maps[i]['photo_anomalie_2'],
          photoAnomalie3: maps[i]['photo_anomalie_3'],
          photoAnomalie4: maps[i]['photo_anomalie_4'],
          photoAnomalie5: maps[i]['photo_anomalie_5'],
        );
      });
    } catch (e) {
      throw Exception("Failed to get anomalie by idMc data: $e");
    }
  }

  Future<List<ClientModel>> getAllClients() async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT *
      FROM client
    ''');

      // Vérifiez si des données ont été récupérées
      if (rows.isNotEmpty) {
        List<ClientModel> clients = rows.map((row) => ClientModel.fromMap(row)).toList();
        return clients;
      } else {
        throw Exception('Aucune donnée trouvée.');
      }
    } catch (error) {
      throw Exception('Failed to fetch client data: $error');
    }
  }



}