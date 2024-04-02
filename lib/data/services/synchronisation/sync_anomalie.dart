import 'dart:convert';
import 'package:application_rano/data/repositories/local/anomalie_repository_locale.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/anomalie_model.dart';
import '../config/api_configue.dart';
import '../saveData/save_data_service_locale.dart';

class SyncAnomalie {
  final AnomalieRepositoryLoale _anomalieRepositoryLoale;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale =
  SaveDataRepositoryLocale();

  SyncAnomalie() : _anomalieRepositoryLoale = AnomalieRepositoryLoale();

  Future<void> syncAnomalieTable(String? accessToken) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();
      final anomalieDataOnline = await _fetchAnomalieDataFromEndpoint(baseUrl, accessToken);
      print("Anomalie data from online: $anomalieDataOnline");

      // Enregistrez chaque anomalie dans la base de données locale

      await _saveDataRepositoryLocale.saveAnomalieData(anomalieDataOnline);


      print("Local Anomalie data is empty.");
    } catch (error) {
      throw Exception('Failed to sync anomalie data: $error');
    }
  }


  Future<List<AnomalieModel>> _fetchAnomalieDataFromEndpoint(
      String baseUrl, String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anomalie'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> anomalie = data['main_courante_list'];
        return anomalie
            .map((data) => AnomalieModel.fromJson(data))
            .toList();
      } else {
        throw Exception('Failed to fetch anomalie data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch anomalie data: $error');
    }
  }


}