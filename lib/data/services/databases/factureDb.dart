  import 'package:sqflite/sqflite.dart';

class facture_db {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS facture (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          relevecompteur_id INTEGER,
          num_facture TEXT,
          num_compteur INTEGER,
          date_facture TEXT,
          total_conso_ht REAL,
          tarif_m3 REAL,
          avoir_avant REAL,
          avoir_utilise REAL,
          restant_precedant REAL,
          montant_total_ttc REAL,
          montant_payer REAL,
          statut TEXT
        )
      ''');
    } catch (e) {
      throw Exception("Failed to create facture table: $e");
    }
  }
}
