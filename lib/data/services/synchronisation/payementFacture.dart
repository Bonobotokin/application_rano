import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/facture_payment_model.dart';
import '../config/api_configue.dart';


class PayementFacture {
  static Future<void> sendPaymentToServer(FacturePaymentModel payment, accessToken) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();
      final url = '$baseUrl/facture'; // Remplacez l'URL par l'URL de votre API Django
      final headers = <String, String>{
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode(payment.toJson());

      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Paiement envoyé avec succès
        print('Paiement envoyé avec succès !');
      } else {
        // Erreur lors de l'envoi du paiement
        print('Erreur lors de l\'envoi du paiement: ${response.statusCode}');
      }
    } catch (e) {
      // Erreur générale
      print('Erreur lors de l\'envoi du paiement: $e');
    }
  }
}
