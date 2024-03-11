import 'package:flutter/material.dart';

class CustomLinearProgressIndicator extends StatefulWidget {
  @override
  _CustomLinearProgressIndicatorState createState() => _CustomLinearProgressIndicatorState();
}

class _CustomLinearProgressIndicatorState extends State<CustomLinearProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Durée de l'animation
    )..repeat(reverse: true); // Répéter l'animation en allant de la fin au début
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return LinearProgressIndicator(
            backgroundColor: Colors.grey[200], // Couleur de fond de la barre de progression
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Couleur de la barre de progression
            value: _animationController.value,
          );
        },
      ),
    );
  }
}
