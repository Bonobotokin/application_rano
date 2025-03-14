import 'dart:convert';
import 'package:application_rano/data/models/commentaire_model.dart';
import 'package:application_rano/data/repositories/commentaire/CommentaireRepositoryLocale.dart';
import 'package:application_rano/data/services/config/api_configue.dart';
import 'package:application_rano/data/services/saveData/save_data_service_locale.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/repositories/local/anomalie_repository_locale.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import '../config/api_configue.dart';
import '../saveData/save_data_service_locale.dart';

class SyncCommentaire {
  final CommentaireRepositoryLocale _commentaireRepositoryLocale;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale = SaveDataRepositoryLocale();

  SyncCommentaire() : _commentaireRepositoryLocale = CommentaireRepositoryLocale();

  Future<void> syncCommentaireTable(String? accessToken) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();
      final List<CommentaireModel> commentaireDataOnline = await _fetchCommentaireDataFromEndpoint(baseUrl, accessToken);
      print("Commentaire data from online: $commentaireDataOnline");

      // Save each commentaire in the local database
      await _saveDataRepositoryLocale.saveCommentaireData(commentaireDataOnline);

      print("Local commentaire data saved successfully.");
    } catch (error) {
      throw Exception('Failed to sync commentaire data: $error');
    }
  }

  Future<List<CommentaireModel>> _fetchCommentaireDataFromEndpoint(String baseUrl, String? accessToken) async {
    try {
      print("baseUl ${baseUrl}");
      final response = await http.get(
        Uri.parse('$baseUrl/anomalie'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> commentaireList = data['commentaire'];
        print("Liste commentaire distant: $commentaireList");
        return commentaireList.map((commentaireData) {
          print("Commentaire JSON: $commentaireData");
          return CommentaireModel.fromJson(commentaireData);
        }).toList();
      } else {
        throw Exception('Failed to fetch commentaire data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch commentaire data: $error');
    }
  }

}