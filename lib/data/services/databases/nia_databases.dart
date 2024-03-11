import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:application_rano/data/services/databases/acceuilDb.dart';
import 'package:application_rano/data/services/databases/missionsDb.dart';
import 'package:application_rano/data/services/databases/usersDb.dart';
import 'package:application_rano/data/services/databases/compteursDb.dart';
import 'package:application_rano/data/services/databases/contratDb.dart';
import 'package:application_rano/data/services/databases/clientDb.dart';
import 'package:application_rano/data/services/databases/relevesDb.dart';
import 'package:application_rano/data/services/databases/last_connectedDb.dart';

class NiADatabases {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDatabase();
    return _database!;
  }

  Future<String> getDatabasePath() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'rel_compteur.db');
  }

  Future<Database> initDatabase() async {
    final path = await getDatabasePath();
    print("le path de DB est : $path ");
    try {
      var database = await openDatabase(
        path,
        version: 1,
        onCreate: create,
        singleInstance: true,
      );

      // Afficher les tables disponibles une fois la base de données initialisée
      List<Map<String, dynamic>> tables =
          await database.query("sqlite_master", where: "type = 'table'");

      for (Map<String, dynamic> table in tables) {
        print(table["name"]);
      }

      return database;
    } catch (e) {
      throw Exception("Failed to open database: $e");
    }
  }

  Future<void> create(Database db, int version) async {
    try {
      await users_db().createTable(db);
      await acceuil_db().createTable(db);
      await missions_db().createTable(db);
      await compteurs_db().createTable(db);
      await client_db().createTable(db);
      await contrat_db().createTable(db);
      await releves_db().createTable(db);
      await last_connected_db().createTable(db);
    } catch (e) {
      throw Exception("Failed to create tables: $e");
    }
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String tableName) async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> rows = await db.query(tableName);
      return rows;
    } catch (e) {
      throw Exception("Failed to query all rows: $e");
    }
  }
}
