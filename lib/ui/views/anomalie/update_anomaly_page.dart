import 'dart:io';
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
import 'package:intl/intl.dart';

class UpdateAnomalyPage extends StatefulWidget {
  const UpdateAnomalyPage({super.key});

  @override
  UpdateAnomalyPageState createState() => UpdateAnomalyPageState();
}

class UpdateAnomalyPageState extends State<UpdateAnomalyPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _dateDeclarationController = TextEditingController();

  late DateFormat _dateFormat;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _dateFormat = DateFormat('dd-MM-yyyy');
    _textEditingController = _dateDeclarationController;
  }

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
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Mises à jour Anomalie",
                    style: TextStyle(
                      color: Color(0xdd2e3131),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AnomalieBLoc, AnomalieState>(
                  builder: (context, state) {
                    if (state is UpdateAnomalieLoading) {
                      return FutureBuilder(
                        future: Future.delayed(const Duration(seconds: 2)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
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
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                      const SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _textEditingController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Saisissez la date (DD-MM-YYYY)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir une date';
                            }
                            return null;
                          },
                          onTap: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (selectedDate != null) {
                              _textEditingController.text = _dateFormat.format(selectedDate);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Longitude',
                          initialValue: anomalieItem.longitudeMc ?? '',
                          onChanged: (value) => anomalieItem.longitudeMc = value,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          label: 'Latitude',
                          initialValue: anomalieItem.latitudeMc ?? '',
                          onChanged: (value) => anomalieItem.latitudeMc = value,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: 'Description',
                    initialValue: anomalieItem.descriptionMc ?? '',
                    maxLines: 3,
                    onChanged: (value) => anomalieItem.descriptionMc = value,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [

                      Expanded(
                        child: _buildTextField(
                          label: 'Client declarant',
                          initialValue: anomalieItem.clientDeclare ?? '',
                          onChanged: (value) => anomalieItem.clientDeclare = value,
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Expanded(
                      //   child: _buildTextField(
                      //     label: 'CP Commune',
                      //     initialValue: anomalieItem.cpCommune ?? '',
                      //     onChanged: (value) => anomalieItem.cpCommune = value,
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // _buildTextField(
                  //   label: 'Commune',
                  //   initialValue: anomalieItem.commune ?? '',
                  //   onChanged: (value) => anomalieItem.commune = value,
                  // ),
                  const SizedBox(height: 12),
                  _buildPhotoListView(anomalieItem),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity, // Définit la largeur du Container à 100% de la largeur disponible
                    child: ElevatedButton(
                      onPressed: () {
                        // Appel de la méthode pour effectuer la mise à jour et afficher le SnackBar
                        _updateAnomalyAndShowSnackBar(anomalieItem);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0), // Longueur du bouton
                        backgroundColor: Colors.blueAccent, // Couleur de fond du bouton
                      ),
                      child: const Text(
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
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Color(0xFF012225)),
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
      onChanged: onChanged,
    );
  }

  // Méthode pour créer une liste horizontale de photos d'anomalie
  Widget _buildPhotoListView(AnomalieModel anomalieItem) {
    return SizedBox(
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
              margin: const EdgeInsets.only(right: 8),
              child: photoAnomalie != null && photoAnomalie.isNotEmpty && File(photoAnomalie).existsSync()
                  ? Image.file(
                File(photoAnomalie),
                fit: BoxFit.cover,
              )
                  : const Center(
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
    // Valider le formulaire
    if (_formKey.currentState!.validate()) {
      // Mettre à jour la date avec la valeur du champ caché
      anomalieItem.dateDeclaration = _textEditingController.text;
      BlocProvider.of<AnomalieBLoc>(context).add(UpdateAnomalie(
        anomalieItem: anomalieItem,
      ));
      _showSuccessSnackBar();
    } else {
      // Afficher un message d'erreur et mettre en surbrillance le champ de date
      setState(() {
        // Définir une couleur rouge sur le champ de date
        _textEditingController.selection = const TextSelection.collapsed(offset: 0);
      });
      // Afficher un SnackBar avec un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir une date'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  void _showSuccessSnackBar() {
    const snackBar = SnackBar(
      content: Text('Modification réussie'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

}