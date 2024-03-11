import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/home/home_event.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';

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
            padding: EdgeInsets.only(
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
          unselectedItemColor: Color(0xEA020D1C).withOpacity(0.5678),
          selectedItemColor: Color(0xFFFF5722),
          elevation: 0,
          backgroundColor: Color(0xB3EFEEEE),
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
              case 2: // Correspond à l'icône de notification
                // Ajoutez ici la logique pour gérer les notifications
                break;
              case 5: // Correspond à l'icône de profil
                if (authState is AuthSuccess) {
                  _showUserInfoDialog(context, authState);
                }
                break;
              // Ajoutez d'autres cas selon vos besoins
              default:
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Accueil",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Compteurs",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.error_outline_sharp),
              label: "Anomalies",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: GestureDetector(
                onTap: () {
                  if (authState is AuthSuccess) {
                    _showUserInfoDialog(context, authState);
                  }
                },
                child: Icon(Icons.person_2_outlined),
              ),
              label: 'Profil',
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

  void _showUserInfoDialog(BuildContext context, AuthSuccess authState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          // Wrap with GestureDetector
          onTap: () {
            Navigator.of(context).pop(); // Close modal on tap
          },
          child: Container(
            padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, -3), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Informations de l\'utilisateur',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                _buildUserInfoItem('Nom', authState.userInfo.name),
                _buildUserInfoItem('Commune', authState.userInfo.cpCommune),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfoItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        '$label: ${value ?? 'Non spécifié'}',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
