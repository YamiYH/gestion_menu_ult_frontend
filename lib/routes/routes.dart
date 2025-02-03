import 'package:flutter/material.dart';

import '../screens/Gestionar_Menu.dart';
import '../screens/Home.dart';
import '../screens/Login.dart';
import '../screens/Options.dart';
import '../screens/Reservar_Ticket.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';
  static const String home = '/home';
  static const String options = '/options';
  static const String reservarTicket = '/reservar_ticket';
  static const String gestionarMenu = '/gestionar_menu';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => Login(),
      home: (context) => Home(),
      options: (context) => Options(),
      reservarTicket: (context) => ReservarTicket(),
      gestionarMenu: (context) => GestionarMenu(),
    };
  }
}
