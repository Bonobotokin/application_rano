import 'dart:io';
import 'package:flutter/services.dart';
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
import '../shared/DateFormatter.dart';
import '../shared/MaskedTextField.dart';

class MissionsPage extends StatefulWidget {
  const MissionsPage({Key? key}) : super(key: key);

  @override
  _MissionsPageState createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  String _searchText = '';

  // Déclarez une variable pour stocker le chemin de l'image sélectionnée
  late String _imagePath = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 1,
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
                  } else if (state is MissionAdded ) {
                    BlocProvider.of<MissionsBloc>(context).add(LoadMissions(
                      accessToken: authState is AuthSuccess
                          ? authState.userInfo.lastToken ?? ''
                          : '',
                    ));
                    return const Center(child: CircularProgressIndicator());
                  }else if (state is MissionUpdated ) {
                    BlocProvider.of<MissionsBloc>(context).add(LoadMissions(
                      accessToken: authState is AuthSuccess
                          ? authState.userInfo.lastToken ?? ''
                          : '',
                    ));
                    return const Center(child: CircularProgressIndicator());
                  }
                  else {
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
        (mission.volumeDernierReleve?.toString().toLowerCase() ??
            '')
            .contains(_searchText.toLowerCase()))
        .toList();

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
              margin:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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

  Widget _buildMissionTile(
      BuildContext context, MissionModel mission, AuthState authState) {
    Color cardColor =
    mission.statut == 1 ? const Color(0xFFFFFFFF) : const Color(0xFFBBDEFB);
    Color btnColor =
    mission.statut == 1 ? const Color(0xFFEEE9E9) : const Color(0xFFBBDEFB);
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
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: cardColor,
        child: ListTile(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: Row(
            children: [
              Icon(Icons.account_circle,
                  color: mission.statut == 1 ? Colors.grey : Colors.blue),
              const SizedBox(width: 8),
              Text(
                '${mission.nomClient} ${mission.prenomClient}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Adresse: ${mission.id}'),
              Text('Num Compteur: ${mission.numCompteur}'),
              Text('Volume Dernier Releve: ${mission.volumeDernierReleve}'),
              Text(
                  'Date Dernier Releve: ${DateFormatter.formatFrenchDate(mission.dateReleve!)}'),
            ],
          ),
          trailing: _buildLinkButton(context, mission, authState, buttonText),
        ),
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, MissionModel mission,
      AuthState authState, String buttonText) {
    return InkWell(
      onTap: () {
        _showFormDialog(context, mission, authState,
            isUpdate: mission.statut == 1);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: mission.statut == 1
              ? const Color(0xFF1991B6)
              : const Color(0xFF37087E),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              buttonText,
              style: const TextStyle(
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
      BuildContext context,
      MissionModel mission,
      AuthState authState,
      {bool isUpdate = false}
      ) async {
    TextEditingController volumeController = TextEditingController();
    TextEditingController dateController = TextEditingController();

    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);
    dateController.text = formattedDate;
    String dateValue = formattedDate;

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Nouveaux consommation de ${mission.numCompteur}, ${mission.adresseClient} - $formattedDate',
                style: const TextStyle(fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: volumeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Volumes'),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer un volume';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      MaskedTextField(
                        mask: 'xxxx-xx-xx',
                        controller: dateController,
                        inputDecoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'YYYY-MM-DD',
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_imagePath.isNotEmpty)
                        Image.file(
                          File(_imagePath),
                          width: 100,
                          height: 100,
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // _imagePath = await _getImage();
                          String? imagePath = await _getImage();
                          setState(() {});
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Prendre une photo'),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                            ),
                            child: Text('Fermer'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                String volumeValue = volumeController.text;
                                String dateValue = dateController.text;
                                DateTime parsedDate =
                                DateFormat('dd-MM-yyyy').parse(dateValue);
                                String formattedDate =
                                DateFormat('yyyy-MM-dd').format(parsedDate);
                                try {
                                  if (isUpdate) {
                                    BlocProvider.of<MissionsBloc>(context).add(
                                      UpdateMission(
                                        missionId: mission.numCompteur.toString(),
                                        adresseClient:
                                        mission.adresseClient.toString(),
                                        consoValue: volumeValue,
                                        date: formattedDate,
                                        accessToken: authState is AuthSuccess
                                            ? authState.userInfo.lastToken ?? ''
                                            : '',
                                        imageCompteur: _imagePath,
                                      ),
                                    );
                                  } else {
                                    BlocProvider.of<MissionsBloc>(context).add(
                                      AddMission(
                                        missionId: mission.numCompteur.toString(),
                                        adresseClient:
                                        mission.adresseClient.toString(),
                                        consoValue: volumeValue,
                                        date: formattedDate,
                                        accessToken: authState is AuthSuccess
                                            ? authState.userInfo.lastToken ?? ''
                                            : '',
                                        imageCompteur: _imagePath,
                                      ),
                                    );
                                  }
                                  Navigator.of(context).pop(); // Ferme la boîte de dialogue
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Mission ${isUpdate ? 'modifiée' : 'créée'} avec succès'),
                                    ),
                                  );
                                  BlocProvider.of<MissionsBloc>(context).add(
                                    LoadMissions(
                                      accessToken: authState is AuthSuccess
                                          ? authState.userInfo.lastToken ?? ''
                                          : '',
                                    ),
                                  ); // Recharge la liste des missions
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Erreur lors de la ${isUpdate ? 'modification' : 'création'} de la mission: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(isUpdate ? 'Modifier' : 'Enregistrer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path; // Enregistrer le chemin de l'image sélectionnée
      });
      return pickedFile.path; // Retourner le chemin de l'image sélectionnée
    } else {
      print('Aucune image sélectionnée.');
      return null;
    }
  }

}
