import 'package:application_rano/data/services/synchronisation/sync_facture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/factures/facture_bloc.dart';
import 'package:application_rano/blocs/factures/facture_event.dart';
import 'package:application_rano/blocs/home/home_bloc.dart';
import 'package:application_rano/blocs/home/home_state.dart';
import 'package:application_rano/data/models/home_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:application_rano/ui/shared/SyncDialog.dart';
import 'package:application_rano/data/repositories/auth_repository.dart';
import 'package:application_rano/data/services/synchronisation/missions/SyncMissionService.dart';
import 'package:application_rano/data/services/synchronisation/factures/SyncFactureService.dart';
import 'package:application_rano/data/services/synchronisation/anomalie/SyncAnomalieService.dart';
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
    _controller = TextEditingController(text: '50');
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
    bool canSendData = label == "Relevé de compteurs" && current > 0;
    bool canSyncMission = label == "Relevé de compteurs";
    bool canSendDataFacture = label == "Factures" && current > 0;
    bool canSyncFacture = label == "Factures";
    bool canSendDataAnomalie = label == "Main courante";
    bool canSyncAnomalie = label == "Main courante";

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

                          if (canSendData)
                            FutureBuilder<int>(
                              future: checkMissionsToSync(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return SizedBox(
                                    width: 20.0, // Définir la largeur souhaitée
                                    height: 20.0, // Définir la hauteur souhaitée
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0, // Vous pouvez également ajuster la largeur du trait si nécessaire
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Icon(Icons.error, color: Colors.red);
                                } else if (snapshot.hasData && snapshot.data! > 0) {
                                  return IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      _sendMissionData(context, authState);
                                    },
                                    tooltip: 'Envoyer les données',
                                  );
                                } else {
                                  return Container(); // Conteneur vide s'il n'y a pas de missions à envoyer
                                }
                              },
                            ),
                          if (canSendDataFacture)
                            FutureBuilder<int>(
                            future: checkFactureToSync(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return SizedBox(
                                  width: 20.0, // Définir la largeur souhaitée
                                  height: 20.0, // Définir la hauteur souhaitée
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0, // Vous pouvez également ajuster la largeur du trait si nécessaire
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Icon(Icons.error, color: Colors.red);
                              } else if (snapshot.hasData && snapshot.data! > 0) {
                                return IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: () {
                                    _sendFactureData(context, authState);
                                  },
                                  tooltip: 'Envoyer les données',
                                );
                              } else {
                                return Container(); // Conteneur vide s'il n'y a pas de missions à envoyer
                              }
                            },
                          ),
                          if (canSendDataAnomalie)
                            FutureBuilder<int>(
                              future: checkAnomalieToSync(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return SizedBox(
                                    width: 20.0, // Définir la largeur souhaitée
                                    height: 20.0, // Définir la hauteur souhaitée
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0, // Vous pouvez également ajuster la largeur du trait si nécessaire
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Icon(Icons.error, color: Colors.red);
                                } else if (snapshot.hasData && snapshot.data! > 0) {
                                  return IconButton(
                                    icon: const Icon(Icons.send),
                                    onPressed: () {
                                      _sendAnomalieData(context, authState);
                                    },
                                    tooltip: 'Envoyer les données',
                                  );
                                } else {
                                  return Container(); // Conteneur vide s'il n'y a pas de missions à envoyer
                                }
                              },
                            ),
                          if (canSyncMission || canSyncFacture || canSyncAnomalie)
                            IconButton(
                              icon: Icon(Icons.sync),
                              color: iconColor,
                              onPressed: () {
                                if (canSyncMission) {
                                  _syncData(context, authState, label);
                                } else if(canSyncFacture) {
                                  _syncDataFacture(context, authState, label);
                                } else {
                                  _syncDataAnomalie(context, authState, label);
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

  Future<int> checkMissionsToSync() async {
    final SyncMissionService syncMissionService = SyncMissionService();
    int numberOfMissions = await syncMissionService.getNumberOfMissionsToSync();

    return numberOfMissions;
  }

  Future<int> checkFactureToSync() async {
    final SyncFactureService syncFactureService = SyncFactureService();
    int numberOfFacture = await syncFactureService.getNumberOfFactureToSync();

    return numberOfFacture;
  }

  Future<int> checkAnomalieToSync() async {
    final SyncAnomalieService syncAnomalieService = SyncAnomalieService();
    int numberOfAnomalie = await syncAnomalieService.getNumberOfAnomaliesToSync();

    return numberOfAnomalie;
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
                  int? numData = int.tryParse(_controller.text);
                  if (numData != null && numData >= 1) {
                    // Envoyer les données des missions
                    final syncMissionService = SyncMissionService();
                    // Mettez à jour la valeur de progression ici
                    setState(() {
                      _progressValue = 0.0; // Réinitialiser la progression
                    });
                    // Envoyer les données des missions en mettant à jour la progression
                    await syncMissionService.sendDataMissionInserver(
                      authState.userInfo.lastToken ?? '',
                      numData,
                          (value) {
                        setState(() {
                          _progressValue = value;
                        });
                      },
                    );

                    // Fermer la boîte de dialogue après l'envoi des données
                    Navigator.of(context).pop();
                  }
                  else {
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

    // Afficher la boîte de dialogue de synchronisation initiale
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SyncDialog(
          duration: 0, // Initialisez la durée à 0 pour l'instant
        );
      },
    );

    if (authState is AuthSuccess) {
      try {
        // Appeler la fonction de synchronisation des relevés
        final SyncMissionService syncMissionService = SyncMissionService();
        final AuthRepository authRepository = AuthRepository(baseUrl: "http://89.116.38.149:8000/api");
        final durationMissionInSeconds = await syncMissionService.syncDataMissionToLocal(authState.userInfo.lastToken ?? '');
        await authRepository.fetchHomeDataFromEndpoint(authState.userInfo.lastToken ?? '');

        // Calculer la somme des durées
        final totalDurationInSeconds = durationMissionInSeconds;

        // Fermer la boîte de dialogue initiale après un certain temps
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        // Afficher la nouvelle boîte de dialogue avec la durée totale
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SyncDialog(
              duration: totalDurationInSeconds, // Passer la durée totale
            );
          },
        );

        // Fermer la nouvelle boîte de dialogue après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds), () {
          Navigator.of(context).pop();
        });

        // Terminer la synchronisation
        setState(() {
          _isSyncing = false;
        });

        // Afficher un message de succès après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds + 2), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label synchronisé avec succès',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        });
      } catch (error) {
        print("Erreur lors de la synchronisation : $error");
      }
    }
  }

  void _sendFactureData(BuildContext context, AuthState authState) async {
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
                  int? numData = int.tryParse(_controller.text);
                  if (numData != null && numData >= 1) {
                    // Envoyer les données des missions
                    final syncFactureService = SyncFactureService();
                    // Mettez à jour la valeur de progression ici
                    setState(() {
                      _progressValue = 0.0; // Réinitialiser la progression
                    });
                    // Envoyer les données des missions en mettant à jour la progression
                    await syncFactureService.sendDataFactureInserver(
                      authState.userInfo.lastToken ?? '',
                      numData,
                          (value) {
                        setState(() {
                          _progressValue = value;
                        });
                      },
                    );

                    // Fermer la boîte de dialogue après l'envoi des données
                    Navigator.of(context).pop();
                  }
                  else {
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

  void _syncDataFacture(BuildContext context, AuthState authState, String label) async {
    setState(() {
      _isSyncing = true; // Commencer la synchronisation
    });

    // Afficher la boîte de dialogue de synchronisation initiale
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SyncDialog(
          duration: 0, // Initialisez la durée à 0 pour l'instant
        );
      },
    );

    if (authState is AuthSuccess) {
      try {
        // Appeler la fonction de synchronisation des relevés
        final SyncFactureService syncFactureService = SyncFactureService();
        final AuthRepository authRepository = AuthRepository(baseUrl: "http://89.116.38.149:8000/api");
        final durationFactureInSeconds = await syncFactureService.syncDataFactureToLocal(authState.userInfo.lastToken ?? '');
        await authRepository.fetchHomeDataFromEndpoint(authState.userInfo.lastToken ?? '');

        // Calculer la somme des durées
        final totalDurationInSeconds = durationFactureInSeconds;

        // Fermer la boîte de dialogue initiale après un certain temps
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        // Afficher la nouvelle boîte de dialogue avec la durée totale
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SyncDialog(
              duration: totalDurationInSeconds, // Passer la durée totale
            );
          },
        );

        // Fermer la nouvelle boîte de dialogue après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds), () {
          Navigator.of(context).pop();
        });

        // Terminer la synchronisation
        setState(() {
          _isSyncing = false;
        });

        // Afficher un message de succès après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds + 2), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label synchronisé avec succès',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        });
      } catch (error) {
        print("Erreur lors de la synchronisation : $error");

        // Fermer les boîtes de dialogue en cas d'erreur
        Navigator.of(context).pop();

        setState(() {
          _isSyncing = false;
        });

        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la synchronisation',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  void _sendAnomalieData(BuildContext context, AuthState authState) async {
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
                  int? numData = int.tryParse(_controller.text);
                  if (numData != null && numData >= 1) {
                    // Envoyer les données des missions
                    final syncAnomalieService = SyncAnomalieService();
                    // Mettez à jour la valeur de progression ici
                    setState(() {
                      _progressValue = 0.0; // Réinitialiser la progression
                    });
                    // Envoyer les données des missions en mettant à jour la progression
                    await syncAnomalieService.sendAnomaliesToServer(
                      authState.userInfo.lastToken ?? '',
                      numData,
                          (value) {
                        setState(() {
                          _progressValue = value;
                        });
                      },
                    );

                    // Fermer la boîte de dialogue après l'envoi des données
                    Navigator.of(context).pop();
                  }
                  else {
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

  void _syncDataAnomalie(BuildContext context, AuthState authState, String label) async {
    setState(() {
      _isSyncing = true; // Commencer la synchronisation
    });

    // Afficher la boîte de dialogue de synchronisation initiale
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SyncDialog(
          duration: 0, // Initialisez la durée à 0 pour l'instant
        );
      },
    );

    if (authState is AuthSuccess) {
      try {
        // Appeler la fonction de synchronisation des relevés
        final SyncAnomalieService syncAnomalieService = SyncAnomalieService();
        final AuthRepository authRepository = AuthRepository(baseUrl: "http://89.116.38.149:8000/api");
        final durationAnomalieInSeconds = await syncAnomalieService.syncDataAnomalieToLocal(authState.userInfo.lastToken ?? '');
        await authRepository.fetchHomeDataFromEndpoint(authState.userInfo.lastToken ?? '');

        // Calculer la somme des durées
        final totalDurationInSeconds = durationAnomalieInSeconds;

        // Fermer la boîte de dialogue initiale après un certain temps
        Timer(Duration(seconds: 2), () {
          Navigator.of(context).pop();
        });

        // Afficher la nouvelle boîte de dialogue avec la durée totale
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return SyncDialog(
              duration: totalDurationInSeconds, // Passer la durée totale
            );
          },
        );

        // Fermer la nouvelle boîte de dialogue après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds), () {
          Navigator.of(context).pop();
        });

        // Terminer la synchronisation
        setState(() {
          _isSyncing = false;
        });

        // Afficher un message de succès après un certain temps
        Timer(Duration(seconds: totalDurationInSeconds + 2), () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label synchronisé avec succès',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        });
      } catch (error) {
        print("Erreur lors de la synchronisation : $error");

        // Fermer les boîtes de dialogue en cas d'erreur
        Navigator.of(context).pop();

        setState(() {
          _isSyncing = false;
        });

        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la synchronisation',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
