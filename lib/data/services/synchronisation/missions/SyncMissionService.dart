import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/repositories/local/missions_repository_locale.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:application_rano/data/services/synchronisation/missionData.dart';
import 'package:application_rano/data/services/synchronisation/sync_facture.dart';
import 'package:application_rano/data/services/synchronisation/sync_mission.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../../repositories/auth_repository.dart';

class SyncMissionService {
  final SyncMission _syncMission = SyncMission();
  final NiADatabases _niaDatabases = NiADatabases();
  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();

  Future<int> getNumberOfMissionsToSync() async {
    try {
      final List<MissionModel> missionsDataLocal = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();
      final List<MissionModel> missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();
      print("Number of missions to sync: ${missionsToSync.length}");
      return missionsToSync.length;
    } catch (error) {
      print("Error fetching missions: $error");
      return 0;
    }
  }

  Future<void> sendDataMissionInserver(String accessToken, int batchSize, void Function(double) onProgressUpdate) async {

    try {
      final List<MissionModel> missionsDataLocal = await getMissionsDataFromLocalDatabase();
      final List<MissionModel> missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();

      if (missionsToSync.isNotEmpty) {
        final int totalMissions = missionsToSync.length;
        int completedMissions = 0;
        final int totalTasks = (totalMissions / batchSize).ceil();

        for (int i = 0; i < totalTasks; i++) {
          final List<MissionModel> missionsBatch = missionsToSync.sublist(i * batchSize, min((i + 1) * batchSize, totalMissions));

          await Future.wait(missionsBatch.map((mission) async {
            print("Sending mission ${mission.numCompteur} with status ${mission.statut}...");
            await MissionData.sendLocalDataToServer(mission, accessToken);

            completedMissions++;
            double progress = completedMissions / totalMissions;
            onProgressUpdate(progress);
          }));
        }

        print("All missions with status 1 successfully sent!");
      } else {
        print("No missions with status 1 to sync.");
      }
    } catch (error) {
      print("Error sending missions: $error");
      rethrow;
    }
  }

  Future<List<MissionModel>> getMissionsDataFromLocalDatabase() async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> maps = [];

      await db.transaction((txn) async {
        maps = await txn.query('missions');
      });

      List<MissionModel> missions = List.generate(maps.length, (i) {
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

      missions.sort((a, b) {
        final aStatut = _mapStatutToValid(a.statut) ?? 0;
        final bStatut = _mapStatutToValid(b.statut) ?? 0;
        return bStatut.compareTo(aStatut);
      });

      return missions;
    } catch (e) {
      throw Exception("Failed to get missions data from local database: $e");
    }
  }

  int? _mapStatutToValid(int? statut) {
    switch (statut) {
      case 1:
      case 2:
        return statut;
      default:
        return null;
    }
  }

  Future<int> syncDataMissionToLocal(String accessToken) async {
    try {
      final AuthRepository authRepository = AuthRepository(baseUrl: "https://app.eatc.me/api");
      final startTime = DateTime.now();

      print("Start syncing missions");
      final List<MissionModel> missionsData = await _syncMission.syncMissionTable(accessToken);
      print("Mission retrieval complete");

      const int missionBatchSize = 200;
      await _processInBatches(missionsData, missionBatchSize, (mission) async {
        final int numCompteur = int.parse(mission.numCompteur.toString());
        print("Processing counter $numCompteur");

        final Map<String, dynamic> clientDetails = await fetchDataClientDetails(numCompteur, accessToken);

        await Future.wait([
          saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']),
          saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']),
          saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']),
          saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']),
        ]);
      });

      print("All missions successfully synced to local database!");

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("Total duration of mission synchronization: ${duration.inSeconds} seconds");

      return duration.inSeconds;
    } catch (error) {
      print("Error syncing missions to local database: $error");
      return 0;
    }
  }

  Future<Map<String, dynamic>> fetchDataClientDetails(int? numCompteur, String? accessToken) async {
    String baseUrl = 'https://app.eatc.me/api';

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/releverClient?num_compteur=$numCompteur'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final compteurData = data['compteur'];
        final contratData = data['contrat'];
        final clientData = data['client'];
        final relevesData = data['releves'];

        final compteur = CompteurModel(
          id: compteurData['id'] is String
              ? int.tryParse(compteurData['id']) ?? 0
              : compteurData['id'] ?? 0,
          marque: compteurData['marque'] ?? '',
          modele: compteurData['modele'] ?? '',
        );

        final contrat = ContratModel(
          id: contratData['id'] != null
              ? (contratData['id'] is String
              ? int.tryParse(contratData['id'] ?? '0') ?? 0
              : contratData['id'])
              : 0,
          numeroContrat: contratData['numero_contrat'] ?? '',
          clientId: contratData['client_id'] != null
              ? int.parse(contratData['client_id'].toString())
              : 0,
          dateDebut: contratData['date_debut'] ?? '',
          dateFin: contratData['date_fin'] ?? '',
          adresseContrat: contratData['adresse_contrat'] ?? '',
          paysContrat: contratData['pays_contrat'] ?? '',
        );

        final client = ClientModel(
          id: clientData['id'] ?? 0,
          nom: clientData['nom'] ?? '',
          prenom: clientData['prenom'] ?? '',
          adresse: clientData['adresse'] ?? '',
          commune: clientData['commune'] ?? '',
          region: clientData['region'] ?? '',
          telephone_1: clientData['tephone1'] ?? '',
          telephone_2: clientData['tephone2'] ?? '',
          actif: clientData['actif'] == true ? 1 : 0,
        );

        final releves = (relevesData as List).map((releve) {
          return RelevesModel(
            id: releve['id'] ?? 0,
            idReleve: releve['id_releve'] ?? 0,
            compteurId: releve['compteur_id'] ?? 0,
            contratId: releve['contrat_id'] ?? 0,
            clientId: releve['client_id'] ?? 0,
            dateReleve: releve['date_releve'] ?? '',
            volume: releve['volume'] ?? 0,
            conso: releve['conso'] ?? 0,
            etatFacture: releve['etatFacture'] ?? '',
            imageCompteur: releve['image_compteur'] ?? '',
          );
        }).toList();

        return {
          'compteur': compteur,
          'contrat': contrat,
          'client': client,
          'releves': releves,
        };
      } else {
        throw Exception('Failed to fetch home data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch home data: $error');
    }
  }

  Future<void> _processInBatches<T>(List<T> items, int batchSize, Future<void> Function(T item) process) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final List<T> batch = items.skip(i).take(batchSize).toList();
      await Future.wait(batch.map(process));
    }
  }
}
