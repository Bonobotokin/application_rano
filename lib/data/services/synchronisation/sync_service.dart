import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/repositories/local/anomalie_repository_locale.dart';
import 'package:application_rano/data/repositories/local/missions_repository_locale.dart';
import 'package:application_rano/data/services/synchronisation/anomalieData.dart';
import 'package:application_rano/data/services/synchronisation/missionData.dart';
import 'package:application_rano/data/services/synchronisation/payementFacture.dart';
import '../../repositories/local/facture_local_repository.dart';
import '../config/api_configue.dart';
import 'sync_mission.dart';
import 'sync_facture.dart';
import 'sync_anomalie.dart';

import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';

class SyncService {
  final SyncMission _syncMission = SyncMission();
  final SyncFacture _syncFacture = SyncFacture();
  final SyncAnomalie _syncAnomalie = SyncAnomalie();
  final AuthRepository authRepository;

  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();

  SyncService({required this.authRepository});

  Future<void> synchronizeLocalData(String accessToken) async {
    try {
      final List<Future<void>> syncTasks = [];

      // Synchronisation des anomalies
      final anomalieLocale = await AnomalieRepositoryLoale().getAnomalieDataFromLocalDatabase();
      final anomaliesToSync = anomalieLocale.where((anomalie) => anomalie.status == 4).toList();

      if (anomaliesToSync.isNotEmpty) {
        syncTasks.add(_processInBatches(anomaliesToSync, 50, (anomalie) async {
          if (anomalie.status != null && anomalie.status != 0) {
            print("Envoi de l'anomalie ${anomalie.id} avec statut ${anomalie.status}...");
            await AnomalieData.sendLocalDataToServer(anomalie, accessToken);
          } else {
            print("Anomalie ${anomalie.id} ignorée car son statut est nul ou égal à 0.");
          }
        }));
      } else {
        print("Aucune anomalie avec le statut 4 à synchroniser.");
      }

      // Synchronisation des paiements de facture
      final payementFacture = await FactureLocalRepository().getAllPayments();
      final paymentsToSync = payementFacture.where((payment) => payment.statut == 'En cours').toList();
      if (paymentsToSync.isNotEmpty) {
        syncTasks.add(_processInBatches(paymentsToSync, 50, (payment) async {
          print("Envoi du paiement de facture ${payment.id}...");
          await PayementFacture.sendPaymentToServer(payment, accessToken);
        }));
      } else {
        print("Aucun paiement de facture en cours à synchroniser.");
      }

      // Synchronisation des missions
      final missionsDataLocal = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();
      final missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();

      if (missionsToSync.isNotEmpty) {
        syncTasks.add(_processInBatches(missionsToSync, 50, (mission) async {
          if (mission.statut != null && mission.statut != 0) {
            print("Envoi de la mission ${mission.id} avec statut ${mission.statut}...");
            // await MissionData.sendLocalDataToServer(mission, accessToken);
          } else {
            print("Mission ${mission.id} ignorée car son statut est nul ou égal à 0.");
          }
        }));
      } else {
        print("Aucune mission avec le statut 1 à synchroniser.");
      }

      // Exécuter toutes les tâches en parallèle
      await Future.wait(syncTasks);

      print('Toutes les données ont été synchronisées avec succès !');
    } catch (e) {
      print('Erreur lors de la synchronisation des données: $e');
    }
  }

  Future<void> syncDataWithServer(String? accessToken) async {
    try {
      final List<int> idRelievers = [];

      // Étape 1: Synchronisation des anomalies
      print("Début de la synchronisation des anomalies");
        await _syncAnomalie.syncAnomalieTable(accessToken);
      print("Synchronisation des anomalies terminée");

      // Étape 2: Récupération des missions
      print("Début de la synchronisation des missions");
      final List<MissionModel> missionsData = await _syncMission.syncMissionTable(accessToken);
      print("Récupération des missions terminée");

      // Étape 3: Traitement des missions par lots
      const int missionBatchSize = 50; // Taille des lots pour les missions
      await _processInBatches(missionsData, missionBatchSize, (mission) async {
        final int numCompteur = int.parse(mission.numCompteur.toString());
        print("Traitement du compteur $numCompteur");

        final Map<String, dynamic> clientDetails = await authRepository.fetchDataClientDetails(numCompteur, accessToken);

        await Future.wait([
          saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']),
          saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']),
          saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']),
          saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']),
        ]);

        print("Détails du relevé vérifiés : ${clientDetails['releves']}");

        for (var releveData in clientDetails['releves']) {
          final int idReliever = int.parse(releveData.id.toString());
          idRelievers.add(idReliever);
        }
      });

      // Étape 4: Synchronisation des factures après le traitement des missions
      print("Début de la synchronisation des factures");
      const int factureBatchSize = 50; // Taille des lots pour les factures
      await _processInBatches(idRelievers, factureBatchSize, (idReliever) async {
        await _syncFacture.syncFactureTable(accessToken, idReliever);
      });
      print("Synchronisation des factures terminée");

    } catch (error) {
      throw Exception('Failed to sync data: $error');
    }
  }

  // Helper function to process items in batches
  Future<void> _processInBatches<T>(List<T> items, int batchSize, Future<void> Function(T item) process) async {
    for (int i = 0; i < items.length; i += batchSize) {
      final List<T> batch = items.skip(i).take(batchSize).toList();
      await Future.wait(batch.map(process));
    }
  }
}
