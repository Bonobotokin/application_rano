import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/models/missions_model.dart';
import '../config/api_configue.dart';
import '../../repositories/local/missions_repository_locale.dart';
import '../saveData/save_data_service_locale.dart';

class SyncMission {
  final MissionsRepositoryLocale missionsRepositoryLocale;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale = SaveDataRepositoryLocale();

  SyncMission() : missionsRepositoryLocale = MissionsRepositoryLocale();

  Future<List<MissionModel>> syncMissionTable(String? accessToken) async {
    try {
      // 1. Nettoyer la table missions locale avant la synchronisation
      final db = await NiADatabases().database;
      await db.delete('missions');
      debugPrint("Table missions locale nettoyée");

      // 2. Récupérer les données depuis le serveur
      final baseUrl = await ApiConfig.determineBaseUrl();
      final missionsDataOnline = await _fetchMissionsDataFromEndpoint(baseUrl, accessToken);
      debugPrint("Missions data from online: $missionsDataOnline");

      // 3. Enregistrer les données localement
      await _saveDataRepositoryLocale.saveMissionsDataToLocalDatabase(missionsDataOnline);
      debugPrint("Missions enregistrées dans la base locale");

      return missionsDataOnline;
    } catch (error) {
      debugPrint("Erreur lors de la synchronisation des missions : $error");
      throw Exception('Failed to sync mission data: $error');
    }
  }

  Future<List<MissionModel>> _fetchMissionsDataFromEndpoint(String baseUrl, String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://app.eatc.me/api/missions'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final missionsData = jsonDecode(response.body);
        if (missionsData.containsKey('compteurs_liste')) {
          final List<dynamic> missions = missionsData['compteurs_liste'];
          return missions.map((missionData) => MissionModel.fromJson(missionData)).toList();
        } else {
          throw Exception('Failed to fetch missions data: Data structure does not contain "compteurs_liste"');
        }
      } else {
        throw Exception('Failed to fetch missions data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch missions data: $error');
    }
  }
}