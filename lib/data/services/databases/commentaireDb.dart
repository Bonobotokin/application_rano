import 'package:sqflite/sqflite.dart';

class commentaire_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE commentaire (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_mc INTEGER,
          id_suivie INTEGER,
          date_suivie INTEGER,
          commentaire_suivie TEXT,
          statut INTEGER,
          FOREIGN KEY (id_mc) REFERENCES anomalie(id)
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create commentaire table: $e");
    }
  }
}
