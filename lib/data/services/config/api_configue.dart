import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static const String ipAddress = 'https://app.eatc.me';

  // Augmentation du délai d'expiration à 20 secondes
  static Future<String> determineBaseUrl() async {
    try {
      var response = await http.get(Uri.parse('$ipAddress/api/serveurTest')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint("ipAddress connected in $ipAddress");
        return '$ipAddress/api';
      } else {
        debugPrint('Erreur lors de la connexion à $ipAddress: Status Code ${response.statusCode}');
        return '';
      }
    } catch (error) {
      debugPrint('Erreur lors de la connexion à $ipAddress: $error');
      return '';
    }
  }
}
