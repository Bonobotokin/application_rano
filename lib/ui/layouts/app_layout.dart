import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/home/home_event.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/factures/facture_event.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;
  final int currentIndex;
  final AuthState authState;

  const AppLayout({
    Key? key,
    required this.body,
    required this.backgroundColor,
    required this.currentIndex,
    required this.authState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Padding(
            padding: const EdgeInsets.only(
                top: 16), // Ajoute un espacement en haut du contenu
            child: body,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context, authState),
          extendBody:
          true, // Permet au corps de s'étendre derrière le BottomNavigationBar
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, AuthState authState) {
    return Stack(
      children: [
        BottomNavigationBar(
          iconSize: 25,
          unselectedItemColor: const Color(0xEA020D1C).withOpacity(0.5678),
          selectedItemColor: const Color(0xFFFF5722),
          elevation: 0,
          backgroundColor: const Color(0xB3EFEEEE),
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (value) {
            switch (value) {
              case 0:
                if (authState is AuthSuccess) {
                  BlocProvider.of<HomeBloc>(context).add(RefreshHomePageData(
                      accessToken: authState.userInfo.lastToken ?? ''));
                  Get.offNamed(AppRoutes.home);
                }
                break;
              case 1:
                if (authState is AuthSuccess) {
                  BlocProvider.of<MissionsBloc>(context).add(LoadMissions(
                      accessToken: authState.userInfo.lastToken ?? ''));
                  Get.offNamed(AppRoutes.missions);
                }
                break;
              case 2:
                if (authState is AuthSuccess) {
                  BlocProvider.of<AnomalieBLoc>(context).add(LoadAnomalie(
                      accessToken: authState.userInfo.lastToken ?? ''));
                  Get.offNamed(AppRoutes.anomaliePage);
                }
                break;
              case 3:
                if (authState is AuthSuccess) {
                  BlocProvider.of<FactureBloc>(context).add(LoadClientFacture(
                      accessToken: authState.userInfo.lastToken ?? ''));
                  Get.offNamed(AppRoutes.listeClient);
                }
                break;
              case 5:
                if (authState is AuthSuccess) {
                  _showLogoutConfirmationDialog(context);
                }
                break;
              default:
                break;
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Accueil",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Compteurs",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.error_outline_sharp),
              label: "Anomalies",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt),
              label: "Facture",
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  if (authState is AuthSuccess) {
                    _showLogoutConfirmationDialog(context);
                  }
                },
                child: const Icon(Icons.power_off),
              ),
              label: 'Quiter',
            ),
          ],
        ),
        Positioned(
          top: -10, // Ajustez la valeur selon votre préférence
          left: 0,
          right: 0,
          child: Container(
            height: 20, // Hauteur de l'ombre
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Déconnexion"),
          content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                // Fermer l'application
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
              child: const Text("Confirmer"),
            ),
          ],
        );
      },
    );
  }
}
