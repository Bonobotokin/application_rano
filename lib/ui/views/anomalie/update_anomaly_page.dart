import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:application_rano/blocs/auth/auth_bloc.dart';
import 'package:application_rano/blocs/auth/auth_state.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_state.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/ui/layouts/app_layout.dart';
import '../../shared/DateFormatter.dart';
import '../../shared/MaskedTextField.dart';
import 'package:application_rano/ui/routing/routes.dart';
import 'package:get/get.dart';

class UpdateAnomalyPage extends StatefulWidget {
  const UpdateAnomalyPage({Key? key});

  @override
  _UpdateAnomalyPageState createState() => _UpdateAnomalyPageState();
}

class _UpdateAnomalyPageState extends State<UpdateAnomalyPage> {
  final _formKey = GlobalKey<FormState>(); // Clé globale pour le formulaire
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _typeMcController = TextEditingController();
  TextEditingController _longitudeMcController = TextEditingController();
  TextEditingController _latitudeMcController = TextEditingController();
  TextEditingController _dateDeclarationController = TextEditingController();

  // Ajoutez la déclaration du contrôleur _hiddenDateController
  TextEditingController _hiddenDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppLayout(
          backgroundColor: const Color(0xFFF5F5F5),
          currentIndex: 2,
          authState: authState,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 20), // Espacement entre le haut de la page et le titre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Mises à jour Anomalie",
                    style: TextStyle(
                      color: Color(0xdd2e3131),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Espacement entre le titre et la liste d'anomalies
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
                    } else if (state is AnomalieUpdateLoaded) {
                      return _buildAnomalieListWidget(state.anomalieList, authState);
                    } else if (state is AnomalieError) {
                      return Center(child: Text('Erreur: ${state.message}'));
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnomalieListWidget(List<AnomalieModel> anomalie, AuthState authState) {
    return Expanded(
      child: ListView.builder(
        itemCount: anomalie.length,
        itemBuilder: (context, index) {
          final anomalieItem = anomalie[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10), // Marge autour de chaque carte
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Espacement interne de la carte
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Type',
                          initialValue: anomalieItem.typeMc ?? '',
                          onChanged: (value) => anomalieItem.typeMc = value,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: MaskedTextField(
                          mask: 'xxxx-xx-xx', // Passer le masque ici
                          controller: _hiddenDateController,
                          inputDecoration: InputDecoration(
                            labelText: '${DateFormatter.formatFrenchDate(anomalieItem.dateDeclaration ?? '')}',
                            hintText: '${anomalieItem.dateDeclaration ?? ''}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(color: Colors.black),
                            labelStyle: TextStyle(color: Color(0xFF012225)),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          onChanged: (value) {
                            setState(() { 
                              anomalieItem.dateDeclaration = value;
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Longitude',
                          initialValue: anomalieItem.longitudeMc ?? '',
                          onChanged: (value) => anomalieItem.longitudeMc = value,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          label: 'Latitude',
                          initialValue: anomalieItem.latitudeMc ?? '',
                          onChanged: (value) => anomalieItem.latitudeMc = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: 'Description',
                    initialValue: anomalieItem.descriptionMc ?? '',
                    maxLines: 3,
                    onChanged: (value) => anomalieItem.descriptionMc = value,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Client declarant',
                          initialValue: anomalieItem.clientDeclare ?? '',
                          onChanged: (value) => anomalieItem.clientDeclare = value,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          label: 'CP Commune',
                          initialValue: anomalieItem.cpCommune ?? '',
                          onChanged: (value) => anomalieItem.cpCommune = value,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildTextField(
                    label: 'Commune',
                    initialValue: anomalieItem.commune ?? '',
                    onChanged: (value) => anomalieItem.commune = value,
                  ),
                  SizedBox(height: 12),
                  _buildPhotoListView(anomalieItem),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity, // Définit la largeur du Container à 100% de la largeur disponible
                    child: ElevatedButton(
                      onPressed: () {
                        // Appel de la méthode pour effectuer la mise à jour et afficher le SnackBar
                        _updateAnomalyAndShowSnackBar(anomalieItem);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0), // Longueur du bouton
                        backgroundColor: Colors.blueAccent, // Couleur de fond du bouton
                      ),
                      child: Text(
                        'Modification',
                        textAlign: TextAlign.center, // Centrer le texte
                        style: TextStyle(color: Colors.white), // Couleur du texte
                      ),
                    ),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Méthode pour créer des champs de texte personnalisés avec des styles cohérents
  Widget _buildTextField({
    required String label,
    required String initialValue,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Color(0xFF012225)),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      onChanged: onChanged,
    );
  }

  // Méthode pour créer une liste horizontale de photos d'anomalie
  Widget _buildPhotoListView(AnomalieModel anomalieItem) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          final photoAnomalie = anomalieItem.getPhotoAnomalie(index + 1);
          return GestureDetector(
            onTap: () async {
              final image = await ImagePicker().pickImage(source: ImageSource.camera);
              if (image != null) {
                setState(() {
                  anomalieItem.setPhotoAnomalie(index + 1, image.path);
                });
              }
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.only(right: 8),
              child: photoAnomalie != null && photoAnomalie.isNotEmpty && File(photoAnomalie).existsSync()
                  ? Image.file(
                File(photoAnomalie),
                fit: BoxFit.cover,
              )
                  : Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateAnomalyAndShowSnackBar(AnomalieModel anomalieItem) {
    // Mettre à jour la date avec la valeur du champ caché
    anomalieItem.dateDeclaration = _hiddenDateController.text;
    BlocProvider.of<AnomalieBLoc>(context).add(UpdateAnomalie(
      anomalieItem: anomalieItem,
    ));
    _showSuccessSnackBar();
  }


  void _showSuccessSnackBar() {
    final snackBar = SnackBar(
      content: Text('Modification réussie'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}
