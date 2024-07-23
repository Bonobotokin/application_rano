import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:application_rano/blocs/anomalies/anomalie_bloc.dart';
import 'package:application_rano/blocs/anomalies/anomalie_event.dart';
import 'package:application_rano/data/models/anomalie_model.dart';
import 'package:application_rano/data/models/client_model.dart';
import 'package:application_rano/data/repositories/anomalie/anomalie_repository.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  List<ClientModel> _clients = [];
  ClientModel? _selectedClient;
  bool _compressingImage = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
    _dateFormat = DateFormat('dd-MM-yyyy');
    _fetchClients();
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
                return _compressingImage
                    ? Container(
                  width: 100,
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: _takePicture,
                );
              }
              return GestureDetector(
                onTap: () => _showOptionsDialog(index),
                onLongPress: () => _showLongPressOptions(index),
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Stack(
                    children: [
                      Image.file(
                        _images[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      if (_compressingImage && index == _images.length - 1)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.5),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
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
        SizedBox(height: 10),
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
        _buildClientDropdown(),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: label,
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
          controller.text = _dateFormat.format(selectedDate);
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
      controller: controller,
      maxLines: 3,
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
          _clientController.text = '${newValue?.id}';
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
      onPressed: _compressingImage ? null : _saveAnomaly,
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
    String client = _selectedClient?.nom ?? '';
    String cpCommune = _cpCommuneController.text;
    String commune = _communeController.text;

    if (type.isEmpty || date.isEmpty || description.isEmpty  ) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    AnomalieModel newAnomaly = AnomalieModel(
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

    Navigator.of(context).pop();
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

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      print('Chemin de l\'image avant compression : $imagePath');

      File imageFile = File(imagePath);
      int originalSize = await imageFile.length();
      print('Taille de l\'image avant compression : ${originalSize ~/ 1024} KB');

      setState(() {
        _compressingImage = true;
      });

      String? compressedImagePath = await _resizeAndCompressImage(imagePath);

      setState(() {
        _compressingImage = false;
      });

      if (compressedImagePath != null) {
        File compressedImage = File(compressedImagePath);
        int compressedSize = await compressedImage.length();
        print('Chemin de l\'image après compression : $compressedImagePath');
        print('Taille de l\'image après compression : ${compressedSize ~/ 1024} KB');

        setState(() {
          _images.add(compressedImage);
        });
      } else {
        print('Erreur lors de la compression de l\'image.');
      }
    } else {
      print('Aucune image sélectionnée.');
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

  void _replaceImage(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      String imagePath = pickedFile.path;
      print('Chemin de l\'image avant compression : $imagePath');

      File imageFile = File(imagePath);
      int originalSize = await imageFile.length();
      print('Taille de l\'image avant compression : ${originalSize ~/ 1024} KB');

      setState(() {
        _compressingImage = true;
      });

      String? compressedImagePath = await _resizeAndCompressImage(imagePath);

      setState(() {
        _compressingImage = false;
      });

      if (compressedImagePath != null) {
        File compressedImage = File(compressedImagePath);
        int compressedSize = await compressedImage.length();
        print('Chemin de l\'image après compression : $compressedImagePath');
        print('Taille de l\'image après compression : ${compressedSize ~/ 1024} KB');

        setState(() {
          _images[index] = compressedImage;
        });
      } else {
        print('Erreur lors de la compression de l\'image.');
      }
    } else {
      print('Aucune image sélectionnée.');
    }
  }
}
