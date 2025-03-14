import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/missions/missions_bloc.dart';
import 'package:application_rano/blocs/missions/missions_event.dart';
import 'package:application_rano/blocs/missions/missions_state.dart';
import 'package:application_rano/data/models/missions_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/clients/client_bloc.dart';
import 'package:application_rano/blocs/clients/client_event.dart';
import 'package:intl/intl.dart';
import '../shared/DateFormatter.dart';
import '../shared/MaskedTextField.dart';
import '../routing/routes.dart';
import 'package:get/get.dart';

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
                    return _buildLoadingState(context);
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
  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  bool isCurrentYearAndMonth(String dateString) {
    DateTime date = parseDate(dateString);
    DateTime now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur bleue pour la bordure
        backgroundColor: Colors.white, // Fond blanc
      ),
    );
  }
  Widget _buildMissionListWidget(
      List<MissionModel> missions, AuthState authState) {

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
      BuildContext context,
      MissionModel mission,
      AuthState authState
      ) {
    Color cardColor = mission.statut == 1 || mission.statut == 2 ? Colors.white : const Color(0xFFBBDEFB);

    Color btnColor = mission.statut == 1 ? const Color(0xFFEEE9E9) : const Color(0xFFBBDEFB);
    String buttonText = mission.statut == 1 ? 'Modifier' : 'Ajouter';

    bool canModify = !(mission.statut == 2 && isCurrentYearAndMonth(mission.dateReleve!));

    Widget linkButton = canModify
        ? _buildLinkButton(context, mission, authState, buttonText)
        : SizedBox.shrink();

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
              Expanded(
                child: Text(
                  '${mission.nomClient} ${mission.prenomClient}',
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
              Text('Adresse: ${mission.adresseClient}'),
              Text('Num Compteur: ${mission.numCompteur}'),
              Text('Volume Dernier Releve: ${mission.volumeDernierReleve}'),
              Text(
                  'Date Dernier Releve: ${DateFormatter.formatFrenchDate(mission.dateReleve!)}'),
            ],
          ),
          trailing: linkButton,

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

    late String _imagePath = ''; // Déclaration du chemin de l'image à l'intérieur de la méthode
    bool _isLoading = false; // État de chargement

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Nouvelle consommation de ${mission.numCompteur}, ${mission.adresseClient} - $formattedDate',
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
                      TextFormField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                      if (_isLoading)
                        CircularProgressIndicator(), // Indicateur de chargement
                      if (_imagePath.isNotEmpty && !_isLoading)
                        Image.file(
                          File(_imagePath),
                          width: 100,
                          height: 100,
                        ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true; // Affiche l'indicateur de chargement
                          });
                          String? imagePath = await _getImage();
                          setState(() {
                            _imagePath = imagePath ?? ''; // Mettre à jour le chemin de l'image
                            _isLoading = false; // Masque l'indicateur de chargement
                          });
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
                                // Vérification si l'image est vide
                                if (_imagePath.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Veuillez prendre une photo'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } else {
                                  String volumeValue = volumeController.text;
                                  String dateValue = dateController.text;
                                  DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(dateValue);
                                  String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
                                  try {
                                    if (isUpdate) {
                                      BlocProvider.of<MissionsBloc>(context).add(
                                        UpdateMission(
                                          missionId: mission.numCompteur.toString(),
                                          adresseClient: mission.adresseClient.toString(),
                                          consoValue: volumeValue,
                                          date: formattedDate,
                                          accessToken: authState is AuthSuccess ? authState.userInfo.lastToken ?? '' : '',
                                          imageCompteur: _imagePath,
                                        ),
                                      );
                                    } else {
                                      BlocProvider.of<MissionsBloc>(context).add(
                                        AddMission(
                                          missionId: mission.numCompteur.toString(),
                                          adresseClient: mission.adresseClient.toString(),
                                          consoValue: volumeValue,
                                          date: formattedDate,
                                          accessToken: authState is AuthSuccess ? authState.userInfo.lastToken ?? '' : '',
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
                                        accessToken: authState is AuthSuccess ? authState.userInfo.lastToken ?? '' : '',
                                      ),
                                    ); // Recharge la liste des missions
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Erreur lors de la ${isUpdate ? 'modification' : 'création'} de la mission: $e'),
                                      ),
                                    );
                                  }
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
      String imagePath = pickedFile.path;
      print('Chemin de l\'image avant compression : $imagePath');

      File imageFile = File(imagePath);
      int originalSize = await imageFile.length();
      print('Taille de l\'image avant compression : ${originalSize ~/ 1024} KB');

      String? compressedImagePath = await _resizeAndCompressImage(imagePath);

      if (compressedImagePath != null) {
        File compressedImage = File(compressedImagePath);
        int compressedSize = await compressedImage.length();
        print('Chemin de l\'image après compression : $compressedImagePath');
        print('Taille de l\'image après compression : ${compressedSize ~/ 1024} KB');
      } else {
        print('Erreur lors de la compression de l\'image.');
      }

      return compressedImagePath;
    } else {
      print('Aucune image sélectionnée.');
      return null;
    }
  }

  Future<String?> _resizeAndCompressImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());

      if (originalImage != null) {
        int newWidth = (originalImage.width * 0.8).toInt();
        int newHeight = (originalImage.height * 0.8).toInt();

        img.Image resizedImage = img.copyResize(originalImage, width: newWidth, height: newHeight);

        List<int> compressedImageBytes = img.encodeJpg(resizedImage, quality: 80);

        File compressedImage = File('${imageFile.parent.path}/compressed_image.jpg');
        await compressedImage.writeAsBytes(compressedImageBytes);

        return compressedImage.path;
      } else {
        print('Erreur lors du décodage de l\'image.');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la manipulation de l\'image : $e');
      return null;
    }
  }

}
