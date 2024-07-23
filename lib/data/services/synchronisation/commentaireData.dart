import 'dart:convert'; // Ajoutez cette ligne pour utiliser jsonEncode
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../models/commentaire_model.dart';
import '../config/api_configue.dart';

class CommentaireData {

  static Future<void> sendCommentaireToServer(CommentaireModel commentaire, String? accessToken) async {
    try {
      String baseUrl = 'http://89.116.38.149:8000/api'; // Déclarez baseUrl comme une variable locale
      final url = '$baseUrl/commentaire'; // Assurez-vous que l'URL est correcte
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Convertir le modèle de commentaire en JSON avec un attribut de statut fixe
      final body = jsonEncode({
        ...commentaire.toMapWithoutId(),
      });

      print("data commentaire send ${body}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Données de commentaire envoyées avec succès !');
      } else {
        print('Erreur lors de l\'envoi des données commentaire: ${response.statusCode}');
        print('Réponse du serveur commentaire: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi des données commentaire: $e');
    }
  }
}
