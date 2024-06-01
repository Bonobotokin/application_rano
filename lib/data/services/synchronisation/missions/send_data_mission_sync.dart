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
import 'package:sqflite/sqflite.dart';

class SendDataMissionSync {
  final SyncMission _syncMission = SyncMission();
  final SyncFacture _syncFacture = SyncFacture();

  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();


  Future<void> sendDataMissionInserver(String accessToken, void Function(double) onProgressUpdate) async {
    try {
      final List<MissionModel> missionsDataLocal = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();
      final List<MissionModel> missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();

      if (missionsToSync.isNotEmpty) {
        final int batchSize = 50;
        final List<Future<void>> syncTasks = await _processInBatches(missionsToSync, batchSize, (mission) async {
          print("Envoi de la mission ${mission.id} avec statut ${mission.statut}...");
          await MissionData.sendLocalDataToServer(mission, accessToken);
          // Calculer la progression et appeler la fonction de rappel
          double progress = (missionsToSync.indexOf(mission) + 1) / missionsToSync.length;
          onProgressUpdate(progress);
        });

        // Attendre que toutes les tâches de synchronisation soient terminées
        await Future.wait(syncTasks);

        print("Toutes les missions avec le statut 1 ont été envoyées avec succès !");

      } else {
        print("Aucune mission avec le statut 1 à synchroniser.");
      }
    } catch (error) {
      print("Erreur lors de l'envoi des missions: $error");
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

  Future<void> syncDataMissionToLocal(String accessToken) async {
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
    } catch (error) {
      print("Erreur lors de la synchronisation des missions vers la base de données locale: $error");
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

  Future<void> syncDataFactureToLocal(String accessToken) async {
    try {
      final startTime = DateTime.now(); // Enregistrer l'heure de début de la synchronisation

      // Récupérer tous les relevés de la base de données locale
      final List<Map<String, dynamic>> releves = await getAllReleves();

      // Extraire les IDs des relevés
      final List<int> idRelievers = releves.map<int>((releve) => releve['id'] as int).toList();

      // Étape 4: Synchronisation des factures après le traitement des missions
      print("Début de la synchronisation des factures");
      const int factureBatchSize = 50; // Taille des lots pour les factures
      await _processInBatches(idRelievers, factureBatchSize, (idReliever) async {
        print("ID du relevé : $idReliever");
        await _syncFacture.syncFactureTable(accessToken, idReliever);
      });
      print("Synchronisation des factures terminée");

      final endTime = DateTime.now(); // Enregistrer l'heure de fin de la synchronisation
      final duration = endTime.difference(startTime); // Calculer la durée totale de la synchronisation
      print("Durée totale de la synchronisation des factures: ${duration.inSeconds} secondes");
    } catch (error) {
      print("Erreur lors de la synchronisation des factures vers la base de données locale: $error");
    }
  }


  Future<List<Map<String, dynamic>>> getAllReleves() async {
    try {
      final Database db = await NiADatabases().database;
      // Exécuter la requête SQL pour sélectionner toutes les lignes de la table releves
      List<Map<String, dynamic>> rows = await db.rawQuery('''
        SELECT * FROM releves
      ''');
      return rows; // Retourner les lignes de la table releves
    } catch (e) {
      throw Exception("Failed to get all releves: $e");
    }
  }

}