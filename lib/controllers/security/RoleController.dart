import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';

import '../../models/RoleEntity.dart';

class RoleController extends BaseController {
  @override
  final String endPoint = '/api/v1/roles';

// --- MÉTODO PARA OBTENER UNA LISTA DE ROLES ---
  Future<List<RoleEntity>> fetchRoles() async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'deletable',
    };

    try {
      final response = await super.get(endPoint, queryParams: queryParams);

      if (response.containsKey('content') && response['content'] is List) {
        final List<dynamic> rolesContent = response['content'] as List<dynamic>;
        super.totalPages = response['totalPages'] ?? 1;
        super.currentPage = response['number'] ?? 0;
        // Mapea la lista JSON a una lista de objetos Role usando el constructor fromJson
        final List<RoleEntity> roleList = rolesContent
            .map((roleJson) =>
                RoleEntity.fromJson(roleJson as Map<String, dynamic>))
            .toList();

        return roleList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Fallo al cargar roles: $e');
    }
  }

// --- MÉTODO PARA OBTENER UN ROL ---
  Future<RoleEntity> getRoleById(String id) async {
    try {
      // Llama al método getById genérico
      final responseData = await super.getById('$endPoint/$id');
      return RoleEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA CREAR UN ROL ---
  Future<RoleEntity> createRole(Map<String, dynamic> roleData) async {
    try {
      // Llama al método POST genérico
      final responseData = await super.post(endPoint, body: roleData);
      return RoleEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR UN ROL ---
  Future<RoleEntity> updateRole(Map<String, dynamic> roleData) async {
    try {
      // Llama al método PUT genérico
      final responseData = await super.put(endPoint, body: roleData);
      return RoleEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ELIMINAR UN ROL ---
  Future<void> deleteRole(String id) async {
    try {
      await super.delete('$endPoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchRoleNames() async {
    try {
      // Reutiliza tu método existente para obtener todos los roles
      final roles = await fetchRoles();
      // Extrae solo la propiedad 'name' de cada objeto RoleM
      return roles.map((role) => role.description).toList();
    } catch (e) {
      // Lanza la excepción para que la UI pueda manejarla
      throw Exception('Fallo al obtener la lista de nombres de roles.');
    }
  }

  // --- NUEVO MÉTODO PARA OBTENER ID POR DESCRIPCIÓN ---
  Future<String?> getRoleIdByDescription(String description) async {
    try {
      // 1. Obtiene la lista completa de objetos Role desde el backend
      final List<RoleEntity> allRoles =
          await fetchRoles(); // Reutiliza tu método existente

      // 2. Busca en la lista el rol que coincida con la descripción
      for (final role in allRoles) {
        if (role.description == description) {
          return role.id; // 3. Si lo encuentra, devuelve su ID
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> fetchModules() async {
    try {
      final responseData = await super.get('/api/v1/metadata/modules');
      final typesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return typesList;
    } catch (e) {
      rethrow;
    }
  }
}
