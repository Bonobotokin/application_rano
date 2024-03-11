import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(), // Utilisez le widget CircularProgressIndicator pour afficher un indicateur de chargement circulaire
    );
  }
}
