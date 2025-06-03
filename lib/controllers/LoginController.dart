import 'dart:convert';

import 'package:gestion_menu_ult_frontend/controllers/user/UserAuthContext.dart';
import 'package:gestion_menu_ult_frontend/models/Login/UserLoginRequest.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  // Endpoint del backend (reemplaza con la URL real de tu API)
  static const String _loginEndpoint =
      'http://192.168.1.111:8887/api/v1/auth/login';

  // Método para iniciar sesión
  Future<bool> login(UserLoginRequest user) async {
    try {
      // Convertir el objeto UserLogin a JSON
      final Map<String, dynamic> jsonBody = user.toJson();
      // Realizar la solicitud POST al backend
      final response = await http.post(
        Uri.parse(_loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(jsonBody),
      );

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('jwtToken')) {
          final String jwtToken = responseData['jwtToken'];

          // Almacenar el token JWT en SharedPreferences
          await UserAuthContext.saveJwtToken(jwtToken);
          return true;
        } else {
          throw Exception('El servidor no proporcionó un token JWT.');
        }
      } else {
        throw Exception('Error en la autenticación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      return false;
    } // Inicio de sesión fallido
  }

// Método para cerrar sesión (eliminar el token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
  }
}
