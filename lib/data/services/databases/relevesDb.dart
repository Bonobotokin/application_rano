import 'package:sqflite/sqflite.dart';

class releves_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS releves (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_releve INTEGER,
          compteur_id INTEGER,
          contrat_id INTEGER,
          client_id INTEGER,
          date_releve TEXT,
          volume INTEGER,
          conso INTEGER,          
          etatFacture TEXT,
          image_compteur TEXT,
          FOREIGN KEY (compteur_id) REFERENCES compteur(id),
          FOREIGN KEY (contrat_id) REFERENCES contrat(id),
          FOREIGN KEY (client_id) REFERENCES client(id)
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create client table: $e");
    }
  }
}