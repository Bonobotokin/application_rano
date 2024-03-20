// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:application_rano/data/models/missions_model.dart';
// import '../config/api_configue.dart';
// import '../../repositories/local/missions_repository_locale.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:application_rano/data/services/databases/nia_databases.dart';
//
// class SyncMission {
//   final NiADatabases _niaDatabases = NiADatabases();
//   final MissionsRepositoryLocale _missionsRepositoryLocale;
//
//   SyncMission() : _missionsRepositoryLocale = MissionsRepositoryLocale();
//
//   Future<void> syncMissionTable(String? accessToken) async {
//     try {
//       final baseUrl = await ApiConfig.determineBaseUrl();
//       final missionsDataOnline = await fetchMissionsDataFromEndpoint(baseUrl, accessToken);
//       print("Fetch data mission synchro : $missionsDataOnline");
//       final missionsDataLocal = await _missionsRepositoryLocale.getMissionsDataFromLocalDatabase();
//       print("mission data Locale : $missionsDataLocal ");
//
//       await compareAndSyncData(missionsDataOnline, missionsDataLocal);
//     } catch (error) {
//       throw Exception('Failed to sync mission data: $error');
//     }
//   }
//
//   Future<List<MissionModel>> fetchMissionsDataFromEndpoint(String baseUrl, String? accessToken) async {
//     try {
//       if (accessToken == null) {
//         throw Exception("Access token is null");
//       }
//
//       final response = await http.get(
//         Uri.parse('$baseUrl/missions'),
//         headers: {'Authorization': 'Bearer $accessToken'},
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         if (responseData.containsKey('compteurs_liste')) {
//           final List<dynamic> missionsData = responseData['compteurs_liste'];
//           return missionsData.map((missionData) => MissionModel.fromJson(missionData)).toList();
//         } else {
//           throw Exception('Failed to fetch missions data: Data structure does not contain "compteurs_liste"');
//         }
//       } else {
//         throw Exception('Failed to fetch missions data: ${response.statusCode}');
//       }
//     } catch (error) {
//       throw Exception('Failed to fetch missions data: $error');
//     }
//   }
//
//
//   Future<void> compareAndSyncData(List<MissionModel> onlineData, List<MissionModel> localData) async {
//     // Comparer les données en ligne et locales
//     for (var onlineMission in onlineData) {
//       for (var localMission in localData) {
//         if (!areMissionsEqual(onlineMission, localMission)) {
//           // Synchroniser les données...
//           await syncMissionData(onlineMission, localMission);
//         }
//       }
//     }
//   }
//
//   bool areMissionsEqual(MissionModel onlineMission, MissionModel localMission) {
//     // Comparer les attributs des missions
//     return onlineMission.id == localMission.id &&
//         onlineMission.nomClient == localMission.nomClient &&
//         onlineMission.prenomClient == localMission.prenomClient &&
//         onlineMission.adresseClient == localMission.adresseClient &&
//         onlineMission.numCompteur == localMission.numCompteur &&
//         onlineMission.consoDernierReleve == localMission.consoDernierReleve &&
//         onlineMission.volumeDernierReleve == localMission.volumeDernierReleve &&
//         onlineMission.dateReleve == localMission.dateReleve &&
//         onlineMission.statut == localMission.statut;
//   }
//
//   Future<void> syncMissionData(MissionModel onlineMission, MissionModel localMission) async {
//     // Mettre à jour les données locales avec les données en ligne
//     try {
//       // Mettez à jour les attributs de localMission avec ceux de onlineMission
//       localMission.nomClient = onlineMission.nomClient;
//       localMission.prenomClient = onlineMission.prenomClient;
//       localMission.adresseClient = onlineMission.adresseClient;
//       localMission.numCompteur = onlineMission.numCompteur;
//       localMission.consoDernierReleve = onlineMission.consoDernierReleve;
//       localMission.volumeDernierReleve = onlineMission.volumeDernierReleve;
//       localMission.dateReleve = onlineMission.dateReleve;
//       localMission.statut = onlineMission.statut;
//
//       // Enregistrez les modifications dans la base de données locale
//       // await _missionsRepositoryLocale.updateMission(localMission);
//     } catch (error) {
//       throw Exception('Failed to sync mission data: $error');
//     }
//   }
// }
