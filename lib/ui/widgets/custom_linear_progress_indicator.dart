import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatefulWidget {
  const CustomLinearProgressIndicator({super.key});

  @override
  CustomLinearProgressIndicatorState createState() => CustomLinearProgressIndicatorState();
}

class CustomLinearProgressIndicatorState extends State<CustomLinearProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Durée de l'animation
    )..repeat(reverse: true); // Répéter l'animation en allant de la fin au début
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return LinearProgressIndicator(
            backgroundColor: Colors.grey[200], // Couleur de fond de la barre de progression
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur de la barre de progression
            value: _animationController.value,
          );
        },
      ),
    );
  }
}
