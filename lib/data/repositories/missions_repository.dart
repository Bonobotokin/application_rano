import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'local/missions_repository_locale.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:intl/intl.dart';

class MissionsRepository {
  final String baseUrl;
  final NiADatabases _niaDatabases = NiADatabases();

  MissionsRepository({required this.baseUrl});

  Future<List<MissionModel>> fetchMissions(String accessToken) async {
    try {
      return MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();
    } catch (e) {
      throw Exception('Failed to fetch missions: $e');
    }
  }
  /*
  *
  * Creat Insert Mission Relever
  * */
  Future<void> createMission(
      String missionId,
      String adresseClient,
      String volumeValue,
      String date,
      ) async {
    try {
      final db = await _niaDatabases.database;

      // Vérifier si la mission existe déjà dans la base de données
      final existingMissions = await db.query(
        'missions',
        where: 'num_compteur = ?',
        whereArgs: [missionId],
      );

      if (existingMissions.isNotEmpty) {
        // Extraire la première (et seule) mission existante
        final existingMission = existingMissions.first;

        // Vérifier si le champ 'volume_dernier_releve' existe et n'est pas null
        if (existingMission.containsKey('volume_dernier_releve') &&
            existingMission['volume_dernier_releve'] != null) {
          // Effectuer la soustraction uniquement si le champ 'volume_dernier_releve' n'est pas null
          final updatedConsoDernierReleve =
              (existingMission['volume_dernier_releve'] as int) -
                  int.parse(volumeValue);

          // Mise à jour de la mission existante
          await db.update(
            'missions',
            {
              'conso_dernier_releve': updatedConsoDernierReleve,
              'volume_dernier_releve': volumeValue,
              'date_releve': date,
              'statut': 1
              // Ajoutez d'autres champs à mettre à jour si nécessaire
            },
            where: 'num_compteur = ?',
            whereArgs: [missionId],
          );

          // Appel de la fonction insertNewReleveFromExistingData
          await insertNewReleveFromExistingData(
            db,
            missionId,
            volumeValue,
            date,
          );

          print(
              'Mission mise à jour avec succès dans la base de données locale');
        } else {
          // Le champ 'volume_dernier_releve' est null, ne pas effectuer la mise à jour
          print(
              'Le champ volume_dernier_releve est null. Impossible de mettre à jour la mission.');
        }
      }
    } catch (e) {
      print('Failed to save mission to local database: $e');
      throw Exception('Failed to save mission to local database: $e');
    }
  }

  Future<void> insertNewReleveFromExistingData(
      Database db,
      String compteurId,
      String volumeValue,
      String date,
      ) async {
    try {
      // Récupérer le dernier relevé avec le compteur_id donné
      Map<String, dynamic>? latestReleve = await db.query(
        'releves',
        where: 'compteur_id = ?',
        whereArgs: [compteurId],
      ).then((value) => value.isNotEmpty ? value.last : null);

      if (latestReleve != null) {
        // Calculer la consommation en soustrayant le nouveau volume du volume du dernier relevé
        int consoValue = (int.parse(volumeValue) - latestReleve['volume']).toInt();

        // Insérer les données de relevé dans une autre table (par exemple, une table appelée "releves")
        await db.insert(
          'releves',
          {
            'compteur_id': latestReleve['compteur_id'],
            'contrat_id': latestReleve['contrat_id'],
            'client_id': latestReleve['client_id'],
            'date_releve': date,
            'volume': volumeValue,
            'conso': consoValue,
            // Ajoutez d'autres champs si nécessaire
          },
        );
      } else {
        // Le dernier relevé n'existe pas, traiter ce cas en conséquence
        print('Aucun relevé trouvé pour le compteur avec l\'ID: $compteurId');
      }

      print('Insertion de nouveau relevé à partir du dernier relevé réussie.');
    } catch (e) {
      throw Exception('Failed to insert new releve from existing data: $e');
    }
  }

  /*
  * Update Mission and Relver
  * */

