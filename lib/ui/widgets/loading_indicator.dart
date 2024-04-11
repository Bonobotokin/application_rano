import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(), // Utilisez le widget CircularProgressIndicator pour afficher un indicateur de chargement circulaire
    );
  }
}
