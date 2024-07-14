import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/client_model.dart'; // Importez le modèle de client
import 'package:application_rano/ui/views/anomalie/anomaliePage.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';
import '../../shared/DateFormatter.dart';
import '../../shared/MaskedTextField.dart';

class NewAnomalyPage extends StatefulWidget {
  const NewAnomalyPage({Key? key}) : super(key: key);

  @override
  _NewAnomalyPageState createState() => _NewAnomalyPageState();
}

class _NewAnomalyPageState extends State<NewAnomalyPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _cpCommuneController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();

  DateTime currentDate = DateTime.now();
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  late DateFormat _dateFormat;
  late TextEditingController _textEditingController;

  List<ClientModel> _clients = []; // Liste des clients
  ClientModel? _selectedClient; // Client sélectionné

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _dateFormat = DateFormat('dd-MM-yyyy');
    _textEditingController = _dateController;
    _fetchClients(); // Récupérez les clients lors de l'initialisation
  }

  Future<void> _fetchClients() async {
  try {
    final List<ClientModel> clients = await AnomalieRepository(baseUrl: "http://89.116.38.149:8000/api").getAllClients();
    if (mounted) {
      setState(() {
        _clients = clients;
          print("Clients fetched: $_clients");
      });
    }
  } catch (error) {
      print('Error fetching clients: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Anomalie'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            _buildFormFields(),
            SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length < 5 ? _images.length + 1 : _images.length,
            itemBuilder: (BuildContext context, int index) {
              if (index == _images.length && _images.length < 5) {
                return IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _takePicture,
                );
              }
              return GestureDetector(
                onTap: () => _showOptionsDialog(index),
                onLongPress: () => _showLongPressOptions(index),
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Image.file(
                    _images[index],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField('Type Anomalie', _typeController),
        SizedBox(height: 10),
        _buildDateField('Date', _dateController),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField('Longitude', _longitudeController)),
            SizedBox(width: 10),
            Expanded(child: _buildTextField('Latitude', _latitudeController)),
          ],
        ),
        SizedBox(height: 10),
        _buildDescriptionField('Description', _descriptionController),
        SizedBox(height: 10),
        _buildClientDropdown(), // Remplacez le champ de saisie de texte par la liste déroulante
        SizedBox(height: 10),
        // Row(
        //   children: [
        //     // Expanded(child: _buildTextField('Code Postal Commune', _cpCommuneController)),
        //     // _buildCodePostaleDropdown(),
        //     SizedBox(width: 10),
        //     Expanded(child: _buildTextField('Commune', _communeController)),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController _textEditingController) {
    return TextFormField(
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
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
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
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }

  Widget _buildDescriptionField(String label, TextEditingController controller) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3, // Définit le nombre maximum de lignes
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Entrez la description de l\'anomalie',
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
    );
  }

  Widget _buildClientDropdown() {
    print("Building client dropdown with clients: $_clients"); // Ajout de la ligne pour vérifier la liste

    return DropdownButtonFormField<ClientModel>(
      value: _selectedClient,
      items: _clients.map((ClientModel client) {
        return DropdownMenuItem<ClientModel>(
          value: client,
          child: Text('${client.nom}'),
        );
      }).toList(),
      onChanged: (ClientModel? newValue) {
        setState(() {
          _selectedClient = newValue;
          _clientController.text = '${newValue?.nom}';
        });
      },
      decoration: InputDecoration(
        labelText: 'Client',
        hintText: 'Sélectionnez un client',
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
    );
  }


  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveAnomaly,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.blue,
      ),
      child: Text(
        'Enregistrer',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.white,
        ),
      ),
    );
  }

  void _saveAnomaly() {
    String type = _typeController.text;
    String date = _dateController.text;
    String longitude = _longitudeController.text;
    String latitude = _latitudeController.text;
    String description = _descriptionController.text;
    String client = _selectedClient?.nom ?? ''; // Utiliser le nom du client sélectionné
    String cpCommune = _cpCommuneController.text;
    String commune = _communeController.text;

    AnomalieModel anomalie = AnomalieModel(
      idMc: 0,
      typeMc: type,
      dateDeclaration: date,
      longitudeMc: longitude,
      latitudeMc: latitude,
      descriptionMc: description,
      clientDeclare: client,
      cpCommune: cpCommune,
      commune: commune,
    );

    context.read<AnomalieBLoc>().add(AddAnomalie(
      typeMc: type,
      dateDeclaration: date,
      longitudeMc: longitude,
      latitudeMc: latitude,
      descriptionMc: description,
      clientDeclare: client,
      cpCommune: cpCommune,
      commune: commune,
      status: '2',
      imagePaths: _images.map((image) => image.path).toList(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("L'enregistrement est terminé")),
    );

    // Navigator.of(context).pushReplacement(MaterialPageRoute(
    //   builder: (BuildContext context) => AnomaliePage(),
    // ));
  }

  Future<void> _takePicture() async {
    if (_images.length < 5) {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Vous ne pouvez pas ajouter plus de 5 images."),
        ),
      );
    }
  }

  void _showOptionsDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Text('Voulez-vous supprimer ou remplacer cette image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _replaceImage(index);
              },
              child: Text('Remplacer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _images.removeAt(index);
                });
              },
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showLongPressOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Supprimer'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _images.removeAt(index);
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Remplacer'),
              onTap: () {
                Navigator.pop(context);
                _replaceImage(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _replaceImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }
}
