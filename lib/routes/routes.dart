import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Config.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Payment.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Users.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/ModulosVenta.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/PropuestaMenu.dart';

import '../screens/admin/Admin.dart';
import '../screens/admin/Logs.dart';
import '../screens/admin/Roles.dart';
import '../screens/common/Login.dart';
import '../screens/common/Options.dart';
import '../screens/menu/InformesVentas.dart';
import '../screens/menu/Inventario.dart';
import '../screens/menu/MenuConfig.dart';
import '../screens/menu/ModulosMenu.dart';
import '../screens/menu/Ventas.dart';
import '../screens/ticket/GestionarTicket.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';

  static const String options = '/options';
  static const String gestionarTicket = '/gestionar_ticket';

  static const String gestionarAlmacen = '/gestionar_almacen';
  static const String modulosMenu = '/modulos_menu';
  static const String logs = '/logs';
  static const String admin = '/admin';
  static const String users = '/users';
  static const String ventas = '/ventas';
  static const String roles = '/roles';
  static const String pagos = '/pagos';
  static const String config = '/config';
  static const String modulosVenta = '/modulos_venta';
  static const String informes = '/informes';
  static const String menuConfig = '/menu_config';
  static const String menuPropuesta = '/menu_propuesta';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      login: (context) => Login(),
      options: (context) => Options(),
      gestionarTicket: (context) => GestionarTicket(),
      gestionarAlmacen: (context) => GestionarAlmacen(),
      modulosMenu: (context) => ModulosMenu(),
      logs: (context) => Logs(),
      admin: (context) => AdminScreen(),
      users: (context) => Users(),
      ventas: (context) => Ventas(),
      roles: (context) => Roles(),
      pagos: (context) => Payment(),
      config: (context) => Config(),
      modulosVenta: (context) => ModulosVenta(),
      informes: (context) => InformesVentas(),
      menuConfig: (context) => MenuConfig(),
      menuPropuesta: (context) => MenuPropuesta(),
    };
  }
}
