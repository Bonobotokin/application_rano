import 'dart:math';
import 'dart:io';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'new_anomaly_page.dart';
import '../../shared/DateFormatter.dart';
import '../../shared/MaskedTextField.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


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
                    return FutureBuilder(
                      future: Future.delayed(Duration(seconds: 2)), // Ajoute un délai de 2 secondes
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return _buildAnomalieListWidget(state.anomalie, authState);
                        }
                      },
                    );
                  } else if (state is AnomalieLoaded) {
                    return _buildAnomalieListWidget(state.anomalie, authState);
                  } else if (state is AnomalieError) {
                    return Center(child: Text('Erreur: ${state.message}'));
                  } else if (state is AnomalieUpdateLoaded) {
                    return _buildAnomalieListWidget(state.anomalieList, authState);
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

  Widget _buildAnomalieListWidget(
      List<AnomalieModel> anomalie, AuthState authState) {
    anomalie.sort((a, b) {
      final aStatut = a.status ?? 0;
      final bStatut = b.status ?? 0;
      // Trie les anomalies en fonction du statut dans l'ordre décroissant
      return bStatut.compareTo(aStatut);
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
                  final anomalie = filteredMissions[index];
                  return _buildAnomalieTile(context, anomalie, authState);
                },
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildAnomalieTile(BuildContext context, AnomalieModel anomalie, AuthState authState) {
    String status;
    Color statusColor;
    bool showButton = false;

    // Déterminer le statut de l'anomalie et la couleur correspondante
    switch(anomalie.status) {
      case 0:
        status = "Non Traitée";
        statusColor = Colors.red;
        break;
      case 1:
        status = "En Cours";
        statusColor = Colors.orange;
        break;
      case 2:
        status = "Réussie";
        statusColor = Colors.green;
        break;
      case 3:
        status = "En cours de validation";
        statusColor = Colors.purple;
        break;
      case 4:
        status = "En attente";
        statusColor = Colors.indigo;
        showButton = true; // Afficher le bouton si le statut est 4
        break;
      default:
        status = "En attente";
        statusColor = Colors.indigo;
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Ajustement de la marge interne
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Row(
                children: [
                  Icon(Icons.error_outline_outlined,
                      color: anomalie.status == 1 ? Colors.grey : Colors.red),
                  const SizedBox(width: 8),
                  Flexible( // Utilisation de Flexible pour ajuster la taille du texte
                    child: Text(
                      '${anomalie.typeMc} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Statut: ${status}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: statusColor,
                    ),
                  ),
                  Text('Longitude: ${anomalie.longitudeMc}'),
                  Text('Altitude: ${anomalie.latitudeMc}'),
                  Text('Desscription : ${anomalie.descriptionMc}'),
                  Text('Client : ${anomalie.clientDeclare}'),
                  Text('Commune : ${anomalie.commune} '),
                  Text('Cp Commune : ${anomalie.cpCommune}'),
                  // Text('COmmentaire : ${anomalie.}'),
                  Text(
                    'Date: ${
                        (anomalie.dateDeclaration != null || anomalie.dateDeclaration != '' || DateFormatter.isValidFrenchDate(anomalie.dateDeclaration!))
                            ? DateFormatter.formatFrenchDate(anomalie.dateDeclaration!)
                            : 'Erreur de date'
                    }',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: statusColor,
                    ),
                  ),

                ],
              ),
              trailing: showButton ? ElevatedButton(
                onPressed: () {
                  if (authState is AuthSuccess) {
                    BlocProvider.of<AnomalieBLoc>(context).add(GetUpdateAnomalie(idMc: anomalie.idMc!));
                    Get.toNamed(AppRoutes.anomalieUpdate,
                        arguments: anomalie.idMc);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor : Colors.lightBlueAccent,
                ),
                child: Text(
                  'Modification',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ) : null,
            ),
            SizedBox(height: 8), // Espacement entre le contenu et les images
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
      ),
    );
  }
}
