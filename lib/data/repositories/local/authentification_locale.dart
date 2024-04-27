import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/models/user.dart';
import 'package:application_rano/data/services/databases/nia_databases.dart';
import '../../services/saveData/save_data_service_locale.dart';

class AuthenticationLocale {
  final NiADatabases _niaDatabases = NiADatabases();
  final SaveDataRepositoryLocale saveDataRepositoryLocale =
  SaveDataRepositoryLocale();

  Future<User?> authenticate(String phoneNumber, String password) async {
    try {
      final Database db = await _niaDatabases.database;

      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'num_utilisateur = ?',
        whereArgs: [phoneNumber],
      );
      print(result);
      if (result.isNotEmpty) {
        final User user = User.fromMap(result.first);
        /*
        * If authentification is local
        * */
          await saveDataRepositoryLocale.saveUserToLocalDatabase(user);
          return user; // Retourner l'utilisateur si les mots de passe correspondent

      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to authenticate user: $error');
    }
  }

  Future<User?> authenticated(id) async {
    try {
      final Database db = await _niaDatabases.database;

      final List<Map<String, dynamic>> result = await db.query(
        'users',
        where: 'num_utilisateur = ?',
        whereArgs: [id],
      );
      print(result);
      if (result.isNotEmpty) {
        final User user = User.fromMap(result.first);
        /*
        * If authentification is local
        * */
        await saveDataRepositoryLocale.saveUserToLocalDatabase(user);
        return user; // Retourner l'utilisateur si les mots de passe correspondent

      } else {
        return null;
      }
    } catch (error) {
      throw Exception('Failed to authenticate user: $error');
    }
  }

  Future<int?> getUserIdConnected() async {
    final Database db = await _niaDatabases.database;

    final List<Map<String, dynamic>> result = await db.query(
      'last_Connected',
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      // Récupérer la valeur de la colonne is_connected
      final bool isConnected = result[0]['is_connected'] == 1;

      // Si l'utilisateur est connecté, retourner son ID
      if (isConnected) {
        return result[0]['id_utilisateur'];
      }
    }

    // Retourner null si aucun utilisateur n'est connecté ou si aucune donnée n'est disponible
    return null;
  }

}
