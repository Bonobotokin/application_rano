import 'dart:async';
import 'package:flutter/material.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 6), () {
      // Code à exécuter après 6 secondes
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/img.png',
        width: 100,
        height: 100,
      )
    );
  }
}
