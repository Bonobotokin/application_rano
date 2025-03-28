import 'dart:convert';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import '../../models/facture_model.dart';
import '../../repositories/local/facture_local_repository.dart';
import '../config/api_configue.dart';
import '../saveData/save_data_service_locale.dart';

class SyncFacture {
  final FactureLocalRepository _factureLocalRepository;
  final SaveDataRepositoryLocale _saveDataRepositoryLocale = SaveDataRepositoryLocale();

  SyncFacture() : _factureLocalRepository = FactureLocalRepository();

  Future<void> syncFactureTable(String? accessToken, int? idReleve) async {
    try {
      if (idReleve != null) {
        final baseUrl = await ApiConfig.determineBaseUrl();
        final Database db = await NiADatabases().database;

        await db.transaction((txn) async {
          await _fetchFactureDataFromEndPoint(accessToken, idReleve, txn);
        });
      } else {
        throw Exception('idReleve is null');
      }
    } on FormatException catch (e) {
      throw Exception('Failed to sync Facture data: $e');
    } on http.ClientException catch (e) {
      throw Exception('Failed to sync data from server: $e');
    } catch (error) {
      throw Exception('Failed to sync Facture data: $error');
    }
  }

  Future<void> _fetchFactureDataFromEndPoint(
      String? accessToken,
      int idReleve,
      Transaction txn
      ) async {
    print("ID Releve: $idReleve");
    print("AccessToken Facture: $accessToken");
    String baseUrl = 'https://app.eatc.me/api'; // Déclarez baseUrl comme une variable locale
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/facture?id_releve=$idReleve'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final factureData = data['facture'];
        print("facture getting start");
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
          montantPayer: factureData['montant_payer'] ?? 0.0,
          statut: factureData['statut'] ?? '',
        );

        print("Enregistrement des données dans la base locale");
        await _saveDataRepositoryLocale.saveFactureData([facture], txn);
      } else {
        throw Exception('Erreur de la requête HTTP: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erreur de récupération des données de la facture: $error');
    }
  }
}
