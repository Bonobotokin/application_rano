import 'dart:convert';
import 'package:application_rano/data/repositories/commentaire/commentaire_repository_locale.dart';
import 'package:application_rano/data/services/synchronisation/commentaire_data.dart';
import 'package:application_rano/data/services/synchronisation/sync_commentaire.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/services/synchronisation/sync_anomalie.dart';
import '../../../repositories/local/anomalie_repository_locale.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/services/synchronisation/anomalie_data.dart'; // Ajout de l'import

class SyncAnomalieService {
  final SyncAnomalie _syncAnomalie = SyncAnomalie();
  final SyncCommentaire _syncCommentaire = SyncCommentaire();

  Future<int> getNumberOfAnomaliesToSync() async {
    try {
      final anomalieLocale = await AnomalieRepositoryLoale().getAnomalieDataFromLocalDatabase();
      final anomaliesToSync = anomalieLocale.where((anomalie) => anomalie.status == 4).toList();

      final commentaireLocale = await CommentaireRepositoryLocale().getCommentaireDataForCurrentMonth();
      final commentaireTosync = commentaireLocale.where((commentaire) => commentaire.statut == 1).toList();

      debugPrint("Commentaire need to send : ${commentaireTosync.length}");

      final int numberOfAnomalies = anomaliesToSync.length + commentaireTosync.length;
      return numberOfAnomalies;
    } catch (error) {
      debugPrint("Erreur lors de la récupération du nombre d'anomalies à synchroniser: $error");
      return -1;
    }
  }

  Future<void> sendAnomaliesToServer(
      String accessToken,
      int batchSize,
      void Function(double) onProgressUpdate,
      ) async {
    try {
      final anomalieLocale = await AnomalieRepositoryLoale().getAnomalieDataFromLocalDatabase();
      final anomaliesToSync = anomalieLocale.where((anomalie) => anomalie.status == 4).toList();

      final commentaireLocale = await CommentaireRepositoryLocale().getCommentaireDataForCurrentMonth();
      final commentaireTosync = commentaireLocale.where((commentaire) => commentaire.statut == 1).toList();

      debugPrint("Commentaire en cours : $commentaireTosync");

      final int totalAnomalies = anomaliesToSync.length;
      final int totalCommentaires = commentaireTosync.length;
      final int totalTasks = totalAnomalies + totalCommentaires;
      int completedTasks = 0;

      // Synchronisation des commentaires
      if (commentaireTosync.isNotEmpty) {
        final List<Future<void>> syncTasksCommentaires = await _processInBatches(commentaireTosync, batchSize, (commentaire) async {
          debugPrint("Envoi du commentaire ${commentaire.id}...");
          if (commentaire.statut == 1) {
            await CommentaireData.sendCommentaireToServer(commentaire, accessToken);
            completedTasks++;
            double progress = completedTasks / totalTasks;
            onProgressUpdate(progress);
          }
        });
        await Future.wait(syncTasksCommentaires);
        debugPrint("Tous les commentaires ont été envoyés avec succès !");
      } else {
        debugPrint("Aucun commentaire à synchroniser.");
      }

      // Synchronisation des anomalies
      if (anomaliesToSync.isNotEmpty) {
        final List<Future<void>> syncTasksAnomalies = await _processInBatches(anomaliesToSync, batchSize, (anomalie) async {
          if (anomalie.status != null && anomalie.status == 4) {
            debugPrint("Tentative d'envoi de l'anomalie ${anomalie.id} avec statut ${anomalie.status}...");
            bool success = await AnomalieData.sendLocalDataToServer(anomalie, accessToken);
            if (success) {
              completedTasks++;
              debugPrint("Anomalie ${anomalie.id} synchronisée avec succès.");
            } else {
              debugPrint("Échec de la synchronisation de l'anomalie ${anomalie.id}.");
            }
            double progress = completedTasks / totalTasks;
            onProgressUpdate(progress);
          } else {
            debugPrint("Anomalie ${anomalie.id} ignorée car son statut est nul ou différent de 4 (${anomalie.status}).");
          }
        });

        await Future.wait(syncTasksAnomalies);
        debugPrint("Toutes les anomalies avec le statut 4 ont été envoyées avec succès !");
      } else {
        debugPrint("Aucune anomalie avec le statut 4 à synchroniser.");
      }

      onProgressUpdate(1.0); // Indiquer la fin de la synchronisation
    } catch (error) {
      debugPrint("Erreur lors de l'envoi des anomalies et des commentaires: $error");
    }
  }

  Future<int> syncDataAnomalieToLocal(String accessToken) async {
    try {
      final startTime = DateTime.now();

      debugPrint("Début de la synchronisation des anomalies");

      final List<AnomalieModel> anomalies = await _fetchAnomalieDataFromEndpoint('https://app.eatc.me/api', accessToken);

      const int anomalieBatchSize = 100;
      await _processInBatches(anomalies, anomalieBatchSize, (anomalie) async {
        debugPrint("Anomalie : ${anomalie.id}");
        await _syncAnomalie.syncAnomalieTable(accessToken);
        debugPrint("Commentaire Démarré");
        await _syncCommentaire.syncCommentaireTable(accessToken);
      });

      debugPrint("Synchronisation des anomalies terminée");

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      debugPrint("Durée totale de la synchronisation des anomalies: ${duration.inSeconds} secondes");
      return duration.inSeconds;
    } catch (error) {
      debugPrint("Erreur lors de la synchronisation des anomalies vers la base de données locale: $error");
      return -1;
    }
  }

  Future<List<Future<void>>> _processInBatches<T>(List<T> items, int batchSize, Future<void> Function(T item) process) async {
    List<Future<void>> futures = [];
    for (int i = 0; i < items.length; i += batchSize) {
      final List<T> batch = items.skip(i).take(batchSize).toList();
      futures.addAll(batch.map(process));
    }
    return futures;
  }

  Future<List<AnomalieModel>> _fetchAnomalieDataFromEndpoint(String baseUrl, String? accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anomalie'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> anomalie = data['main_courante_list'];
        debugPrint("Liste anomalies distantes : $anomalie");
        return anomalie.map((data) => AnomalieModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch anomalie data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch anomalie data: $error');
    }
  }
}