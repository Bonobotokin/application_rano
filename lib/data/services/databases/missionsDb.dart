import 'package:sqflite/sqflite.dart';

class missions_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE missions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom_client TEXT,
          prenom_client TEXT,
          adresse_client TEXT,
          num_compteur INTEGER,
          conso_dernier_releve INTEGER,
          volume_dernier_releve INTEGER,
          date_releve TEXT,
          statut INTEGER
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create mission table: $e");
    }
  }
}