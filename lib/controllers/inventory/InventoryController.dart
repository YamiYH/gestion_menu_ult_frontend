// lib/controllers/InventoryController.dart

import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';
import 'package:gestion_menu_ult_frontend/models/Inventory.dart'; // Asegúrate que la ruta sea correcta

class InventoryController extends BaseController {
  // Estado y Filtros
  String? searchTerm;
  double? minQuantity;
  double? maxQuantity;

  // Usa la IP correcta de tu backend
  @override
  final String endPoint = '/api/v1/products';

  Future<List<Inventory>> fetchProducts({Map<String, String>? filters}) async {
    Map<String, String> queryParams = {
      'pageNo': super.currentPage.toString(),
      'pageSize': super.pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'description',
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
        List<dynamic> inventoryListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return inventoryListJson
            .map((data) => Inventory.fromJson(data))
            .toList();
      } else {
        throw Exception("Formato de respuesta de recetas inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Inventory>> fetchFullListOfProducts() async {
    Map<String, String> queryParams = {
      'pageNo': '0',
      'pageSize': '500',
      'sortType': 'asc',
      'sortBy': 'description',
    };

    try {
      // Llama al método GET genérico de la clase padre
      final responseData = await super.get(endPoint, queryParams: queryParams);

      // Interpreta la respuesta JSON específica de este método
      if (responseData is Map<String, dynamic> &&
          responseData.containsKey('content')) {
        List<dynamic> productListJson = responseData['content'];
        super.totalPages = responseData['totalPages'] ?? 1;
        super.currentPage = responseData['number'] ?? 0;
        return productListJson.map((data) => Inventory.fromJson(data)).toList();
      } else {
        throw Exception("Formato de respuesta de productos inesperado.");
      }
    } catch (e) {
      rethrow;
    }
  }
}
