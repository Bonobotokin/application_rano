import 'package:application_rano/ui/views/anomalie/anomaliePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Supprimez cette ligne pour résoudre le conflit d'importation
// import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/date_symbol_data_local.dart'; // Utilisez uniquement cette ligne

import 'package:intl/intl.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/data/models/anomalie_model.dart';

// Votre code reste le même...


class NewAnomalyPage extends StatefulWidget {
  const NewAnomalyPage({Key? key}) : super(key: key);

  @override
  _NewAnomalyPageState createState() => _NewAnomalyPageState();
}

class _NewAnomalyPageState extends State<NewAnomalyPage> {
  // Define your controllers for input fields
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _cpCommuneController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();

  // Define the default value for anomaly status
  int _status = 0;
  @override
  void initState() {
    super.initState();
    // Initialize date formatting
    initializeDateFormatting('fr_FR');

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Anomalie'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTextField('Type Anomalie', _typeController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('Date', _dateController),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTextField('Longitude', _longitudeController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('Latitude', _latitudeController),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField('Description', _descriptionController),
              SizedBox(height: 20),
              _buildTextField('Client', _clientController),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTextField('Code Postal Commune', _cpCommuneController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField('Commune', _communeController),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildDropdownButtonFormField(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Récupérer les valeurs saisies dans les champs du formulaire
                  String type = _typeController.text;
                  String date = _dateController.text;
                  String longitude = _longitudeController.text;
                  String latitude = _latitudeController.text;
                  String description = _descriptionController.text;
                  String client = _clientController.text;
                  String cpCommune = _cpCommuneController.text;
                  String commune = _communeController.text;
                  int statut = _status;

                  // Créer un objet AnomalieModel avec les valeurs récupérées
                  AnomalieModel anomalie = AnomalieModel(
                    idMc: 0, // Vous devrez peut-être définir cette valeur en fonction de votre logique
                    typeMc: type,
                    dateDeclaration: date,
                    longitudeMc: longitude,
                    latitudeMc: latitude,
                    descriptionMc: description,
                    clientDeclare: client,
                    cpCommune: cpCommune,
                    commune: commune,
                    status: statut,
                  );

                  // Envoyer l'objet AnomalieModel à votre fonction on<AddAnomalie>
                  context.read<AnomalieBLoc>().add(AddAnomalie(
                    typeMc: type,
                    dateDeclaration: date,
                    longitudeMc: longitude,
                    latitudeMc: latitude,
                    descriptionMc: description,
                    clientDeclare: client,
                    cpCommune: cpCommune,
                    commune: commune,
                    status: statut.toString(), // Convertir statut en String
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Facture enregistrée avec succès')),
                  );
                  // Rechargez la page actuelle après la soumission du formulaire
                  // Vous pouvez soit rediriger vers la page précédente, soit reconstruire la page actuelle
                  // Par exemple:

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (BuildContext context) => AnomaliePage(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  // Autres styles du bouton
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Marge interne du bouton
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bord arrondi du bouton
                  ),
                  backgroundColor: Colors.blue, // Couleur de fond du bouton
                ),
                child: Text(
                  'Enregistrer',
                  style: TextStyle(
                    fontSize: 16.0, // Taille de la police du texte du bouton
                    color: Colors.white, // Couleur du texte du bouton
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    if (label == 'Date') {
      // Pour le champ de date, définissez la date actuelle comme valeur par défaut
      String currentDate = DateFormat.yMd('fr_FR').format(DateTime.now());
      controller.text = currentDate;
    }

    return TextFormField(
      controller: controller,
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
        floatingLabelBehavior: FloatingLabelBehavior.never, // Disable the floating label
      ),
    );
  }


  Widget _buildDropdownButtonFormField() {
    return DropdownButtonFormField<int>(
      value: _status,
      onChanged: (value) {
        setState(() {
          _status = value!;
        });
      },
      items: [
        DropdownMenuItem<int>(
          value: 0,
          child: Text('Non Traité'),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text('En Cours'),
        ),
        DropdownMenuItem<int>(
          value: 2,
          child: Text('Réalisé'),
        ),
      ],
      decoration: InputDecoration(
        labelText: 'Statut',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Color(0xFF012225)),
      ),
    );
  }

  @override
  void dispose() {
    // Ensure to dispose the controllers to avoid memory leaks
    _typeController.dispose();
    _dateController.dispose();
    _longitudeController.dispose();
    _latitudeController.dispose();
    _descriptionController.dispose();
    _clientController.dispose();
    _cpCommuneController.dispose();
    _communeController.dispose();
    super.dispose();
  }
}
