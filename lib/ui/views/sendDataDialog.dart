import 'dart:async'; // Importez Timer depuis dart:async

import 'package:flutter/material.dart';

class SendDataDialog extends StatefulWidget {
  @override
  _SendDataDialogState createState() => _SendDataDialogState();
}

class _SendDataDialogState extends State<SendDataDialog> {
  TextEditingController _controller = TextEditingController();
  double _progressValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Envoyer les données'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Nombre de données à envoyer'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un nombre';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          LinearProgressIndicator(value: _progressValue),
          SizedBox(height: 10),
          Text('Veuillez patienter...'),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            // Valider l'entrée et démarrer l'envoi des données
            int numData = int.tryParse(_controller.text) ?? 0;
            if (numData >= 50) {
              // Commencer l'envoi des données
              // Ici, vous pouvez mettre la logique d'envoi des données

              // Simulons un envoi en incrémentant la barre de progression
              const int totalData = 1000; // Nombre total de données à envoyer
              const Duration sendDuration = Duration(milliseconds: 100); // Durée de chaque envoi
              int sentData = 0; // Nombre de données déjà envoyées
              Timer.periodic(sendDuration, (timer) {
                setState(() {
                  if (sentData < totalData) {
                    _progressValue = sentData / totalData;
                    sentData += 50; // Simuler l'envoi de 50 données à la fois
                  } else {
                    _progressValue = 1.0;
                    timer.cancel(); // Arrêter la simulation une fois que toutes les données sont envoyées
                  }
                });
              });

              // Fermer la boîte de dialogue après un certain délai
              Future.delayed(Duration(seconds: 2), () {
                Navigator.of(context).pop();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Le nombre minimum de données à envoyer est de 50'),
                ),
              );
            }
          },
          child: Text('Valider'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
