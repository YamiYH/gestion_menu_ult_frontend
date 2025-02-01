import 'package:flutter/material.dart';
import '../screens/Home.dart';
import '../screens/Login.dart';

class AppRoutes {
  // Definimos los nombres de las rutas
  static const String login = '/';
  static const String home = '/home';

  // Mapeamos las rutas a las pantallas correspondientes
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => Login(),
      home: (context) => Home(),
    };
  }
}