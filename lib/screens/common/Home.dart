import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900], // Rojo vino para el AppBar
      ),
      body: Center(
        child: Text(
          '¡Bienvenido al sistema de comedor universitario!',
          style: TextStyle(fontSize: 20, color: Colors.red[900]),
        ),
      ),
    );
  }
}