  Future<void> UpdateMission(
      String missionId,
      String adresseClient,
      String volumeValue,
      String date,
      ) async {
    try {
      final db = await _niaDatabases.database;

      // Vérifier si la mission existe déjà dans la base de données
      final existingMissions = await db.query(
        'missions',
        where: 'num_compteur = ?',
        whereArgs: [missionId],
      );

      if (existingMissions.isNotEmpty) {
        // Extraire la première (et seule) mission existante
        final existingMission = existingMissions.first;

        // Vérifier si le champ 'volume_dernier_releve' existe et n'est pas null
        if (existingMission.containsKey('volume_dernier_releve') &&
            existingMission['volume_dernier_releve'] != null) {
          // Effectuer la soustraction uniquement si le champ 'volume_dernier_releve' n'est pas null
          final updatedConsoDernierReleve =
              (existingMission['volume_dernier_releve'] as int) -
                  int.parse(volumeValue);

          // Mise à jour de la mission existante
          await db.update(
            'missions',
            {
              'conso_dernier_releve': updatedConsoDernierReleve,
              'volume_dernier_releve': volumeValue,
              'date_releve': date,
              'statut': 1
              // Ajoutez d'autres champs à mettre à jour si nécessaire
            },
            where: 'num_compteur = ?',
            whereArgs: [missionId],
          );

          // Appel de la fonction insertNewReleveFromExistingData
          await updateReleveFromExistingData(
            db,
            missionId,
            volumeValue,
            date,
          );

          print(
              'Mission mise à jour avec succès dans la base de données locale');
        } else {
          // Le champ 'volume_dernier_releve' est null, ne pas effectuer la mise à jour
          print(
              'Le champ volume_dernier_releve est null. Impossible de mettre à jour la mission.');
        }
      }
    } catch (e) {
      print('Failed to save mission to local database: $e');
      throw Exception('Failed to save mission to local database: $e');
    }
  }


  Future<void> updateReleveFromExistingData(
      Database db,
      String compteurId,
      String volumeValue,
      String date,
      ) async {
    try {
      // Obtenir la date actuelle
      DateTime currentDate = DateTime.now();

      // Récupérer la date du mois précédent
      DateTime previousMonthDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day);

      String formattedPreviousMonthDate = DateFormat('yyyy-MM').format(previousMonthDate);
      print("moiss $formattedPreviousMonthDate");
      // Récupérer le dernier relevé avec le compteur_id donné pour le mois en cours
      Map<String, dynamic>? latestMonthReleve = await db.query(
        'releves',
        where: 'compteur_id = ? AND strftime("%Y-%m", date_releve) = ?',
        whereArgs: [compteurId, formattedPreviousMonthDate],
      ).then((value) => value.isNotEmpty ? value.last : null);

      print("Laste Relves $latestMonthReleve");
      String formattedCurrentDate = DateFormat('yyyy-MM').format(currentDate);

      List<Map<String, dynamic>>  RelevesNow = await db.query(
        'releves',
        where: 'compteur_id = ? AND strftime("%Y-%m", date_releve) = ?',
        whereArgs: [compteurId, formattedCurrentDate],
      );

      if (RelevesNow.isNotEmpty && latestMonthReleve != null && latestMonthReleve.isNotEmpty) {
        int RelevesNowId = RelevesNow.last['id'] ?? 0; // Utilisation de l'opérateur de null-aware pour éviter les erreurs si 'RelevesNow' ou 'latestMonthReleve' est null
        int latestMonthReleveId = latestMonthReleve['id'] ?? 0; // Utilisation de l'opérateur de null-aware pour éviter les erreurs si 'RelevesNow' ou 'latestMonthReleve' est null

        int consoValue = (int.parse(volumeValue) - latestMonthReleve['volume']).toInt();
        await db.update(
          'releves',
          {
            'date_releve': date,
            'volume': volumeValue,
            'conso': consoValue,
            // Ajoutez d'autres champs à mettre à jour si nécessaire
          },
          where: 'id = ?',
          whereArgs: [RelevesNowId],
        );
        print('Mise à jour du relevé à partir du dernier relevé réussie.');
      }


    } catch (e) {
      throw Exception('Failed to update releve from existing data: $e');
    }
  }


}
