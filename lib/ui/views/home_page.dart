import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/factures/facture_event.dart';
import 'package:application_rano/data/services/synchronisation/missions/send_data_mission_sync.dart';
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
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _controller;
  double _progressValue = 0.0;
  bool _isSyncing = false; // Variable pour suivre l'état de la synchronisation


  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 0,
          authState: authState,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: const Row(
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
                    return _buildHomePageWithData(context, state.data, authState);
                  } else if (state is HomeLoading) {
                    return _buildHomePageWithData(context, state.data, authState);
                  } else if (state is HomeError) {
                    return Center(
                      child: Text(
                        'Oh non! Une erreur s\'est produite: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
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

  Widget _buildHomePageWithData(BuildContext context, HomeModel? data, AuthState authState) {
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
                  const Color(0x80FAD203),
                  authState,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  data.nombreTotalFacturePayer,
                  data.nombreTotalFactureImpayer,
                  "Factures",
                  Icons.receipt,
                  const Color(0xA6BE9BF3),
                  authState,
                ),
                const SizedBox(height: 16),
                _buildCard(
                  context,
                  data.realise,
                  data.totaleAnomalie,
                  "Main courante",
                  Icons.report_problem,
                  const Color(0x9987D9E1),
                  authState,
                  enCours: data.enCours,
                  nonTraite: data.nonTraite,
                  realise: data.realise,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      );
    }
  }

  Widget _buildCard(
      BuildContext context,
      int current,
      int total,
      String label,
      IconData icon,
      Color bgColor,
      AuthState authState, {
        int? enCours,
        int? nonTraite,
        int? realise,
      }) {
    Color iconColor = Colors.black54;
    Color progressColor = getProgressColor(label);

    double progress = total != 0 ? current / total : 0.0;
    String tasksText = getTaskText(label, current, total, extraData: {
      'En cours': enCours ?? 0,
      'Non traité': nonTraite ?? 0,
      'Réalisé': realise ?? 0,
    });

    return GestureDetector(
      onTap: () {
        if (!_isSyncing && authState is AuthSuccess) {
          if (label == "Relevé de compteurs") {
            _handleReleveDeCompteurs(context, authState);
          } else if (label == "Factures") {
            _handleFactures(context, authState);
          } else if (label == "Main courante") {
            _handleAnomalie(context, authState);
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
                color: const Color(0xFFF6F1F1).withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
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
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xE5ECE6E3),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$current / $total',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              if (label == "Relevé de compteurs" && current > 0) {
                                _sendMissionData(context, authState);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Aucune donnée à envoyer',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            tooltip: 'Envoyer les données',
                          ),
                          IconButton(
                            icon: Icon(Icons.sync),
                            color: iconColor,
                            onPressed: () {
                              if (!_isSyncing && current > 0) {
                                _syncData(context, authState, label);
                              }
                            },
                          ),
                        ],
                      ),

                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMissionData(BuildContext context, AuthState authState) async {
    if (authState is AuthSuccess) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Envoyer les données'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Nombre de données à envoyer'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nombre';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Utilisez la valeur de progression mise à jour ici
                LinearProgressIndicator(value: _progressValue),
                SizedBox(height: 10),
                Text('Veuillez patienter...'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  int numData = int.tryParse(_controller.text) ?? 0;
                  if (numData >= 50) {
                    // Envoyer les données des missions
                    final sendDataMissionSync = SendDataMissionSync();
                    // Mettez à jour la valeur de progression ici
                    setState(() {
                      _progressValue = 0.0; // Réinitialiser la progression
                    });
                    // Envoyer les données des missions en mettant à jour la progression
                    await sendDataMissionSync.sendDataMissionInserver(authState.userInfo.lastToken ?? '', (progress) {
                      // Mettre à jour la valeur de progression ici
                      setState(() {
                        _progressValue = progress;
                      });
                    });

                    // Fermer la boîte de dialogue après l'envoi des données
                    Navigator.of(context).pop();
                  } else {

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Le nombre minimum de données à envoyer est de 50',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Valider'),
              ),
            ],
          );
        },
      );
    } else {
      // Gérer le cas où authState n'est pas AuthSuccess
    }
  }
  void _syncData(BuildContext context, AuthState authState, String label) async {
    setState(() {
      _isSyncing = true; // Commencer la synchronisation
    });

    // Afficher la boîte de dialogue de synchronisation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Synchronisation en cours...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Veuillez patienter...'),
            ],
          ),
        );
      },
    );

    if (authState is AuthSuccess) {
      // Appeler la fonction de synchronisation des relevés
      await _syncReleveData(context, authState); // Attendre la fin de la synchronisation
    }

    // Terminer la synchronisation
    setState(() {
      _isSyncing = false;
    });

    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label synchronisé avec succès',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _syncReleveData(BuildContext context, AuthSuccess authState) async {
    // Synchroniser les relevés
    final SendDataMissionSync sendDataMissionSync = SendDataMissionSync();
    await sendDataMissionSync.syncDataMissionToLocal(authState.userInfo.lastToken ?? '');
    await sendDataMissionSync.syncDataFactureToLocal(authState.userInfo.lastToken ?? '');

    // Masquer la barre de progression
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Fermer le popup de synchronisation
    Navigator.of(context).pop();
  }



  void _syncFacturesData(BuildContext context, AuthSuccess authState) async {
    // Synchroniser les factures
    final SendDataMissionSync sendDataMissionSync = SendDataMissionSync();
    await sendDataMissionSync.syncDataFactureToLocal(authState.userInfo.lastToken ?? '');

    // Masquer la barre de progression
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }




  void _handleReleveDeCompteurs(BuildContext context, AuthSuccess authState) {
    BlocProvider.of<MissionsBloc>(context)
        .add(LoadMissions(accessToken: authState.userInfo.lastToken ?? ''));
    Get.toNamed(AppRoutes.missions);
  }

  void _handleAnomalie(BuildContext context, AuthSuccess authState) {
    BlocProvider.of<AnomalieBLoc>(context)
        .add(LoadAnomalie(accessToken: authState.userInfo.lastToken ?? ''));
    Get.toNamed(AppRoutes.anomaliePage);
  }

  void _handleFactures(BuildContext context, AuthSuccess authState) {
    BlocProvider.of<FactureBloc>(context).add(LoadClientFacture(accessToken: authState.userInfo.lastToken ?? ''));
    Get.toNamed(AppRoutes.listeClient);
  }

  Color getProgressColor(String label) {
    Map<String, Color> titleToProgressColor = {
      "Relevé de compteurs": Colors.deepOrange,
      "Main courante": Colors.blue,
      "Factures": Colors.purple,
    };

    return titleToProgressColor[label] ?? Colors.grey;
  }

  String getTaskText(String label, int current, int total, {Map<String, int>? extraData}) {
    String taskText;
    int remainingTasks = total - current;

    if (label == "Main courante" && extraData != null) {
      return extraData.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
    }

    if (current != 0 || total != 0) {
      if (remainingTasks > 0) {
        taskText = 'Reste à faire : $remainingTasks';
      } else {
        taskText = 'Tâches terminées';
      }
    } else {
      switch (label) {
        case "Relevé de compteurs":
          taskText = 'Pas de relevé';
          break;
        case "Main courante":
          taskText = 'Pas de main courantes';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
