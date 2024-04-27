import 'package:application_rano/blocs/server/server_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/server/server_bloc.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/ui/views/Logo.dart';
import '../widgets/CustomLinearProgressIndicator.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ServerBloc _serverBloc;

  @override
  void initState() {
    super.initState();
    _serverBloc = BlocProvider.of<ServerBloc>(context);
    _serverBloc
        .add(const CheckServerStatusEvent('Vérification de l\'état du serveur'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<ServerBloc, ServerStatus>(
          listener: (context, status) async {
            if(status == ServerStatus.connected) {
              // print("Synchronisation réussie. Redirection vers la page de connexion...");
              Future.delayed(const Duration(seconds: 5), () {
                Get.offNamed(
                    AppRoutes.login); // Redirection vers la page de connexion
              });
            } else if (status == ServerStatus.disconnected) {
              // print("Serveur déconnecté. Affichage du message d'erreur...");
              Future.delayed(const Duration(seconds: 5), () {
                Get.offNamed(AppRoutes.login);
              });
            }
          },
          builder: (context, status) {
            if (status == ServerStatus.loading) {
              return _buildLoadingWidget("Connexion en cours ...");
            } else if (status == ServerStatus.connected) {
              return _buildLoadingWidget("Connexion rétablie ...");
            }
            // else if (status == ServerStatus.synchronizing) {
            //   return _buildLoadingWidget("Synchronisation en cours ...");
            // }
            else if (status == ServerStatus.disconnected) {
              return _buildErrorWidget("serveur erreur, locale demarrer");
            } else {
              return Container(); // Retourner un widget vide par défaut
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingWidget(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Logo(),
        const SizedBox(height: 16),
        const CustomLinearProgressIndicator(),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Logo(),
        const SizedBox(height: 16),
        CircularProgressIndicator(
          backgroundColor: Colors.grey[200],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
        ),
        const SizedBox(height: 16),
        Text(message),
      ],
    );
  }
}
