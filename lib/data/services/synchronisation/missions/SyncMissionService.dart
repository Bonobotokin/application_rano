import 'dart:convert';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/releves_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:http/http.dart' as http; // Importez http pour effectuer des requêtes HTTP

import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/repositories/local/missions_repository_locale.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:application_rano/data/services/synchronisation/missionData.dart';
import 'package:application_rano/data/services/synchronisation/sync_facture.dart';
import 'package:application_rano/data/services/synchronisation/sync_mission.dart';
import 'package:sqflite/sqlite_api.dart';


class SyncMissionService {
  final SyncMission _syncMission = SyncMission();
  final NiADatabases _niaDatabases = NiADatabases();

  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();

  Future<int> getNumberOfMissionsToSync() async {
    try {
      // Récupérez les données de mission depuis la base de données locale
      final List<MissionModel> missionsDataLocal = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();

      // Filtrez les missions avec le statut 1
      final List<MissionModel> missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();

      // Retournez le nombre de missions à synchroniser
      return missionsToSync.length;
    } catch (error) {
      print("Erreur lors de la récupération des missions: $error");
      return 0; // En cas d'erreur, retournez 0
    }
  }


  Future<void> sendDataMissionInserver(String accessToken, int batchSize, void Function(double) onProgressUpdate) async {
    try {
      final List<MissionModel> missionsDataLocal = await getMissionsDataFromLocalDatabase();
      final List<MissionModel> missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();

      if (missionsToSync.isNotEmpty) {
        final int totalMissions = missionsToSync.length;
        int completedMissions = 0;

        final List<Future<void>> syncTasks = await _processInBatches(missionsToSync, batchSize, (mission) async {
          print("Envoi de la mission ${mission.numCompteur} avec statut ${mission.statut}...");
          await MissionData.sendLocalDataToServer(mission, accessToken);
          completedMissions++;

          // Calculate the progress and call the callback function
          double progress = completedMissions / totalMissions;
          onProgressUpdate(progress);
        });

        // Wait for all synchronization tasks to complete
        await Future.wait(syncTasks);

        print("Toutes les missions avec le statut 1 ont été envoyées avec succès !");
      } else {
        print("Aucune mission avec le statut 1 à synchroniser.");
      }
    } catch (error) {
      print("Erreur lors de l'envoi des missions: $error");
    }
  }

  Future<List<MissionModel>> getMissionsDataFromLocalDatabase() async {
    try {
      final Database db = await _niaDatabases.database;
      List<Map<String, dynamic>> maps = [];

      // Commencez une transaction
      await db.transaction((txn) async {
        maps = await txn.query('missions');
      });

      // Récupération des données et tri
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

      // Tri des missions en fonction du statut dans l'ordre décroissant 2, 1, 0
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
        return null; // Renvoie null si le statut est null ou différent de 1 ou 2
    }
  }

  Future<int> syncDataMissionToLocal(String accessToken) async {
    try {
      final startTime = DateTime.now(); // Enregistrer l'heure de début de la synchronisation

      // Étape 1: Récupération des missions
      print("Début de la synchronisation des missions");
      final List<MissionModel> missionsData = await _syncMission.syncMissionTable(accessToken);
      print("Récupération des missions terminée");

      // Étape 2: Traitement des missions par lots
      const int missionBatchSize = 50; // Taille des lots pour les missions
      await _processInBatches(missionsData, missionBatchSize, (mission) async {
        final int numCompteur = int.parse(mission.numCompteur.toString());
        print("Traitement du compteur $numCompteur");

        final Map<String, dynamic> clientDetails = await fetchDataClientDetails(numCompteur, accessToken);

        await Future.wait([
          saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']),
          saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']),
          saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']),
          saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']),
        ]);
      });

      print("Toutes les missions ont été synchronisées avec succès vers la base de données locale !");

      final endTime = DateTime.now(); // Enregistrer l'heure de fin de la synchronisation
      final duration = endTime.difference(startTime); // Calculer la durée totale de la synchronisation
      print("Durée totale de la synchronisation des missions: ${duration.inSeconds} secondes");

      return duration.inSeconds; // Retourner la durée en secondes
    } catch (error) {
      print("Erreur lors de la synchronisation des missions vers la base de données locale: $error");
      return 0; // En cas d'erreur, retourner 0 secondes
    }
  }


  Future<Map<String, dynamic>> fetchDataClientDetails(
      int? numCompteur, String? accessToken) async {
    print("accessTokenaccessTokenx $accessToken");
    String baseUrl = 'http://89.116.38.149:8000/api'; // Déclarez baseUrl comme une variable locale

    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      if (baseUrl.isEmpty) {
        return {
          'data': 'locale data',
        };
      } else {
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
                : compteurData['id'],
            marque: compteurData['marque'] as String,
            modele: compteurData['modele'] as String,
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
                : 0, // Convertir en int
            dateDebut: contratData['date_debut'] ?? '',
            dateFin: contratData['date_fin'] != null
                ? contratData['date_fin'] as String?
                : null, // Utiliser null si dateFin est null
            adresseContrat: contratData['adresse_contrat'] ?? '',
            paysContrat: contratData['pays_contrat'] ?? '',
          );
          final client = ClientModel(
            id: clientData['id'] is int ? clientData['id'] : 0,
            nom: clientData['nom'] ?? '',
            prenom: clientData['prenom'] ?? '',
            adresse: clientData['adresse'] ?? '',
            commune: clientData['commune'] ?? '',
            region: clientData['region'] ?? '',
            telephone_1: clientData['tephone1'] ?? '',
            telephone_2: clientData['tephone2'] != null
                ? clientData['tephone2'] as String
                : '',
            actif: clientData['actif'] == true ? 1 : 0,
          );

          final releves = (relevesData as List).map((releve) {
            return RelevesModel(
              id: releve['id'] is int ? releve['id'] : 0,
              idReleve: releve['id_releve'] is int ? releve['id_releve'] : 0,
              compteurId:
              releve['compteur_id'] is int ? releve['compteur_id'] : 0,
              contratId: releve['contrat_id'] is int ? releve['contrat_id'] : 0,
              clientId: releve['client_id'] is int ? releve['client_id'] : 0,
              dateReleve:
              releve['date_releve'] is String ? releve['date_releve'] : '',
              volume: releve['volume'] is int ? releve['volume'] : 0,
              conso: releve['conso'] is int ? releve['conso'] : 0,
              etatFacture: releve['etatFacture'] is String ?  releve['etatFacture'] : '',
              imageCompteur: releve['image_compteur'] is String ?  ? releve['image_compteur'] : '',
            );
          }).toList();

          print('Client Details { :');
          print('Compteur Data: $compteurData');
          print('Contra Data: $contratData');
          print('client Data: $clientData');
          print('Releves Data: $relevesData');
          print('Client Details } ');

          return {
            'compteur': compteur,
            'contrat': contrat,
            'client': client,
            'releves': releves,
          };
        } else {
          throw Exception('Failed to fetch home data: ${response.statusCode}');
        }
      }
    } catch (error) {
      throw Exception('Failed to fetch home data: $error');
    }
  }



// Helper function to process items in batches
  Future<List<Future<void>>> _processInBatches<T>(List<T> items, int batchSize, Future<void> Function(T item) process) async {
    List<Future<void>> futures = [];

    for (int i = 0; i < items.length; i += batchSize) {
      final List<T> batch = items.skip(i).take(batchSize).toList();
      futures.addAll(batch.map(process));
    }

    return futures;
  }
}