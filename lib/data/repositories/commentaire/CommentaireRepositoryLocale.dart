import 'package:application_rano/blocs/commentaire/commentaire_bloc.dart';
import 'package:application_rano/data/models/commentaire_model.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

class CommentaireRepositoryLocale
{
  final NiADatabases _niaDatabases = NiADatabases();

  Future<List<CommentaireModel>> getCommentaireDataFromLocalDatabase() async
  {
    final Database db = await _niaDatabases.database;
    final List<Map<String, dynamic>> maps = await db.query('commentaire');
    return List.generate(maps.length, (i) {
      return CommentaireModel(
        id: maps[i]['id'],
        idMc: maps[i]['id_mc'],
        idSuivie: maps[i]['id_suivie'],
        dateSuivie: maps[i]['date_suivie'],
        commentaireSuivie: maps[i]['commentaire_suivie'],
        statut: maps[i]['statut'],
      );
    });
  }

  Future<List<CommentaireModel>> getCommentaireDataFromLocalDatabasesSending() async {
    final Database db = await _niaDatabases.database;
    final List<Map<String, dynamic>> maps = await db.query('commentaire');
    return List.generate(maps.length, (i) {
      return CommentaireModel(
        id: maps[i]['id'],
        idMc: maps[i]['id_mc'],
        idSuivie: maps[i]['id_suivie'],
        dateSuivie: DateTime.parse(maps[i]['date_suivie']),
        commentaireSuivie: maps[i]['commentaire_suivie'],
        statut: maps[i]['statut'],
      );
    });
  }

  Future<List<CommentaireModel>> getCommentaireDataForCurrentMonth() async {
    try {
      final commentaireLocal = await getCommentaireDataFromLocalDatabasesSending();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(Duration(milliseconds: 1));

      final commentaireTosync = commentaireLocal.where((commentaire) {
        final date = commentaire.dateSuivie;
        return date.isAfter(startOfMonth) && date.isBefore(endOfMonth);
      }).toList();

      return commentaireTosync;
    } catch (e) {
      throw Exception("Failed to get commentaire data for current month: $e");
    }
  }

  Future<Map<String, dynamic>> getCommentaireData(int idMc) async {
    try {
      final Database db = await _niaDatabases.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'commentaire',
        where: 'id_mc = ?',
        whereArgs: [idMc],
        orderBy: 'id DESC', // Sort by date_suivie in descending order
      );
      print("maps $maps");

      final commentaires = List.generate(maps.length, (i) {
        return CommentaireModel(
          id: maps[i]['id'] ?? 0,
          idMc: maps[i]['id_mc'] ?? 0,
          idSuivie: maps[i]['id_suivie'] ?? 0,
          dateSuivie: DateTime.parse(maps[i]['date_suivie']),
          commentaireSuivie: maps[i]['commentaire_suivie'] ?? '',
          statut: maps[i]['statut'] ?? 0,
        );
      });

      // Assuming you want to get idSuivie from the first comment
      final idSuivie = commentaires.isNotEmpty ? commentaires.first.idSuivie : 0;

      return {
        'commentaires': commentaires,
        'idSuivie': idSuivie,
      };
    } catch (e) {
      throw Exception("Failed to get commentaire data: $e");
    }
  }




  Future<void> addCommentaire(int idMc, int idSuivie, String commentaire) async {
    try {
      final Database db = await _niaDatabases.database;

      // Obtenez la date et l'heure actuelles
      final DateTime now = DateTime.now();

      // Formatez la date et l'heure en format 'yyyy-MM-dd HH:mm'
      final String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(now);

      // Insérez les données dans la base de données
      await db.insert(
          'commentaire',
          {
            'id_mc': idMc,
            'id_suivie': idSuivie,
            'date_suivie': formattedDate, // Utilisez la date formatée
            'commentaire_suivie': commentaire,
            'statut': 1
          }
      );
    } catch (e) {
      throw Exception("Failed to add commentaire: $e");
    }
  }
}
