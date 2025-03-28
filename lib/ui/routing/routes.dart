import 'package:application_rano/ui/views/anomalie/commentaire_page.dart';
import 'package:application_rano/ui/views/anomalie/update_anomaly_page.dart';
import 'package:application_rano/ui/views/factures/client_facture_liste.dart';
import 'package:application_rano/ui/views/factures/client_list_page.dart';
import 'package:get/get.dart';
import 'package:application_rano/ui/views/Logo.dart';
import 'package:application_rano/ui/views/login_page.dart';
import 'package:application_rano/ui/views/home_page.dart';
import 'package:application_rano/ui/views/missions_page.dart';
import 'package:application_rano/ui/views/clients/detail_compteur_page.dart';
import 'package:application_rano/ui/views/clients/client_info_page.dart';
import 'package:application_rano/ui/views/clients/payement_facture.dart';
import 'package:application_rano/ui/views/anomalie/anomalie_page.dart';

class AppRoutes {
  static const String logo = '/logo';
  static const String login = '/login';
  static const String home = '/home';
  static const String missions = '/missions';
  static const String detailsReleverCompteur = '/detailReleveCompt';
  static const String clientInfo = '/clientInfo';
  static const String facturePayed = '/facturePayed'; // Définir la route facturePayed
  static const String anomaliePage = '/anomaliePage';
  static const String anomalieUpdate = '/updateAnomalie';
  static const String listeClient = '/listeClient';
  static const String listeFactureClient = '/listeFactureCLient';
  static const String commentaire = '/commentaire';
}

List<GetPage> getAppRoutes() {
  return [
    GetPage(
      name: AppRoutes.logo,
      page: () => const Logo(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.missions,
      page: () => const MissionsPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.detailsReleverCompteur,
      page: () => const DetailCompteurPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.clientInfo,
      page: () => const ClientInfoPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.facturePayed,
      page: () => const PaymentFacture(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.anomaliePage,
      page: () => const AnomaliePage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.listeClient,
      page: () => ClientListPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.listeFactureClient,
      page: () => ClientFactureList(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),

    GetPage(
      name: AppRoutes.anomalieUpdate,
      page: () => UpdateAnomalyPage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),

    GetPage(
      name: AppRoutes.commentaire,
      page: () => CommentairePage(),
      transition: Transition.noTransition,
      transitionDuration: const Duration(seconds: 0),
    ),
  ];
}
