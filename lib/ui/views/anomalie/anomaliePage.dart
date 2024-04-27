import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';

import 'new_anomaly_page.dart';

class AnomaliePage extends StatefulWidget {
  const AnomaliePage({super.key});

  @override
  _AnomaliePageState createState() => _AnomaliePageState();
}

class _AnomaliePageState extends State<AnomaliePage> {
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 2,
          authState: authState,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Anomalie",
                      style: TextStyle(
                        color: Color(0xdd2e3131),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Naviguer vers une nouvelle page pour créer une nouvelle anomalie
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewAnomalyPage()), // Remplacez NewAnomalyPage() par le nom de votre page de création d'anomalie
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      ),
                      child: Text(
                        'Nouvelles anomalies',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  ],
                ),
              ),
              BlocBuilder<AnomalieBLoc, AnomalieState>(
                builder: (context, state) {
                  if (state is AnomalieLoading) {
                    return _buildMissionListWidget(state.anomalie, authState);
                  } else if (state is AnomalieLoaded) {
                    return _buildMissionListWidget(state.anomalie, authState);
                  } else if (state is AnomalieError) {
                    return Center(child: Text('Erreur: ${state.message}'));
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

  Widget _buildMissionListWidget(
      List<AnomalieModel> anomalie, AuthState authState) {
    anomalie.sort((a, b) {
      final aStatut = a.status ?? 0;
      final bStatut = b.status ?? 0;
      return aStatut.compareTo(bStatut);
    });

    final filteredMissions = _searchText.isEmpty
        ? anomalie
        : anomalie
        .where((anomalie) =>
    (anomalie.typeMc?.toLowerCase() ?? '')
        .contains(_searchText.toLowerCase()) ||
        (anomalie.dateDeclaration?.toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()))
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey, width: 1),
                color: const Color(0xFFEEEEEE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: TextField(
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher...',
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                    });
                  },
                ),
              ),
            ),
          ),
          if (filteredMissions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_rounded,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aucun résultat trouvé',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredMissions.length,
                itemBuilder: (context, index) {
                  final mission = filteredMissions[index];
                  return _buildMissionTile(context, mission, authState);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMissionTile(BuildContext context, AnomalieModel anomalie, AuthState authState) {
    String status;
    if (anomalie.status == 0) {
      status = "Non Traitée";
    } else if (anomalie.status == 1) {
      status = "En Cours";
    } else {
      status = "Réussie";
    }

    Color cardColor = anomalie.status == 1 ? const Color(0xFFFFFFFF) : const Color(0xFFBBDEFB);
    Color btnColor = anomalie.status == 1 ? const Color(0xFFEEE9E9) : const Color(0xFFBBDEFB);
    String buttonText = anomalie.status == 1 ? 'Modifier' : 'Ajouter';

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anomalie : ${anomalie.typeMc}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: anomalie.status == 0 ? Colors.red : anomalie.status == 1 ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text(
                'Détails',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Text(
                  'Longitude: ${anomalie.descriptionMc}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Altitude: ${anomalie.descriptionMc}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Déclarant: ${anomalie.clientDeclare}',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  'Date: ${anomalie.dateDeclaration}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Description :',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${anomalie.descriptionMc}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Text(
                  'Images :',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    for (int i = 1; i <= 5; i++)
                      if (anomalie.getPhotoAnomalie(i) != null &&
                          anomalie.getPhotoAnomalie(i)!.isNotEmpty &&
                          File(anomalie.getPhotoAnomalie(i)!).existsSync())
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: Image.file(
                                    File(anomalie.getPhotoAnomalie(i)!),
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            );
                          },
                          child: Image.file(
                            File(anomalie.getPhotoAnomalie(i)!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}