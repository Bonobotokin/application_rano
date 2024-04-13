import 'package:sqflite/sqflite.dart';
class facture_payment_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS facture_paiment (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          facture_id INTEGER,
          relevecompteur_id INTEGER,
          paiement REAL,
          date_paiement TEXT,
          statut TEXT NULL,
          FOREIGN KEY (facture_id) REFERENCES facture(id),
          FOREIGN KEY (relevecompteur_id) REFERENCES releves(id) 
        )
      ''');
    } catch (e) {
      throw Exception("Failed to create facture table: $e");
    }
  }
}