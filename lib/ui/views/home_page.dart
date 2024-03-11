import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/home/home_state.dart';
import 'package:application_rano/data/models/home_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/ui/routing/routes.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: Color(0xFFF5F5F5),
          currentIndex: 0,
          authState: authState,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rapport",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoaded) {
                    return _buildHomePageWithData(
                        context, state.data, authState);
                  } else if (state is HomeLoading) {
                    return _buildHomePageWithData(
                        context, state.data, authState);
                  } else if (state is HomeError) {
                    return Center(
                        child: Text(
                            'Oh non! Une erreur s\'est produite: ${state.message}',
                            style: TextStyle(color: Colors.red)));
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildHomePageWithData(
    BuildContext context, HomeModel? data, AuthState authState) {
  if (data != null) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildCard(
                  context,
                  data.nombreReleverEffectuer,
                  data.nombreTotalCompteur,
                  "Relevé de compteurs",
                  Icons.assignment,
                  Color(0x80FAD203)!,
                  authState),
              SizedBox(height: 16),
              _buildCard(
                  context,
                  data.realise,
                  data.totaleAnomalie,
                  "Main courante",
                  Icons.report_problem,
                  Color(0x9987D9E1)!,
                  authState),
              SizedBox(height: 16),
              _buildCard(context, 20, 20, "Factures", Icons.receipt,
                  Color(0xA6BE9BF3)!, authState),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  } else {
    return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange)));
  }
}

Widget _buildCard(BuildContext context, int current, int total, String label,
    IconData icon, Color bgColor, AuthState authState) {
  Color iconColor = Colors.black54;
  Color progressColor = getProgressColor(label);

  double progress = total != 0 ? current / total : 0.0;
  String tasksText = getTaskText(label, current, total);

  return GestureDetector(
    onTap: () {
      if (authState is AuthSuccess) {
        if (label == "Relevé de compteurs") {
          _handleReleveDeCompteurs(context, authState);
        } else if (label == "Main courante") {
          // Redirect to Main courante page
        } else if (label == "Traites") {
          // Redirect to Traites page
        } else if (label == "Factures") {
          // Redirect to Factures page
        }
      }
    },
    child: Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFF6F1F1).withOpacity(0.1), // Couleur de l'ombre
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3), // Décalage de l'ombre
            ),
          ],
        ),
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: Color(0xEA020D1C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tasksText,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Color(0xE5ECE6E3),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
                SizedBox(height: 8),
                Text(
                  '$current / $total',
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Color getProgressColor(String label) {
  Map<String, Color> titleToProgressColor = {
    "Relevé de compteurs": Colors.deepOrange,
    "Main courante": Colors.blue,
    "Traites": Colors.orange,
    "Factures": Colors.purple,
  };

  return titleToProgressColor[label] ?? Colors.grey;
}

String getTaskText(String label, int current, int total) {
  String taskText;
  if (current != 0 || total != 0) {
    if (current != total) {
      taskText = 'Reste à faire : ${total - current}';
    } else {
      switch (label) {
        case "Relevé de compteurs":
          taskText = 'Relevés terminés';
          break;
        case "Main courante":
          taskText = 'Main courante terminés';
          break;
        case "Traites":
          taskText = 'Tâches traitées';
          break;
        case "Factures":
          taskText = 'Factures réglées';
          break;
        default:
          taskText = 'Tâches terminées';
      }
    }
  } else {
    switch (label) {
      case "Relevé de compteurs":
        taskText = 'Pas de relevé';
        break;
      case "Main courante":
        taskText = 'Pas de main courantes';
        break;
      case "Traites":
        taskText = 'Pas de tâche';
        break;
      case "Factures":
        taskText = 'Aucune facture';
        break;
      default:
        taskText = 'Pas de tâche';
    }
  }
  return taskText;
}

void _handleReleveDeCompteurs(BuildContext context, AuthSuccess authState) {
  BlocProvider.of<MissionsBloc>(context)
      .add(LoadMissions(accessToken: authState.userInfo.lastToken ?? ''));
  Get.toNamed(AppRoutes.missions);
}
