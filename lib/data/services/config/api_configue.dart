import 'package:http/http.dart' as http;

class ApiConfig {
  // Remplacez par votre adresse IP
  static const String ipAddress = 'http://89.116.38.149:8000';

  static Future<String> determineBaseUrl() async {
    try {
      var response = await http.get(Uri.parse('$ipAddress/api/serveurTest')).timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        print("Connexion réussie à $ipAddress");
        return '$ipAddress/api';
      } else {
        print("Connexion à $ipAddress échouée avec le code de statut ${response.statusCode}");
      }
    } catch (error) {
      print('Erreur lors de la connexion à $ipAddress: $error');
    }

    // Si l'adresse IP n'est pas disponible, retourner une chaîne vide
    print('L\'adresse IP n\'a pas pu être connectée.');
    return '';
  }
}
