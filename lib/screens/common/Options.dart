import 'package:flutter/material.dart';

import '../../widgets/card_widgets.dart';
import '../../widgets/custom_appbar.dart'; // Importar los widgets de las tarjetas

class Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    // Datos simulados para el usuario y las notificaciones
    final String userName = 'Yamilet Yero';
    final List<String> notifications = [
      'Nueva actualización disponible',
      'Tienes un nuevo mensaje',
      'Recordatorio: Reunión a las 3 PM',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        notifications: notifications,
        text: '¿Qué deseas hacer?',
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
