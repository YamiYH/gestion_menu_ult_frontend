// lib/controllers/user/UserController.dart

import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';

import '../../../models/UserEntity.dart';
import '../../BaseController.dart';

class UserController extends BaseController {
  @override
  final String endPoint = '/api/v1/users';

  // --- MÉTODO PARA OBTENER LA LISTA DE USUARIOS (SIMPLIFICADO) ---
  Future<List<User>> fetchUsers({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'name',
    };

    if (filters != null) {
      queryParams.addAll(filters);
    }

    try {
      // Llama al método GET genérico de la clase padre
      final responseData = await super.get(endPoint, queryParams: queryParams);

      // Interpreta la respuesta JSON específica de este método
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('content')) {
        List<dynamic> userListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return userListJson.map((data) => User.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de usuarios inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA CREAR UN USUARIO (SIMPLIFICADO) ---
  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      // Llama al método POST genérico
      final responseData = await super.post(endPoint, body: userData);
      return User.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR UN USUARIO (SIMPLIFICADO) ---
  Future<User> updateUser(Map<String, dynamic> userData) async {
    try {
      // Llama al método PUT genérico
      final responseData = await super.put(endPoint, body: userData);
      return User.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ELIMINAR UN USUARIO (SIMPLIFICADO) ---
  Future<void> deleteUser(String username) async {
    try {
      // Llama al método DELETE genérico, construyendo la ruta completa del recurso
      await super.delete('$endPoint/$username');
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CON ENDPOINT DIFERENTE ---
  Future<List<String>> fetchUserTypes() async {
    try {
      final responseData = await super.get('/api/v1/metadata/user/types');
      final typesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return typesList;
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getByUsername(String username) async {
    try {
      // Llama al método DELETE genérico, construyendo la ruta completa del recurso
      final responseData = await super.getById('$endPoint/$username');
      return User.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getAllUsers() async {
    Map<String, String> queryParams = {
      'pageNo': '0',
      'pageSize': '9000',
      'sortType': 'asc',
      'sortBy': 'name',
    };

    try {
      // Llama al método GET genérico de la clase padre
      final responseData = await super.get(endPoint, queryParams: queryParams);

      // Interpreta la respuesta JSON específica de este método
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('content')) {
        List<dynamic> userListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return userListJson.map((data) => User.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de usuarios inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }
}
