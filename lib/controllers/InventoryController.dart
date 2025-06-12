// lib/controllers/InventoryController.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';
import 'package:gestion_menu_ult_frontend/controllers/user/UserAuthContext.dart';
import 'package:gestion_menu_ult_frontend/models/Inventory.dart'; // Asegúrate que la ruta sea correcta
import 'package:http/http.dart' as http;

class InventoryController extends BaseController {
  // Estado y Filtros
  String? searchTerm;
  double? minQuantity;
  double? maxQuantity;

  // Estado de la Paginación
  int currentPage = 0; // El backend usa paginación basada en 0
  int totalPages = 1;
  int pageSize = 10;

  // Usa la IP correcta de tu backend
  @override
  final String endPoint = '/api/v1/products';

  Future<List<Inventory>> fetchProducts() async {
    String? token = await UserAuthContext.getJwtToken();
    if (token == null) throw Exception("Token de autenticación no encontrado.");

    // Construye los parámetros de la consulta para que coincidan con PaginationAndFilterRequestDto
    Map<String, String> queryParams = {
      'pageNo': currentPage.toString(),
      'pageSize': pageSize.toString(),
      'sortType': 'asc',
      'sortBy': 'description',
    };

    // Añade los filtros adicionales
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      // El backend debe saber cómo interpretar 'search'. Podría ser 'description', 'code', etc.
      queryParams['search'] = searchTerm!;
    }
    if (minQuantity != null) {
      queryParams['minExistence'] = minQuantity.toString();
    }
    if (maxQuantity != null) {
      queryParams['maxExistence'] = maxQuantity.toString();
    }

    var uri =
        Uri.parse('$baseUrl$endPoint').replace(queryParameters: queryParams);
    debugPrint("Fetching products from: $uri");

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        if (responseData.containsKey('content') &&
            responseData['content'] is List) {
          List<dynamic> productListJson =
              responseData['content'] as List<dynamic>;

          // Almacenar info de paginación de la respuesta del backend
          totalPages = responseData['totalPages'] ?? 1;
          currentPage = responseData['number'] ?? 0;

          return productListJson
              .map((data) => Inventory.fromJson(data as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
              "Formato de respuesta inesperado (falta la clave 'content').");
        }
      } else {
        throw Exception(
            "Fallo al cargar el inventario. Código: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción en fetchProducts: $e");
      throw Exception("Excepción al conectar con el backend: $e");
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
