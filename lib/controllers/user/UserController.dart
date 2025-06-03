import 'dart:convert'; // Necesario para jsonDecode

import 'package:gestion_menu_ult_frontend/controllers/user/UserAuthContext.dart';
import 'package:http/http.dart' as http;

class UserController {
  // URL del endpoint del backend
  final String _baseUrl = 'http://192.168.1.111:8887';
  final String _endPoint = '/api/v1/users';

  // --- Funciones auxiliares para la transformación de datos ---

  // Obtiene la descripción del primer rol, o un valor por defecto.
  String _getRoleDescription(List<dynamic>? rolesJson) {
    if (rolesJson != null && rolesJson.isNotEmpty) {
      final firstRole = rolesJson.first as Map<String, dynamic>?;
      if (firstRole != null &&
          firstRole.containsKey('description') &&
          firstRole['description'] != null) {
        return firstRole['description'].toString();
      }
      return 'Descripción no disponible'; // Si el primer rol no tiene descripción
    }
    return 'Sin rol asignado'; // Si no hay roles
  }

  // Formatea el tipo de usuario (ej: "EMPLOYEE" -> "Employee")
  String _formatUserType(String? typeJson) {
    if (typeJson == null || typeJson.isEmpty) {
      return 'Desconocido'; // O un string vacío: ''
    }
    // Convierte "EMPLOYEE" a "Employee"
    return '${typeJson[0].toUpperCase()}${typeJson.substring(1).toLowerCase()}';
  }

  // Método para obtener la lista de usuarios
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    String? token = await UserAuthContext.getJwtToken();

    if (token == null) {
      print(
          'UserController: Error - Token JWT es nulo. No se puede realizar la solicitud autenticada.');
      return []; // Devuelve una lista vacía si no hay token
    }

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json', // Buena práctica incluirla
    };
    var uri = Uri.parse(
        '$_baseUrl$_endPoint?pageNo=0&pageSize=10&sortType=asc&sortBy=username');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);

        // El backend devuelve los usuarios dentro de la clave "content"
        if (decodedResponse.containsKey('content') &&
            decodedResponse['content'] is List) {
          final List<dynamic> usersContent =
              decodedResponse['content'] as List<dynamic>;
          final List<Map<String, dynamic>> userList = [];

          for (var userJson in usersContent) {
            if (userJson is Map<String, dynamic>) {
              final Map<String, dynamic> userMap = {
                'username': userJson['username'] ?? 'N/A',
                'name': userJson['name'] ?? 'N/A',
                'lastname': userJson['lastName'] ?? 'N/A',
                'email': userJson['email'] ?? 'N/A',
                'role':
                    _getRoleDescription(userJson['roles'] as List<dynamic>?),
                'status': (userJson['active'] == true) ? 'Activo' : 'Inactivo',
                'type': _formatUserType(userJson['type'] as String?),
              };
              userList.add(userMap);
            }
          }
          print(userList);
          return userList;
        } else {
          print(
              'UserController: Error - La respuesta del backend no contiene la lista "content" esperada.');
          return [];
        }
      } else {
        print(
            'UserController: Error en la respuesta del servidor - Status: ${response.statusCode}');
        print('UserController: Razón - ${response.reasonPhrase}');
        print('UserController: Cuerpo - ${response.body}');
        return []; // Devuelve una lista vacía en caso de error HTTP
      }
    } catch (e) {
      print('UserController: Excepción durante fetchUsers - $e');
      return []; // Devuelve una lista vacía en caso de cualquier otra excepción
    }
  }
}

// --- Ejemplo de cómo podrías llamar a este método (para pruebas) ---
// void main() async {
//   final userController = UserController();
//   List<Map<String, dynamic>> users = await userController.fetchUsers();
//
//   if (users.isNotEmpty) {
//     print("Usuarios obtenidos:");
//     users.forEach((user) {
//       print(user);
//     });
//   } else {
//     print("No se pudieron obtener los usuarios o la lista está vacía.");
//   }
// }
