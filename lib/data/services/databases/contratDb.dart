import 'package:sqflite/sqflite.dart';

class contrat_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS contrat (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          numero_contrat TEXT,
          client_id INTEGER,
          date_debut TEXT,
          date_fin TEXT NULL,
          adresse_contrat TEXT,
          pays_contrat TEXT,
          FOREIGN KEY (client_id) REFERENCES client(id)
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create contrat table: $e");
    }
  }
}
