import 'package:application_rano/data/services/api/api_local.dart';
import 'package:flutter/foundation.dart';

class LocalRepository {
  final ApiLocal apiLocal;

  LocalRepository(this.apiLocal);

  Future<void> saveDataLocally(String data) async {
    try {
      await apiLocal.saveDataLocally(data);
      debugPrint('Données enregistrées localement avec succès');
    } catch (error) {
      debugPrint('Erreur lors de l\'enregistrement des données localement : $error');
      rethrow;
    }
  }

  Future<String> getLocalData() async {
    try {
      return await apiLocal.getLocalData();
    } catch (error) {
      debugPrint('Erreur lors de la récupération des données locales : $error');
      rethrow;
    }
  }
}
