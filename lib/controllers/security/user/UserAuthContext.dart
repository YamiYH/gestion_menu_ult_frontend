import 'package:shared_preferences/shared_preferences.dart';

class UserAuthContext {
  // Método privado para almacenar el token JWT en SharedPreferences
  static Future<void> saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
  }

  // Método privado para almacenar el username en SharedPreferences
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  // Método para obtener el token JWT almacenado
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

// Método para obtener el token JWT almacenado
  static Future<String?> getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

// Método para verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getJwtToken();
    // Por ahora, una simple comprobación de existencia es suficiente.
    // Más adelante, podrías decodificar el token y verificar su fecha de expiración.
    return token != null && token.isNotEmpty;
  }
}
