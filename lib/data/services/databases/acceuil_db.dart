import 'package:sqflite/sqflite.dart';
class AcceuilDb {
  Future<void> createTable(Database db) async {
    try {
      await db.execute('''
        CREATE TABLE acceuil (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          non_traite INTEGER,
          en_cours INTEGER,
          totale_anomalie INTEGER,
          realise INTEGER,
          nombre_total_compteur INTEGER,
          nombre_relever_effectuer INTEGER,
          nombre_total_facture_impayer INTEGER,
          nombre_total_facture_payer INTEGER
        );
      ''');
    } catch (e) {
      throw Exception("Failed to create accueil table: $e");
    }
  }
}