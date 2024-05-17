import 'package:intl/intl.dart'; // Importez le package intl pour formater les dates
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  static String formatFrenchDate(String dateString) {
    // Initialise les données de localisation pour le français
    initializeDateFormatting('fr_FR', null);

    try {
      // Convertir la chaîne en objet DateTime
      DateTime date = DateTime.parse(dateString);
      // Utiliser le package intl pour formater la date en français
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      print('Erreur de format de date: $e');
      return 'Format de date invalide';
    }
  }
  static bool isValidFrenchDate(String dateStr) {
    try {
      // Utiliser le parseur de dates de intl package pour vérifier la validité de la date
      DateFormat('dd-MM-yyyy').parseStrict(dateStr);
      return true;
    } catch (e) {
      return false;
    }
  }


}
