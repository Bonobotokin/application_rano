import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:application_rano/ui/views/Logo.dart';
import 'package:application_rano/ui/views/login_page.dart';
import 'package:application_rano/ui/views/home_page.dart';
import 'package:application_rano/ui/views/missions_page.dart';
import 'package:application_rano/ui/views/clients/detail_compteur_page.dart';
import 'package:application_rano/ui/views/clients/client_info_page.dart';
import 'package:application_rano/ui/views/clients/payement_facture.dart';

class AppRoutes {
  static const String logo = '/logo';
  static const String login = '/login';
  static const String home = '/home';
  static const String missions = '/missions';
  static const String detailsReleverCompteur = '/detailReleveCompt';
  static const String clientInfo = '/clientInfo';
  static const String facturePayed = '/facturePayed'; // Définir la route facturePayed
}

List<GetPage> getAppRoutes() {
  return [
    GetPage(
      name: AppRoutes.logo,
      page: () => Logo(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomePage(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.missions,
      page: () => MissionsPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.detailsReleverCompteur,
      page: () => DetailCompteurPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.clientInfo,
      page: () => ClientInfoPage(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
    GetPage(
      name: AppRoutes.facturePayed,
      page: () => PaymentFacture(),
      transition: Transition.noTransition,
      transitionDuration: Duration(seconds: 0),
    ),
  ];
}
