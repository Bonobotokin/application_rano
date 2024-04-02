import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/repositories/local/authentification_locale.dart';
import 'package:application_rano/data/repositories/local/synchronisation_repository.dart';
import '../models/home_model.dart';
import '../models/missions_model.dart';
import '../services/saveData/save_data_service_locale.dart'; // Importer le fichier contenant les opérations locales
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/models/compteur_model.dart';
import 'package:application_rano/data/models/contrat_model.dart';
import 'package:application_rano/data/models/releves_model.dart';

class AuthRepository {
  final String baseUrl;
  final SaveDataRepositoryLocale saveDataRepositoryLocale =
      SaveDataRepositoryLocale(); // Créer une instance de la classe contenant les opérations locales

  AuthRepository({required this.baseUrl});

  Future<User?> login(String phoneNumber, String password) async {
    try {
      if (baseUrl.trim().isEmpty) {
        print("authentification locale");
        return AuthenticationLocale().authenticate(phoneNumber, password);
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/authentification'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'num_utilisateur': phoneNumber,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          final User user = User.fromJson(responseData['info_utilisateur']);
          print("User a insetre : $responseData['info_utilisateur']");
          await saveDataRepositoryLocale.saveUserToLocalDatabase(
              user); // Appeler la méthode locale pour enregistrer l'utilisateur

          return user;
        } else {
          return null;
        }
      }
    } catch (error) {
      throw Exception('Failed to login: $error');
    }
  }

  Future<Map<String, dynamic>> fetchHomeDataFromEndpoint(
      String? accessToken) async {
    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      if (baseUrl == null || baseUrl.isEmpty) {
        return {
          'data': 0,
        };
      } else {
        final response = await http.get(
          Uri.parse('$baseUrl/accueil'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        print(response);
        if (response.statusCode == 200) {
          final homeModel = HomeModel.fromJson(jsonDecode(response.body));
          await saveDataRepositoryLocale.saveHomeDataToLocalDatabase(
              homeModel); // Enregistrer les données d'accueil localement
          print("homeMOdel $homeModel");
          return jsonDecode(response.body);
        } else {
          throw Exception('Failed to fetch home data: ${response.statusCode}');
        }
      }
    } catch (error) {
      throw Exception('Failed to fetch home data: $error');
    }
  }


  Future<Map<String, dynamic>> fetchDataClientDetails(
      int? numCompteur, String? accessToken) async {
    try {
      if (accessToken == null) {
        throw Exception("Access token is null");
      }

      if (baseUrl == null || baseUrl.isEmpty) {
        return {
          'data': 'locale data',
        };
      } else {
        final response = await http.get(
          Uri.parse('$baseUrl/releverClient?num_compteur=$numCompteur'),
          headers: {'Authorization': 'Bearer $accessToken'},
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          final compteurData = data['compteur'];
          final contratData = data['contrat'];
          final clientData = data['client'];
          final relevesData = data['releves'];

          final compteur = CompteurModel(
            id: compteurData['id'] is String
                ? int.tryParse(compteurData['id']) ?? 0
                : compteurData['id'],
            marque: compteurData['marque'] as String,
            modele: compteurData['modele'] as String,
          );

          final contrat = ContratModel(
            id: contratData['id'] != null
                ? (contratData['id'] is String
                    ? int.tryParse(contratData['id'] ?? '0') ?? 0
                    : contratData['id'])
                : 0,
            numeroContrat: contratData['numero_contrat'] ?? '',
            clientId: contratData['client_id'] != null
                ? int.parse(contratData['client_id'].toString())
                : 0, // Convertir en int
            dateDebut: contratData['date_debut'] ?? '',
            dateFin: contratData['date_fin'] != null
                ? contratData['date_fin'] as String?
                : null, // Utiliser null si dateFin est null
            adresseContrat: contratData['adresse_contrat'] ?? '',
            paysContrat: contratData['pays_contrat'] ?? '',
          );
          final client = ClientModel(
            id: clientData['id'] != null
                ? (clientData['id'] is String
                    ? int.tryParse(clientData['id'] ?? '0') ?? 0
                    : clientData['id'])
                : 0,
            nom: clientData['nom'] ?? '',
            prenom: clientData['prenom'] ?? '',
            adresse: clientData['adresse'] ?? '',
            commune: clientData['commune'] ?? '',
            region: clientData['region'] ?? '',
            telephone_1: clientData['tephone1'] ?? '',
            telephone_2: clientData['tephone2'] != null
                ? clientData['tephone2'] as String
                : '',
            actif: clientData['actif'] == true ? 1 : 0,
          );

          final releves = (relevesData as List).map((releve) {
            return RelevesModel(
              id: releve['id'] is int ? releve['id'] : 0,
              idReleve: releve['id_releve'] is int ? releve['id_releve'] : 0,
              compteurId:
                  releve['compteur_id'] is int ? releve['compteur_id'] : '0',
              contratId: releve['contrat_id'] is int ? releve['contrat_id'] : 0,
              clientId: releve['client_id'] is int ? releve['client_id'] : 0,
              dateReleve:
                  releve['date_releve'] is String ? releve['date_releve'] : '',
              volume: releve['volume'] is int ? releve['volume'] : 0,
              conso: releve['conso'] is int ? releve['conso'] : 0,
            );
          }).toList();

          print('Client Details { :');
          print('Compteur Data: $compteurData');
          print('Contra Data: $contratData');
          print('client Data: $clientData');
          print('Releves Data: $relevesData');
          print('Client Details } ');

          return {
            'compteur': compteur,
            'contrat': contrat,
            'client': client,
            'releves': releves,
          };
        } else {
          throw Exception('Failed to fetch home data: ${response.statusCode}');
        }
      }
    } catch (error) {
      throw Exception('Failed to fetch home data: $error');
    }
  }

// Sauvegarde des données dans la base de données locale

// await saveDataRepositoryLocale.saveCompteurDetailsRelever(compteur);
// await saveDataRepositoryLocale.saveContraDetailsRelever(contrat);
// await saveDataRepositoryLocale.saveClientDetailsRelever(client);
// await saveDataRepositoryLocale.saveReleverDetailsRelever(releves);
}
