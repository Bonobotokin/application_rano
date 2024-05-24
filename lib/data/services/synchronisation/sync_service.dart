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
      syncTasks.add(_processInBatches(anomaliesToSync, (anomalie) async {
        print("Post anomalie Verifiess $anomalie");
        await AnomalieData.sendLocalDataToServer(anomalie, accessToken);
      }));

      // Synchronisation des paiements de facture
      final payementFacture = await FactureLocalRepository().getAllPayments();
      final paymentsToSync = payementFacture.where((payment) => payment.statut == 'En cours').toList();
      syncTasks.add(_processInBatches(paymentsToSync, (payment) async {

        if( payment.statut == 'En cours' ){
          print("tsy mbola");
          await PayementFacture.sendPaymentToServer(payment, accessToken);
        }

      }));

      // Synchronisation des missions
      final missionsDataLocal = await MissionsRepositoryLocale().getMissionsDataFromLocalDatabase();
      final missionsToSync = missionsDataLocal.where((mission) => mission.statut == 1).toList();
      syncTasks.add(_processInBatches(missionsToSync, (mission) async {
        if (mission.statut != null && mission.statut != 0) {
          print("missiosn envoir ${mission.volumeDernierReleve}");
          await MissionData.sendLocalDataToServer(mission, accessToken);
        }
      }));

      // Exécuter toutes les tâches en parallèle
      await Future.wait(syncTasks);

      print('Toutes les données ont été synchronisées avec succès !');
    } catch (e) {
      print('Erreur lors de la synchronisation des données: $e');
    }
  }

  Future<void> syncDataWithServer(String? accessToken) async {
    try {
      final idRelievers = <int>[];

      // Synchronisation anomalie
      await _syncAnomalie.syncAnomalieTable(accessToken);

      // Récupération des données de missions
      final missionsData = await _syncMission.syncMissionTable(accessToken);

      // Traitement des missions par lot
      await _processInBatches(missionsData, (mission) async {
        final numCompteur = int.parse(mission.numCompteur.toString());
        print("num_compteur $numCompteur");

        final clientDetails = await authRepository.fetchDataClientDetails(numCompteur, accessToken);

        await Future.wait([
          saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']),
          saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']),
          saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']),
        ]);

        print("date verifie Releve ${clientDetails['releves']}");

        for (var releveData in clientDetails['releves']) {
          final idReliever = int.parse(releveData.id.toString());
          idRelievers.add(idReliever);
        }

        await saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']);
      });

      // Traitement des idRelievers par lot
      await _processInBatches(idRelievers, (idReliever) async {
        await _syncFacture.syncFactureTable(accessToken, idReliever);
      });
    } catch (error) {
      throw Exception('Failed to sync data: $error');
    }
  }

  Future<void> _processInBatches<T>(List<T> data, Future<void> Function(T) processFunction) async {
    final batchSize = 50; // Taille du lot à traiter simultanément

    for (var i = 0; i < data.length; i += batchSize) {
      final batchData = data.skip(i).take(batchSize).toList();
      await Future.wait(batchData.map((item) async => await processFunction(item)));
    }
  }
}
