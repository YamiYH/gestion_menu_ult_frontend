import 'dart:convert';

import 'package:gestion_menu_ult_frontend/models/Login/UserLoginRequest.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  // Endpoint del backend (reemplaza con la URL real de tu API)
  static const String _loginEndpoint =
      'http://192.168.1.111:8091/api/auth/login';

  // Método para iniciar sesión
  Future<bool> login(UserLoginRequest user) async {
    try {
      // Convertir el objeto UserLogin a JSON
      final Map<String, dynamic> jsonBody = user.toJson();
      print(user.toJson());

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
        print(responseData);

        // Extraer el token JWT
        // Extraer el objeto "data" y luego el token JWT
        final data = responseData['data'] as Map<String, dynamic>?;

        if (data != null && data.containsKey('jwtToken')) {
          final String jwtToken = data['jwtToken'];

          // Almacenar el token JWT en SharedPreferences
          await _saveJwtToken(jwtToken);
          return true;
        } else {
          throw Exception('El servidor no proporcionó un token JWT.');
        }
      } else {
        throw Exception('Error en la autenticación: ${response.statusCode}');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      return false; // Inicio de sesión fallido
    }
  }

  // Método privado para almacenar el token JWT en SharedPreferences
  Future<void> _saveJwtToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwtToken', token);
  }
}
