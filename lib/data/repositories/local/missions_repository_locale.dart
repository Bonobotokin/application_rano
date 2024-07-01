import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';

class MissionsRepositoryLocale {
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<MissionModel>> getMissionsDataFromLocalDatabase() async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query('missions');

      // Récupération des données
      List<MissionModel> missions = List.generate(maps.length, (i) {
        return MissionModel(
          id: maps[i]['id'],
          nomClient: maps[i]['nom_client'],
          prenomClient: maps[i]['prenom_client'],
          adresseClient: maps[i]['adresse_client'],
          numCompteur: maps[i]['num_compteur'],
          consoDernierReleve: maps[i]['conso_dernier_releve'],
          volumeDernierReleve: maps[i]['volume_dernier_releve'],
          dateReleve: maps[i]['date_releve'],
          statut: maps[i]['statut'],
        );
      });

      // Tri des missions en fonction du statut dans l'ordre décroissant 2, 1, 0
      missions.sort((a, b) {
        final aStatut = _mapStatutToValid(a.statut) ?? 0;
        final bStatut = _mapStatutToValid(b.statut) ?? 0;

        // Si les deux missions ont le même statut, on les trie par ordre alphabétique du nom du client
        if (aStatut == bStatut) {
          final aNomClient = a.nomClient ?? '';
          final bNomClient = b.nomClient ?? '';
          return aNomClient.compareTo(bNomClient);
        }

        // Si l'une des missions a le statut 0, elle est placée avant l'autre
        if (aStatut == 0) {
          return -1;
        }
        if (bStatut == 0) {
          return 1;
        }

        // Si l'une des missions a le statut 1, elle est placée avant l'autre
        if (aStatut == 1) {
          return -1;
        }
        if (bStatut == 1) {
          return 1;
        }

        // Sinon, on trie par ordre décroissant de statut (2, 1, 0)
        return bStatut.compareTo(aStatut);
      });



      return missions;
    } catch (e) {
      throw Exception("Failed to get missions data from local database: $e");
    }
  }

  int? _mapStatutToValid(int? statut) {
    switch (statut) {
      case 0:
      case 1:
      case 2:
        return statut;
      default:
        return null; // Renvoie null si le statut est null ou différent de 1 ou 2
    }
  }
}
