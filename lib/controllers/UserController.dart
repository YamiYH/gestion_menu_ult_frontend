import 'dart:convert';

import 'package:http/http.dart' as http;

class UserController {
  // URL del endpoint del backend
  final String _baseUrl = 'https://tu-backend.com/api/users';

  // Método para obtener la lista de usuarios
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      // Realizar la solicitud GET al backend
      final response = await http.get(Uri.parse(_baseUrl));

      // Verificar si la respuesta es exitosa (status code 200)
      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON
        final List<dynamic> data = json.decode(response.body);

        // Convertir la lista dinámica a una lista de mapas
        return data.cast<Map<String, dynamic>>();
      } else {
        // Lanzar una excepción si la respuesta no es exitosa
        throw Exception('Error al cargar los usuarios: ${response.statusCode}');
      }
    } catch (e) {
      // Manejar errores de red o decodificación
      throw Exception('Error de conexión: $e');
    }
  }
}
