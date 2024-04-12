import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/services/synchronisation/payementFacture.dart';
import '../../repositories/local/facture_local_repository.dart';
import '../config/api_configue.dart';
import 'sync_mission.dart';
import 'sync_facture.dart';
import 'sync_anomalie.dart';

class SyncService {
  final SyncMission _syncMission = SyncMission();
  final SyncFacture _syncFacture = SyncFacture();
  final SyncAnomalie _syncAnomalie = SyncAnomalie();

  late final AuthRepository authRepository;
  final SaveDataRepositoryLocale saveDataRepositoryLocale = SaveDataRepositoryLocale();

  SyncService() {
    _initialize();

  }

  Future<void> _initialize() async {
    final baseUrl = await ApiConfig.determineBaseUrl();
    authRepository = AuthRepository(baseUrl: baseUrl);
  }

  Future<void> syncDataWithServer(String? accessToken) async {
    try {
      final idRelievers = <int>[]; // Déclaration de la liste en dehors de la boucle for

      // Synchronisation anomalie
      await _syncAnomalie.syncAnomalieTable(accessToken);

      final missionsData = await _syncMission.syncMissionTable(accessToken);

      for (var mission in missionsData) {
        final numCompteur = int.parse(mission.numCompteur.toString());
        print("num_compteur $numCompteur");

        final clientDetails = await authRepository.fetchDataClientDetails(numCompteur, accessToken);

        await saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']);
        await saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']);
        await saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']);
        print("date verrifie Releve ${clientDetails['releves']}");

        for (var releveData in clientDetails['releves']) {
          print("date id Releve ${releveData.id}");
          final idReliever = int.parse(releveData.id.toString());
          print("idReliever $idReliever");
          idRelievers.add(idReliever); // Ajout de l'idReliever à la liste
        }

        await saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']);
      }

      print("tableaux : $idRelievers");


      for (var idReliever in idRelievers) {
        print("idTableaux : $idReliever");
        await _syncFacture.syncFactureTable(accessToken, idReliever);
      }
    } catch (error) {
      throw Exception('Failed to sync data: $error');
    }
  }

}
