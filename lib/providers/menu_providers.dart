// lib/providers/menu_provider.dart
import 'package:flutter/material.dart';

import '../models/menu_propuesta.dart';

class MenuProvider with ChangeNotifier {
  List<MenuPropuesta> _propuestas = [];

  List<MenuPropuesta> get propuestas => _propuestas;

  void agregarPropuesta(MenuPropuesta propuesta) {
    _propuestas.add(propuesta);
    notifyListeners(); // Notifica a los listeners que el estado ha cambiado
  }
}
