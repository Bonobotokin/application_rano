import 'dart:convert';
import 'package:application_rano/data/repositories/commentaire/CommentaireRepositoryLocale.dart';
import 'package:application_rano/data/services/synchronisation/commentaireData.dart';
import 'package:application_rano/data/services/synchronisation/sync_commentaire.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/services/synchronisation/sync_anomalie.dart';
import 'package:application_rano/data/services/synchronisation/anomalieData.dart';
import '../../../repositories/local/anomalie_repository_locale.dart';
import 'package:application_rano/data/models/anomalie_model.dart';

class SyncAnomalieService {
  final SyncAnomalie _syncAnomalie = SyncAnomalie();
  final SyncCommentaire _syncCommentaire = SyncCommentaire();

  Future<int> getNumberOfAnomaliesToSync() async {
    try {
      final anomalieLocale = await AnomalieRepositoryLoale().getAnomalieDataFromLocalDatabase();
      final anomaliesToSync = anomalieLocale.where((anomalie) => anomalie.status == 4).toList();

      final commentaireLocale = await CommentaireRepositoryLocale().getCommentaireDataForCurrentMonth();
      final commentaireTosync = commentaireLocale.where((commentaire) => commentaire.statut == 1).toList();

      print("Commentaire need to send : ${commentaireTosync.length}");

      // Compter le nombre d'anomalies qui doivent être synchronisées
      final int numberOfAnomalies = anomaliesToSync.length + commentaireTosync.length;

      return numberOfAnomalies;
    } catch (error) {
      print("Erreur lors de la récupération du nombre d'anomalies à synchroniser: $error");
      return -1; // Retourner -1 en cas d'erreur
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

      print("Commentaire en cours : $commentaireTosync");

      final int totalAnomalies = anomaliesToSync.length;
      final int totalCommentaires = commentaireTosync.length;
      final int totalTasks = totalAnomalies + totalCommentaires;

      int completedTasks = 0;

      if (commentaireTosync.isNotEmpty) {
        final List<Future<void>> syncTasksCommentaires = await _processInBatches(commentaireTosync, batchSize, (commentaire) async {
          print("Envoi du commentaire ${commentaire.id}...");
          if (commentaire.statut != null && commentaire.statut == 1) {

            await CommentaireData.sendCommentaireToServer(commentaire, accessToken);

            completedTasks++;
            double progress = completedTasks / totalTasks;
            onProgressUpdate(progress);
          }
        });

        await Future.wait(syncTasksCommentaires);
        print("Tous les commentaires ont été envoyés avec succès !");
      } else {
        print("Aucun commentaire à synchroniser.");
      }

      // Anomalies
      if (anomaliesToSync.isNotEmpty ) {
        final List<Future<void>> syncTasksAnomalies = await _processInBatches(anomaliesToSync, batchSize, (anomalie) async {
          if (anomalie.status != null && anomalie.status == 4) {
            print("Envoi de l'anomalie ${anomalie.id} avec statut ${anomalie.status}...");
            // await AnomalieData.sendLocalDataToServer(anomalie, accessToken);
            completedTasks++;
            double progress = completedTasks / totalTasks;
            onProgressUpdate(progress);
          } else {
            print("Anomalie ${anomalie.id} ignorée car son statut est nul ou égal à 0.");
          }
        });

        await Future.wait(syncTasksAnomalies);
        print("Toutes les anomalies avec le statut 4 ont été envoyées avec succès !");
      } else {
        print("Aucune anomalie avec le statut 4 à synchroniser.");
      }

      // Optionally, call onProgressUpdate(1.0) to indicate completion
      onProgressUpdate(1.0);

    } catch (error) {
      print("Erreur lors de l'envoi des anomalies et des commentaires: $error");
    }
  }


  Future<int> syncDataAnomalieToLocal(String accessToken) async {
    try {
      final startTime = DateTime.now();

      print("Début de la synchronisation des anomalies");

      // Obtenir les données des anomalies depuis l'endpoint
      final List<AnomalieModel> anomalies = await _fetchAnomalieDataFromEndpoint('your_base_url', accessToken);

      const int anomalieBatchSize = 100;
      await _processInBatches(anomalies, anomalieBatchSize, (anomalie) async {
        print("Anomalie : ${anomalie.id}");
        await _syncAnomalie.syncAnomalieTable(accessToken);

        print("Commentaire Demare");
        await _syncCommentaire.syncCommentaireTable(accessToken);
      });

      print("Synchronisation des anomalies terminée");

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print("Durée totale de la synchronisation des anomalies: ${duration.inSeconds} secondes");
      return duration.inSeconds;
    } catch (error) {
      print("Erreur lors de la synchronisation des anomalies vers la base de données locale: $error");
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
      String baseUrl = 'https://app.eatc.me/api'; // Déclarez baseUrl comme une variable locale
      final response = await http.get(
        Uri.parse('$baseUrl/anomalie'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> anomalie = data['main_courante_list'];
        print("Liste anomalie distantesss $anomalie");
        return anomalie.map((data) => AnomalieModel.fromJson(data)).toList();
      } else {
        throw Exception('Failed to fetch anomalie data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch anomalie data: $error');
    }
  }
}
