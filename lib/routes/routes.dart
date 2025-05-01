import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Config.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/ModulosAdmin.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Payment.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/UserModelo.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Users.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/LibroRecetas.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/MenuPropuesta.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/RecetaModelo.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ComedorAcceso.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ModulosVenta.dart';

import '../screens/admin/Logs.dart';
import '../screens/admin/RolModelo.dart';
import '../screens/admin/Roles.dart';
import '../screens/common/Login.dart';
import '../screens/common/Notifications.dart';
import '../screens/common/Options.dart';
import '../screens/common/Perfil.dart';
import '../screens/menu/Inventario.dart';
import '../screens/menu/MenuConfig.dart';
import '../screens/menu/ModulosMenu.dart';
import '../screens/menu/Ventas/InformesVentas.dart';
import '../screens/menu/Ventas/Ventas.dart';
import '../screens/ticket/GestionarTicket.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';

  static const String options = '/options';
  static const String gestionarTicket = '/gestionar_ticket';
  static const String inventario = '/gestionar_almacen';
  static const String modulosMenu = '/modulos_menu';
  static const String logs = '/logs';
  static const String modulosAdmin = '/modulos_admin';
  static const String users = '/users';
  static const String ventas = '/ventas';
  static const String roles = '/roles';
  static const String pagos = '/pagos';
  static const String config = '/config';
  static const String modulosVenta = '/modulos_venta';
  static const String informes = '/informes';
  static const String menuConfig = '/menu_config';
  static const String menuPropuesta = '/menu_propuesta';
  static const String libroRecetas = '/libro_recetas';
  static const String recetaModelo = '/receta_modelo';
  static const String comedorAcceso = '/comedor_acceso';
  static const String userModelo = '/user_modelo';
  static const String rolModelo = '/rol_modelo';
  static const String perfil = '/perfil';
  static const String notifications = '/notifications';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return <String, WidgetBuilder>{
      login: (context) => Login(),
      options: (context) => Options(),
      gestionarTicket: (context) => GestionarTicket(),
      inventario: (context) => Inventario(),
      modulosMenu: (context) => ModulosMenu(),
      logs: (context) => Logs(),
      modulosAdmin: (context) => ModulosAdmin(),
      users: (context) => Users(),
      ventas: (context) => Ventas(),
      roles: (context) => Roles(),
      pagos: (context) => Payment(),
      config: (context) => Config(),
      modulosVenta: (context) => ModulosVenta(),
      informes: (context) => InformesVentas(),
      menuConfig: (context) => MenuConfig(),
      menuPropuesta: (context) => MenuPropuesta(),
      libroRecetas: (context) => LibroRecetas(),
      recetaModelo: (context) => RecetaModelo(isEditMode: true, receta: null),
      comedorAcceso: (context) => ComedorAcceso(),
      userModelo: (context) => UserModelo(),
      rolModelo: (context) => RolModelo(),
      perfil: (context) => Perfil(),
      notifications: (context) => Notifications(),
    };
  }
}
