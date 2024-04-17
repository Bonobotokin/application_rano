import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/missions_model.dart';
import '../config/api_configue.dart';

class MissionData {
  static Future<void> sendLocalDataToServer(
      MissionModel mission, String? accessToken) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();
      final url = '$baseUrl/missions';
      final headers = <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Création de l'objet JSON avec les détails de la mission
      final Map<String, dynamic> missionJson = {
        'num_compteur': mission.numCompteur,
        'date_releve': mission.dateReleve,
        'volume': mission.volumeDernierReleve,
        // Ajoutez les autres champs de mission ici
      };

      final body = jsonEncode(missionJson);

      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 201) {
        print('Mission envoyée avec succès !');
      } else {
        print('Erreur lors de l\'envoi de la mission: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi de la mission: $e');
    }
  }
}

