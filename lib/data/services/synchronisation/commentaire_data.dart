import 'dart:convert'; // Ajoutez cette ligne pour utiliser jsonEncode
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../models/commentaire_model.dart';

class CommentaireData {

  static Future<void> sendCommentaireToServer(CommentaireModel commentaire, String? accessToken) async {
    try {
      String baseUrl = 'https://app.eatc.me/api'; // Déclarez baseUrl comme une variable locale
      final url = '$baseUrl/commentaire'; // Assurez-vous que l'URL est correcte
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      // Convertir le modèle de commentaire en JSON avec un attribut de statut fixe
      final body = jsonEncode({
        ...commentaire.toMapWithoutId(),
      });

      debugPrint("data commentaire send $body");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Données de commentaire envoyées avec succès !');
      } else {
        debugPrint('Erreur lors de l\'envoi des données commentaire: ${response.statusCode}');
        debugPrint('Réponse du serveur commentaire: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi des données commentaire: $e');
    }
  }
}
