import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/ui/views/anomalie/anomaliePage.dart';

class UpdateAnomalyPage extends StatefulWidget {
  const UpdateAnomalyPage({Key? key}) : super(key: key);

  @override
  _UpdateAnomalyPageState createState() => _UpdateAnomalyPageState();
}

class _UpdateAnomalyPageState extends State<UpdateAnomalyPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _clientController = TextEditingController();
  final TextEditingController _cpCommuneController = TextEditingController();
  final TextEditingController _communeController = TextEditingController();

  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
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
        _buildTextField('Date', _dateController),
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
        _buildTextField('Client', _clientController),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildTextField('Code Postal Commune', _cpCommuneController)),
            SizedBox(width: 10),
            Expanded(child: _buildTextField('Commune', _communeController)),
          ],
        ),
      ],
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
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }

  void _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _changePicture(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images[index] = File(pickedFile.path);
      });
    }
  }

  void _showOptionsDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.remove_circle),
                title: Text('Supprimer'),
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.fullscreen),
                title: Text('Agrandir'),
                onTap: () {
                  _showImageDialog(index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLongPressOptions(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.remove_circle),
                title: Text('Supprimer'),
                onTap: () {
                  setState(() {
                    _images.removeAt(index);
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.fullscreen),
                title: Text('Agrandir'),
                onTap: () {
                  _showImageDialog(index);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                _images[index],
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveAnomaly() {
    String type = _typeController.text;
    String date = _dateController.text;
    String longitude = _longitudeController.text;
    String latitude = _latitudeController.text;
    String description = _descriptionController.text;
    String client = _clientController.text;
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
      const SnackBar(content: Text("L'enregistrement est terminer")),
    );

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (BuildContext context) => AnomaliePage(),
    ));
  }

  @override
  void dispose() {
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
