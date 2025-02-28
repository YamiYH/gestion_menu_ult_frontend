import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/almacen/inventario.dart';

import '../screens/common/Home.dart';
import '../screens/common/Login.dart';
import '../screens/common/Options.dart';
import '../screens/menu/Gestionar_Menu.dart';
import '../screens/ticket/Reservar_Ticket.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';
  static const String home = '/home';
  static const String options = '/options';
  static const String reservarTicket = '/reservar_ticket';
  static const String gestionarMenu = '/gestionar_menu';
  static const String gestionarAlmacen = '/gestionar_almacen';

  //static const String confirmarReserva = '/confirmar_reserva';
  //static const String menuPropuesta = '/menu_propuesta';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => Login(),
      home: (context) => Home(),
      options: (context) => Options(),
      reservarTicket: (context) => ReservarTicket(),
      gestionarMenu: (context) => GestionarMenu(),
      gestionarAlmacen: (context) => GestionarAlmacen(),
      //confirmarReserva: (context) => ConfirmarReserva()
    };
  }
}
