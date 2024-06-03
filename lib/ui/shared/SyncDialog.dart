import 'package:flutter/material.dart';
class SyncDialog extends StatelessWidget {
  final int duration; // Durée de la synchronisation en secondes

  const SyncDialog({Key? key, required this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Synchronisation en cours...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Veuillez patienter...'),
          SizedBox(height: 8),
          Text('Durée estimée: $duration secondes'), // Afficher la durée estimée
        ],
      ),
    );
  }
}
