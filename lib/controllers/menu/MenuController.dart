import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';

class MenuEntityController extends BaseController {
  @override
  final String endPoint = '/api/v1/menu';

  // --- MÉTODO PARA OBTENER LA LISTA DE MENUES ---
  Future<List<MenuEntity>> fetchMenu({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'dsc',
      'sortBy': 'date',
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
        List<dynamic> menuListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return menuListJson.map((data) => MenuEntity.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de recetas inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA OBTENER LA LISTA DE MENUES LISTOS PARA VENDER---
  Future<List<MenuEntity>> fetchSaleMenu({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'date',
    };

    if (filters != null) {
      queryParams.addAll(filters);
    }

    final String newEndpoint = '$endPoint/sale';

    try {
      // Llama al método GET genérico de la clase padre
      final responseData =
          await super.get(newEndpoint, queryParams: queryParams);

      // Interpreta la respuesta JSON específica de este método
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('content')) {
        List<dynamic> menuListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return menuListJson.map((data) => MenuEntity.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de recetas inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA CREAR UNA RECETA (SIMPLIFICADO) ---
  Future<MenuEntity> createMenu(Map<String, dynamic> menuData) async {
    try {
      // Llama al método POST genérico
      final responseData = await super.post(endPoint, body: menuData);
      return MenuEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR UN MENU (SIMPLIFICADO) ---
  Future<MenuEntity> updateMenu(Map<String, dynamic> menuData) async {
    try {
      // Llama al método PUT genérico
      print(menuData);
      final responseData = await super.put(endPoint, body: menuData);
      return MenuEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ACTUALIZAR EL STATUS DE UN MENU (SIMPLIFICADO) ---
  Future<MenuEntity> changeStatusMenu(String id, String status) async {
    Map<String, String> queryParams = {'status': status};
    try {
      // Llama al método PUT genérico
      final responseData =
          await super.putWithParams('$endPoint/$id', queryParams: queryParams);
      return MenuEntity.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO PARA ELIMINAR UN MENU (SIMPLIFICADO) ---
  Future<void> deleteMenu(String id) async {
    try {
      // Llama al método DELETE genérico, construyendo la ruta completa del recurso
      await super.delete('$endPoint/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isMenuProposal(String date, String category, String type) async {
    try {
      final bool responseData =
          await super.get('$endPoint/isproposed', queryParams: {
        'date': date,
        'category': category,
        'type': type,
      });
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CON ENDPOINT CATEGORIAS ---
  Future<List<String>> fetchMenuCategories() async {
    try {
      final responseData = await super.get('/api/v1/metadata/menu/categories');
      final categoriesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return categoriesList;
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CON ENDPOINT TIPOS ---
  Future<List<String>> fetchMenuTypes() async {
    try {
      final responseData = await super.get('/api/v1/metadata/menu/types');
      final categoriesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return categoriesList;
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODO CON ENDPOINT ESTADOS ---
  Future<List<String>> fetchMenuStatus() async {
    try {
      final responseData = await super.get('/api/v1/metadata/menu/status');
      final categoriesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return categoriesList;
    } catch (e) {
      rethrow;
    }
  }
}
