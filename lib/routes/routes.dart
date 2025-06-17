import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Configuracion/Config.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Configuracion/Payment.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/ModulosAdmin.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Usuario/UserModelo.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Usuario/Users.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Help.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Contabilidad/AprobarMenu.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Contabilidad/Contabilidad.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/LibroDeRecetas/LibroRecetas.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/LibroDeRecetas/RecetaModelo.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Menu/MenuList.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Menu/MenuPropuesta.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ComedorAcceso.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ModulosVenta.dart';

import '../screens/admin/Auditoria/Logs.dart';
import '../screens/admin/Rol/RolModelo.dart';
import '../screens/admin/Rol/Roles.dart';
import '../screens/common/Login.dart';
import '../screens/common/Options.dart';
import '../screens/common/Perfil.dart';
import '../screens/menu/Inventario/Inventario.dart';
import '../screens/menu/ModulosMenu.dart';
import '../screens/menu/Ventas/InformesVentas.dart';
import '../screens/menu/Ventas/MenuVenta.dart';
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
  static const String enzona = '/enzona';
  static const String config = '/config';
  static const String modulosVenta = '/modulos_venta';
  static const String informes = '/informes';
  static const String menuPropuesta = '/menu_propuesta';
  static const String libroRecetas = '/libro_recetas';
  static const String recetaModelo = '/receta_modelo';
  static const String comedorAcceso = '/comedor_acceso';
  static const String userModelo = '/user_modelo';
  static const String rolModelo = '/rol_modelo';
  static const String perfil = '/perfil';
  static const String notifications = '/notifications';
  static const String contabilidad = '/contabilidad';
  static const String aprobarMenu = '/aprobar_menu';
  static const String help = '/help';
  static const String menuList = '/menu_list';
  static const String menuVentas = '/menu_ventas';

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
      enzona: (context) => Payment(
            ticket: null,
          ),
      config: (context) => Config(),
      modulosVenta: (context) => ModulosVenta(),
      informes: (context) => InformesVentas(),
      menuPropuesta: (context) => MenuPropuesta(),
      libroRecetas: (context) => LibroRecetas(),
      recetaModelo: (context) => RecetaModelo(isEditMode: true, receta: null),
      comedorAcceso: (context) => ComedorAcceso(),
      userModelo: (context) => UserModelo(),
      rolModelo: (context) => RolModelo(),
      perfil: (context) => Perfil(),
      contabilidad: (context) => Contabilidad(),
      aprobarMenu: (context) => AprobarMenu(menu: null),
      help: (context) => Help(),
      menuList: (context) => MenuList(),
      menuVentas: (context) => MenuVentas(),
    };
  }
}
