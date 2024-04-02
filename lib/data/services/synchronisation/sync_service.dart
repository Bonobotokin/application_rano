import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/services/databases/factureDb.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
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

      // Synchronisation anomalie
      await _syncAnomalie.syncAnomalieTable(accessToken);

      final missionsData = await _syncMission.syncMissionTable(accessToken);
      final idRelievers = <int>[]; // Utilisation d'une liste typée pour stocker les idReliever
      //
      for (var mission in missionsData) {
        final numCompteur = int.parse(mission.numCompteur.toString());
        print("num_compteur $numCompteur");
        final idReliever = int.parse(mission.id.toString());

        print("idReliever $idReliever");

        final clientDetails = await authRepository.fetchDataClientDetails(numCompteur, accessToken);

        await saveDataRepositoryLocale.saveCompteurDetailsRelever(clientDetails['compteur']);
        await saveDataRepositoryLocale.saveContraDetailsRelever(clientDetails['contrat']);
        await saveDataRepositoryLocale.saveClientDetailsRelever(clientDetails['client']);
        await saveDataRepositoryLocale.saveReleverDetailsRelever(clientDetails['releves']);

        idRelievers.add(idReliever);
      }

      print("tableaux : $idRelievers");

      for (var idReliever in idRelievers) {
        if (idReliever != null) {
          await _syncFacture.syncFactureTable(accessToken, idReliever);
        } else {
          throw Exception('idReliever is null');
        }
      }


    } catch (error) {
      throw Exception('Failed to sync data: $error');
    }
  }
}
