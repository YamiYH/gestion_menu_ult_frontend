// lib/providers/ProfileProvider.dart

import 'package:flutter/material.dart'; // O un nuevo ProfileController
import 'package:gestion_menu_ult_frontend/models/UserProfile.dart';

import '../controllers/security/user/UserController.dart';

class ProfileProvider extends ChangeNotifier {
  final UserController _userController =
      UserController(); // O el controlador que uses

  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  // Getters para que la UI pueda acceder a los datos y estados
  UserProfile? get userProfile => _userProfile;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// Método para buscar los datos del perfil desde el backend.
  Future<void> fetchUserProfile(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userController.getByUsername('me/$username');
      _userProfile = UserProfile.fromUser(userData);
    } catch (e) {
      _error = "No se pudo cargar el perfil: $e";
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a los widgets que la carga ha terminado (con o sin éxito)
    }
  }

  /// Limpia los datos del perfil al cerrar sesión.
  void clearProfile() {
    _userProfile = null;
    _error = null;
    notifyListeners();
  }
}
