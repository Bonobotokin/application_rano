import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/facture_model.dart';
import '../../models/facture_payment_model.dart';
import '../config/api_configue.dart';
import '../../repositories/local/facture_local_repository.dart';
import '../databases/nia_databases.dart';
import '../saveData/save_data_service_locale.dart';

class SyncFacture {
  final FactureLocalRepository _factureLocalRepository;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale =
  SaveDataRepositoryLocale();

  SyncFacture() : _factureLocalRepository = FactureLocalRepository();

  Future<void> syncFactureTable(String? accessToken, int? idReliever) async {
    try {
      final baseUrl = await ApiConfig.determineBaseUrl();

      if (idReliever != null) {

        final factureOnlineMap =
        await _fetchFacturedataFromEndPoint(baseUrl, accessToken, idReliever);
        final factureOnline = factureOnlineMap['facture'];

        // Récupérer les données de facture locales
        final factureLocal = await _factureLocalRepository
            .getFactureDataFromLocalDatabase();

        // Vérifier si les données locales existent
        if (factureLocal.isEmpty) {
          // Si les données locales sont vides, enregistrer les données distantes directement
          print("Local facture data is empty.");
          await _saveDataRepositoryLocale.saveFactureData(factureOnline);
          return factureOnline;
        } else {
          // Si les données locales existent, comparer et mettre à jour si nécessaire
          final factureLocalIds = factureLocal.map((facture) => facture.id)
              .toSet();
          if (!factureLocalIds.contains(factureOnline.id)) {
            // Si l'identifiant de la facture distante n'existe pas localement, enregistrer la nouvelle facture
            print("New facture found. Saving to local database.");
            await _saveDataRepositoryLocale.saveFactureData(factureOnline);
            return factureOnline;
          } else {
            // Si la facture distante existe déjà localement, ne rien faire
            print("Facture already exists locally.");
            return null;
          }
        }
      } else {
        throw Exception('idReliever is null');
      }
    } on FormatException catch (e) {
      throw Exception('Failed to sync Facture data: $e');
    } on http.ClientException catch (e) {
      throw Exception('Failed to sync data from server: $e');
    } catch (error) {
      throw Exception('Failed to sync Facture data: $error');
    }
  }


  Future<Map<String, dynamic>> _fetchFacturedataFromEndPoint(String baseUrl,
      String? accessToken, int? idReliever) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/facture?id_releve=$idReliever'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final factureData = data['facture'];

        final facture = FactureModel(
          id: factureData['id'],
          relevecompteurId: factureData['relevecompteur_id'] ?? 0,
          numFacture: factureData['num_facture'] ?? '',
          numCompteur: factureData['num_compteur'] ?? 0,
          dateFacture: factureData['date_facture'] ?? '',
          totalConsoHT: factureData['total_conso_ht'] ?? 0.0,
          tarifM3: factureData['tarif_m3'] ?? 0.0,
          avoirAvant: factureData['avoir_avant'] ?? 0.0,
          avoirUtilise: factureData['avoir_utilise'] ?? 0.0,
          restantPrecedant: factureData['restant_precedant'] ?? 0.0,
          montantTotalTTC: factureData['montant_total_ttc'] ?? 0.0,
          statut: factureData['statut'] ?? '',
        );

        return {'facture': facture};
      } else {
        throw Exception('Failed to fetch facture data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch facture data: $error');
    }
  }
}