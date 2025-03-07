import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/logs.dart';
import 'package:gestion_menu_ult_frontend/screens/almacen/inventario.dart';
import 'package:gestion_menu_ult_frontend/screens/common/modulos.dart';

import '../screens/common/Home.dart';
import '../screens/common/Login.dart';
import '../screens/common/Options.dart';
import '../screens/menu/Gestionar_Menu.dart';
import '../screens/ticket/Gestionar_Ticket.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';
  static const String home = '/home';
  static const String options = '/options';
  static const String gestionarTicket = '/gestionar_ticket';
  static const String gestionarMenu = '/gestionar_menu';
  static const String gestionarAlmacen = '/gestionar_almacen';
  static const String modulos = '/modulos';
  static const String logs = '/logs';
  static const String propuesta = '/propuesta';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      login: (context) => Login(),
      home: (context) => Home(),
      options: (context) => Options(),
      gestionarTicket: (context) => GestionarTicket(),
      gestionarMenu: (context) => GestionarMenu(),
      gestionarAlmacen: (context) => GestionarAlmacen(),
      modulos: (context) => ModulosScreen(),
      logs: (context) => LogsScreen(),
    };
  }
}
