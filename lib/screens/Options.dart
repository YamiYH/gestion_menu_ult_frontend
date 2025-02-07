import 'package:flutter/material.dart';

import '../widgets/card_widgets.dart'; // Importar los widgets de las tarjetas

class Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '¿Qué deseas hacer?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: screenWidth > 600 ? 25 : 20,
          ),
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isMobile
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 20),
                    ReservarTicketCard(screenWidth: screenWidth),
                    GestionarMenuCard(screenWidth: screenWidth),
                  ],
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: ReservarTicketCard(screenWidth: screenWidth)),
                    SizedBox(width: 100),
                    Flexible(
                        child: GestionarMenuCard(screenWidth: screenWidth)),
                  ],
                ),
        ),
      ),
    );
  }
}
