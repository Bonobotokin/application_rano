import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/anomalie_model.dart';
import '../config/api_configue.dart';
import '../databases/nia_databases.dart';
import 'package:intl/intl.dart';

class AnomalieData {
  final NiADatabases _niaDatabase = NiADatabases();

  static Future<void> sendLocalDataToServer(AnomalieModel anomalie, String? accessToken) async {
    try {
      String baseUrl = 'https://app.eatc.me/api'; // Déclarez baseUrl comme une variable locale
      final url = '$baseUrl/anomalie';
      final headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data',
      };

      final anomalieFiles = await getImageAnomalie(anomalie.idMc, NiADatabases());

      if (anomalieFiles.isNotEmpty) {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll(headers);

        for (var i = 0; i < anomalieFiles.length; i++) {
          final anomalieFile = anomalieFiles[i];
          final fileName = path.basename(anomalieFile.path);
          final fileStream = http.ByteStream(anomalieFile.openRead());
          final fileLength = await anomalieFile.length();

          request.files.add(
            http.MultipartFile(
              'photo_anomalie_${i + 1}', // Utilisez le nom de champ attendu par l'API Django
              fileStream,
              fileLength,
              filename: fileName,
            ),
          );
        }

        // Ajouter les autres champs
        DateTime dateDeclaration = DateTime.parse(anomalie.dateDeclaration!);
        String formattedDate = DateFormat('yyyy-MM-dd').format(dateDeclaration);

        request.fields['date_declaration'] = formattedDate;
        request.fields['type_mc'] = anomalie.typeMc.toString();
        request.fields['longitude_mc'] = anomalie.longitudeMc.toString();
        request.fields['latitude_mc'] = anomalie.latitudeMc.toString();
        request.fields['description_mc'] = anomalie.descriptionMc.toString();
        request.fields['client_declare'] = anomalie.clientDeclare.toString();
        request.fields['cp_commune'] = anomalie.cpCommune.toString();
        request.fields['status'] = anomalie.status.toString();

        print('Détails de la requête avant envoi : $request');
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('Données envoyées avec succès !');
        } else {
          print('Erreur lors de l\'envoi des données: ${response.statusCode}');
          print('Réponse du serveur: $responseBody');
        }
      } else {
        print('Aucune image d\'anomalie trouvée.');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi des données: $e');
    }
  }

  static Future<List<File>> getImageAnomalie(int? idMc, NiADatabases _niaDatabase) async {
    try {
      final Database db = await _niaDatabase.database;
      List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT photo_anomalie_1, photo_anomalie_2, photo_anomalie_3, photo_anomalie_4, photo_anomalie_5
      FROM anomalie 
      WHERE 
      id_mc = ?
    ''', [idMc]);

      List<File> images = [];

      for (var row in rows) {
        for (var i = 1; i <= 5; i++) {
          final String? imagePath = row['photo_anomalie_$i'] as String?;
          if (imagePath != null && imagePath.isNotEmpty) {
            final String fullPath = await _buildImagePath(imagePath);
            final File imageFile = File(fullPath);
            if (imageFile.existsSync()) {
              images.add(imageFile);
            } else {
              print('Le fichier image n\'existe pas : $fullPath');
            }
          }
        }
      }

      return images;
    } catch (e) {
      print('Erreur lors de la récupération des images d\'anomalie: $e');
      return [];
    }
  }

  static Future<String> _buildImagePath(String imageCompteurPath) async {
    if (!imageCompteurPath.startsWith('/')) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      return '${appDirectory.path}/$imageCompteurPath';
    }
    return imageCompteurPath;
  }
}
