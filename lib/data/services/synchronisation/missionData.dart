import 'dart:convert';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:http/http.dart' as http;
import '../../models/facture_payment_model.dart';
import '../config/api_configue.dart';

class MissionData {
  static Future<void> sendLocalDataToServer(
    MissionModel missions, String? accessToken) async {
  try {
    print("accessToken: $accessToken");
    final baseUrl = await ApiConfig.determineBaseUrl();

    final url = '$baseUrl/missions'; // Remplacez l'URL par l'URL de votre API Django
    final headers = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(missions.toJson());

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      // Paiement envoyé avec succès
      print('missions envoyé avec succès !');
    } else {
      // Erreur lors de l'envoi du paiement
      print('Erreur lors de l\'envoi du missions: ${response.statusCode}');
    }
  } catch (e) {
    // Erreur générale
    print('Erreur lors de l\'envoi du missions: $e');
  }

}