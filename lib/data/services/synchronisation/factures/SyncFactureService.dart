import 'package:application_rano/data/services/synchronisation/sync_facture.dart';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:application_rano/data/services/synchronisation/payementFacture.dart';
import '../../../repositories/local/facture_local_repository.dart';

class SyncFactureService {
  final SyncFacture _syncFacture = SyncFacture();

  Future<int> getNumberOfFactureToSync() async {
    try {
      final releves = await FactureLocalRepository().getAllPayments();
      final idReleves = releves.where((payment) => payment.statut == 'En cours').toList();
      print("Nombre de factures à envoyer: ${idReleves.length}");

      return idReleves.length;
    } catch (error) {
      print("Erreur lors de la récupération du nombre de factures à synchroniser: $error");
      return -1; // Retourner -1 en cas d'erreur
    }
  }

  Future<void> sendDataFactureInserver(
      String accessToken,
      int batchSize,
      void Function(double) onProgressUpdate
      ) async {
    try {
      // Synchronisation des paiements de facture
      final payementFacture = await FactureLocalRepository().getAllPayments();
      final paymentsToSync = payementFacture.where((payment) => payment.statut == 'En cours').toList();

      if (paymentsToSync.isNotEmpty) {
        final int totalFacture = paymentsToSync.length;
        int completedFacture = 0;

        final List<Future<void>> syncTasks = await _processInBatches(paymentsToSync, batchSize, (payment) async {
          print("Envoi de la Payement ${payment.id} avec statut ${payment.statut}...");
          await PayementFacture.sendPaymentToServer(payment, accessToken);
          completedFacture++;

          // Calculate the progress and call the callback function
          double progress = completedFacture / totalFacture;
          onProgressUpdate(progress);
        });

        // Wait for all synchronization tasks to complete
        await Future.wait(syncTasks);

        print("Toutes les factures avec le statut en cours ont été envoyées avec succès !");
      } else {
        print("Aucune factures avec le statut en cours à synchroniser.");
      }
    } catch (error) {
      print("Erreur lors de l'envoi des factures: $error");
    }
  }

  Future<int> syncDataFactureToLocal(String accessToken) async {
    try {
      final startTime = DateTime.now();
      final List<Map<String, dynamic>> releves = await getAllReleves();
      final List<int> idReleves = releves.map<int>((releve) => releve['id'] as int).toList();

      print("Début de la synchronisation des factures");
      const int factureBatchSize = 50;
      int totalDurationInSeconds = 0;

      await _processInBatches(idReleves, factureBatchSize, (idReleve) async {
        print("ID du relevé : $idReleve");

        // Initialisation du chronomètre pour chaque itération
        Stopwatch stopwatch = Stopwatch();
        stopwatch.start();

        try {
          await _syncFacture.syncFactureTable(accessToken, idReleve);
          stopwatch.stop();
          int durationInSeconds = stopwatch.elapsed.inSeconds;
          totalDurationInSeconds += durationInSeconds;
        } catch (error) {
          print("Erreur lors de la synchronisation du relevé $idReleve : $error");
        }
      });

      print("Synchronisation des factures terminée");

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      final totalDuration = duration.inSeconds + totalDurationInSeconds;

      print("Durée totale de la synchronisation des factures: ${totalDuration} secondes");
      return totalDuration;
    } catch (error) {
      print("Erreur lors de la synchronisation des factures vers la base de données locale: $error");
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllReleves() async {
    try {
      final Database db = await NiADatabases().database;

      // Obtenir la date actuelle
      DateTime now = DateTime.now();
      String currentYear = now.year.toString();
      String currentMonth = now.month.toString().padLeft(2, '0'); // Pour formater le mois avec deux chiffres

      // Requête SQL pour obtenir les relevés avec état "Impayé" et date_releve dans le mois et l'année en cours
      final List<Map<String, dynamic>> rows = await db.rawQuery(
        'SELECT * FROM releves WHERE strftime("%Y", date_releve) = ? AND strftime("%m", date_releve) = ? AND etatFacture = ?',
        [currentYear, currentMonth, 'Impayé'],
      );

      // Imprimer les relevés récupérés
      print("Relevés récupérés : ${rows.length}");

      return rows;
    } catch (e) {
      throw Exception("Failed to get all releves: $e");
    }
  }

  Future<List<Future<void>>> _processInBatches<T>(
      List<T> items,
      int batchSize,
      Future<void> Function(T) process
      ) async {
    List<Future<void>> tasks = [];
    for (int i = 0; i < items.length; i += batchSize) {
      final batch = items.skip(i).take(batchSize);
      for (T item in batch) {
        tasks.add(process(item));
      }
    }
    await Future.wait(tasks); // Attendre que toutes les tâches de ce lot soient terminées
    return tasks;
  }
}
