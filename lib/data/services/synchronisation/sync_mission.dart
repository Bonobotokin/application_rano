import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/models/missions_model.dart';
import '../config/api_configue.dart';
import '../../repositories/local/missions_repository_locale.dart';
import '../saveData/save_data_service_locale.dart';

class SyncMission {
  final MissionsRepositoryLocale _missionsRepositoryLocale;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale =
  SaveDataRepositoryLocale();

  SyncMission() : _missionsRepositoryLocale = MissionsRepositoryLocale();

  Future<List<MissionModel>> syncMissionTable(String? accessToken) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();
      final missionsDataOnline = await _fetchMissionsDataFromEndpoint(baseUrl, accessToken);
      print("Missions data from online: $missionsDataOnline");

      final missionsDataLocal = await _missionsRepositoryLocale.getMissionsDataFromLocalDatabase();
      print("Missions data from locale: $missionsDataLocal");

      if (missionsDataLocal.isEmpty) {
        print("Local missions data is empty.");
        final db = await NiADatabases().database;
        await db.transaction((txn) async {
          await _saveDataRepositoryLocale.saveMissionsDataToLocalDatabase(txn, missionsDataOnline);
        });

        return missionsDataOnline;
      } else {
        await _compareAndSyncData(missionsDataOnline, missionsDataLocal, baseUrl, accessToken);

        return missionsDataOnline;
      }
    } catch (error) {
      throw Exception('Failed to sync mission data: $error');
    }
  }


  Future<List<MissionModel>> _fetchMissionsDataFromEndpoint(
      String baseUrl, String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/missions'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final missionsData = jsonDecode(response.body);
        if (missionsData.containsKey('compteurs_liste')) {
          final List<dynamic> missions = missionsData['compteurs_liste'];
          return missions
              .map((missionData) => MissionModel.fromJson(missionData))
              .toList();
        } else {
          throw Exception(
              'Failed to fetch missions data: Data structure does not contain "compteurs_liste"');
        }
      } else {
        throw Exception('Failed to fetch missions data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch missions data: $error');
    }
  }

  Future<void> _compareAndSyncData(List<MissionModel> onlineData,
      List<MissionModel> localData, String baseUrl, String? accessToken) async {
    try {
      final db = await NiADatabases().database;

      await db.transaction((txn) async {
        for (var onlineMission in onlineData) {
          var localMission = localData.firstWhere(
                (mission) => mission.id == onlineMission.id,
            orElse: () => MissionModel(),
          );

          // Vérifiez si la mission locale existe déjà dans la base de données Django
          if (localMission == null ||
              !(await _areMissionsEqual(onlineMission, localMission))) {
            print("verifier $localMission ");
            // Si la mission n'existe pas localement ou est différente, envoyez-la au serveur
            await _sendLocalDataToServer([localMission], baseUrl, accessToken);
            final missionsDataOnline = await _fetchMissionsDataFromEndpoint(baseUrl, accessToken);
            await _saveDataRepositoryLocale.saveMissionsDataToLocalDatabase(txn, missionsDataOnline);
          }
        }
      });
    } on FormatException catch (e) {
      throw Exception('Failed to compare missions: $e');
    } on http.ClientException catch (e) {
      throw Exception('Failed to sync data from server: $e');
    } catch (error) {
      throw Exception('Failed to compare and sync data: $error');
    }
  }


  Future<bool> _areMissionsEqual(
      MissionModel onlineMission, MissionModel localMission) async {
    try {
      final onlineDate = DateTime.tryParse(onlineMission.dateReleve ?? '');
      final localDate = DateTime.tryParse(localMission.dateReleve ?? '');

      if (onlineDate != null && localDate != null) {
        return onlineDate.isAtSameMomentAs(localDate);
      }

      return false;
    } catch (error) {
      throw Exception('Failed to compare missions: $error');
    }
  }

  Future<void> _sendLocalDataToServer(
      List<MissionModel> localData, String baseUrl, String? accessToken) async {
    try {
      print("accessToken: $accessToken");

      for (var mission in localData) {
        var jsonData = jsonEncode({
          'num_compteur': mission.numCompteur,
          'date_releve': mission.dateReleve,
          'volume': mission.volumeDernierReleve,
        });

        final response = await http.post(
          Uri.parse('$baseUrl/missions'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
          body: jsonData,
        );

        print("Response from server: ${response.statusCode}");
        if (response.statusCode == 201) {
          print('Local data sent to server successfully.');
        } else {
          throw Exception(
              'Failed to send local data to server: ${response.statusCode}');
        }
      }
    } catch (error) {
      throw Exception('Failed to send local data to server: $error');
    }
  }
}
