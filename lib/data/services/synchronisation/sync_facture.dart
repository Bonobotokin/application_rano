import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/facture_model.dart';
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

        final factureOnline = await _fetchFacturedataFromEndPoint(baseUrl, accessToken, idReliever);

        print("Facture récupérée depuis l'API : $factureOnline");

        final factureLocal =
        await _factureLocalRepository.getFactureDataFromLocalDatabase();


        if(factureLocal.isEmpty){
          print("Local missions data is empty.");
          final factureData = await _saveDataRepositoryLocale.saveFactureData(factureOnline['facture']);


          // Récupérer toutes les données de la table après l'enregistrement
          final allFactureData = await _factureLocalRepository.getFactureDataFromLocalDatabase();

          // Vérifier si la longueur de la liste de données récupérées correspond
          // au nombre de données que vous avez enregistrées
          if (allFactureData.length == 2) {
            print("All facture data saved successfully.");
          } else {
            print("Some facture data may not have been saved correctly.");
          }
        }
        else{

          await _compareAndSyncData(factureOnline, factureLocal, baseUrl, accessToken);

          return factureOnline;
        }


      } else {
        throw Exception('idReliever is null');
      }
    } catch (error) {
      throw Exception('Failed to sync Facture data: $error');
    }
  }


  Future<Map<String, dynamic>> _fetchFacturedataFromEndPoint(
      String baseUrl, String? accessToken, int? idReliever) async {
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
            relevecompteurId: factureData['relevecompteur_id'] is int ? factureData['relevecompteur_id'] : 0,
            numFacture: factureData['num_facture'] ?? '',
            numCompteur: factureData['num_compteur'] is int ? factureData['num_compteur'] : 0,
            dateFacture: factureData['date_facture'] is String ? factureData['date_facture'] : '',
            totalConsoHT: factureData['total_conso_ht']  is double ? factureData['total_conso_ht'] : 0.0,
            tarifM3: factureData['tarif_m3'] is double ? factureData['tarif_m3'] : 0.0,
            avoirAvant: factureData['avoir_avant'] is double ? factureData['avoir_avant'] : 0.0,
            avoirUtilise: factureData['avoir_utilise'] is double ? factureData['avoir_utilise'] : 0.0,
            restantPrecedant: factureData['restant_precedant'] is double ? factureData['restant_precedant'] : 0.0,
            montantTotalTTC: factureData['montant_total_ttc'] is double ? factureData['montant_total_ttc'] : 0.0,
            statut: factureData['statut'] is String ? factureData['statut'] : '',
        );
        print('Facture Data: $factureData');

        return {'facture' : facture};
      } else {
        throw Exception('Failed to fetch facture data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Failed to fetch facture data: $error');
    }
  }

}
