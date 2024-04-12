import 'package:intl/intl.dart'; // Importez le package intl pour formater les dates
import 'package:intl/date_symbol_data_local.dart';

class DateFormatter {
  static String formatFrenchDate(String dateString) {
    // Initialise les données de localisation pour le français
    initializeDateFormatting('fr_FR', null);

    DateTime date = DateTime.parse(dateString); // Convertir la chaîne en objet DateTime
    // Utiliser le package intl pour formater la date en français
    return DateFormat.yMMMMd('fr_FR').format(date);
  }
}
