import 'package:flutter/material.dart';
class SyncDialog extends StatelessWidget {
  final int duration; // Durée de la synchronisation en secondes

  const SyncDialog({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Synchronisation en cours...'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text('Veuillez patienter...'),
          const SizedBox(height: 8),
          Text('Durée estimée: $duration secondes'), // Afficher la durée estimée
        ],
      ),
    );
  }
}
