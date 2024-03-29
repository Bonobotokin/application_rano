import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/missions/missions_state.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/blocs/clients/client_event.dart';
import 'package:intl/intl.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:get/get.dart';

class MissionsPage extends StatefulWidget {
  @override
  _MissionsPageState createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: Color(0xFFF5F5F5),
          currentIndex: 1,
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
                      "Missions",
                      style: TextStyle(
                        color: Color(0xdd2e3131),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              BlocBuilder<MissionsBloc, MissionsState>(
                builder: (context, state) {
                  if (state is MissionsLoading) {
                    return _buildMissionListWidget(state.missions, authState);
                  } else if (state is MissionsLoaded) {
                    return _buildMissionListWidget(state.missions, authState);
                  } else if (state is MissionsLoadFailure) {
                    return Center(child: Text('Erreur: ${state.error}'));
                  } else if (state is MissionAdded) {
                    BlocProvider.of<MissionsBloc>(context).add(LoadMissions(
                        accessToken: authState is AuthSuccess
                            ? authState.userInfo.lastToken ?? ''
                            : ''));
                    return Center(child: CircularProgressIndicator());
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
      List<MissionModel> missions, AuthState authState) {
    missions.sort((a, b) {
      final aStatut = a.statut ?? 0;
      final bStatut = b.statut ?? 0;
      return aStatut.compareTo(bStatut);
    });

    final filteredMissions = _searchText.isEmpty
        ? missions
        : missions
        .where((mission) =>
    (mission.nomClient?.toLowerCase() ?? '')
        .contains(_searchText.toLowerCase()) ||
        (mission.prenomClient?.toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()) ||
        (mission.adresseClient?.toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()) ||
        (mission.numCompteur?.toString().toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()) ||
        (mission.volumeDernierReleve?.toString().toLowerCase() ?? '')
            .contains(_searchText.toLowerCase()))
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey, width: 1),
                color: Color(0xFFEEEEEE),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: TextField(
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
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

  // Construire une tuile pour chaque mission
  Widget _buildMissionTile(
      BuildContext context, MissionModel mission, AuthState authState) {
    Color cardColor =
    mission.statut == 1 ? Color(0xFFFFFFFF) : Color(0xFFBBDEFB);
    Color btnColor =
    mission.statut == 1 ? Color(0xFFEEE9E9) : Color(0xFFBBDEFB);
    String buttonText = mission.statut == 1 ? 'Modifier' : 'Ajouter';

    return GestureDetector(
      onTap: () {
        if (authState is AuthSuccess) {
          BlocProvider.of<ClientBloc>(context).add(LoadClients(
              accessToken: authState.userInfo.lastToken ?? '',
              numCompteur: mission.numCompteur ?? 0));
          Get.toNamed(AppRoutes.detailsReleverCompteur,
              arguments: mission.numCompteur);
        }
      },
      child: Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: cardColor,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Row(
            children: [
              Icon(Icons.account_circle,
                  color: mission.statut == 1 ? Colors.grey : Colors.blue),
              SizedBox(width: 8),
              Text(
                '${mission.nomClient} ${mission.prenomClient}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text('Adresse: ${mission.adresseClient}'),
              Text('Num Compteur: ${mission.numCompteur}'),
              Text('Volume Dernier Releve: ${mission.volumeDernierReleve}'),
              Text('Date Dernier Releve: ${mission.dateReleve}'),
            ],
          ),
          trailing: _buildLinkButton(context, mission, authState, buttonText),
        ),
      ),
    );
  }

  // Construire le bouton pour ajouter ou modifier une mission
  Widget _buildLinkButton(BuildContext context, MissionModel mission,
      AuthState authState, String buttonText) {
    return InkWell(
      onTap: () {
        // Afficher le formulaire pour ajouter ou modifier une mission
        _showFormDialog(context, mission, authState, isUpdate: mission.statut == 1);
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: mission.statut == 1 ? Color(0xFF1991B6) : Color(0xFF37087E),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 6),
            Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFormDialog(
      BuildContext context, MissionModel mission, AuthState authState, {bool isUpdate = false}) async {
    File? _image;
    TextEditingController volumeController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String dateValue = formattedDate;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Nouveaux consommation de ${mission.numCompteur}, ${mission.adresseClient} - $formattedDate',
            style: TextStyle(fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: volumeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Volumes'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: dateController,
                    readOnly: false,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      hintText: 'AAAA-MM-JJ',
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      _image = await _getImage();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Prendre une photo'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      String voluemeValue = volumeController.text;
                      String dateValue = dateController.text;

                      try {
                        // Ajouter ou mettre à jour la mission avec les détails fournis
                        if (isUpdate) {
                          BlocProvider.of<MissionsBloc>(context).add(UpdateMission(
                            missionId: mission.numCompteur.toString(),
                            adresseClient: mission.adresseClient.toString(),
                            consoValue: voluemeValue,
                            date: dateValue,
                            accessToken: authState is AuthSuccess
                                ? authState.userInfo.lastToken ?? ''
                                : '',
                          ));
                        } else {
                          BlocProvider.of<MissionsBloc>(context).add(AddMission(
                            missionId: mission.numCompteur.toString(),
                            adresseClient: mission.adresseClient.toString(),
                            consoValue: voluemeValue,
                            date: dateValue,
                            accessToken: authState is AuthSuccess
                                ? authState.userInfo.lastToken ?? ''
                                : '',
                          ));
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Mission ${isUpdate ? 'modifiée' : 'créée'} avec succès')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Erreur lors de la ${isUpdate ? 'modification' : 'création'} de la mission: $e')),
                        );
                      }
                    },
                    child: Text(isUpdate ? 'Modifier' : 'Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Sélectionner une image à partir de la caméra
  Future<File?> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('Aucune image sélectionnée.');
      return null;
    }
  }
}
