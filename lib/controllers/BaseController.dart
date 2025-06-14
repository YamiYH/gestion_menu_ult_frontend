// lib/controllers/BaseController.dart

import 'dart:convert';

import 'package:flutter/material.dart'; // Asumo que tu UserAuthContext está en es
import 'package:gestion_menu_ult_frontend/controllers/security/user/UserAuthContext.dart';
import 'package:http/http.dart' as http;

abstract class BaseController {
  // Propiedad que cada controlador hijo DEBE definir.
  abstract final String endPoint;

  // Propiedades comunes que pueden ser usadas por los hijos.
  final String baseUrl =
      'http://192.168.1.111:8887'; // O desde un archivo de configuración

  // Estado de paginación
  int currentPage = 0;
  int totalPages = 1;
  int pageSize = 10;

  // --- MÉTODOS HTTP GENÉRICOS ---

  // Método GET genérico
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams}) async {
    final headers = await _getAuthenticatedHeaders();
    final uri =
        Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

    debugPrint("GET Request to: $uri");

    final response = await http.get(uri, headers: headers);
    return _processResponse(response);
  }

  // Método POST genérico
  Future<dynamic> post(String path,
      {required Map<String, dynamic> body}) async {
    final headers = await _getAuthenticatedHeaders();
    final uri = Uri.parse('$baseUrl$path');

    debugPrint("POST Request to: $uri");

    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));
    return _processResponse(response);
  }

  // Método PUT genérico
  Future<dynamic> put(String path, {required Map<String, dynamic> body}) async {
    final headers = await _getAuthenticatedHeaders();
    final uri = Uri.parse('$baseUrl$path');

    debugPrint("PUT Request to: $uri");

    final response =
        await http.put(uri, headers: headers, body: jsonEncode(body));
    return _processResponse(response);
  }

  // Método PUT genérico
  Future<dynamic> putWithParams(String path,
      {required Map<String, dynamic> queryParams}) async {
    final headers = await _getAuthenticatedHeaders();
    final uri =
        Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);

    debugPrint("PUT Request to: $uri");

    final response = await http.put(uri, headers: headers);
    return _processResponse(response);
  }

  // Método DELETE genérico
  Future<dynamic> delete(String path) async {
    final headers = await _getAuthenticatedHeaders();
    final uri = Uri.parse('$baseUrl$path');

    debugPrint("DELETE Request to: $uri");

    final response = await http.delete(uri, headers: headers);
    return _processResponse(response);
  }

  // Método getById genérico
  Future<dynamic> getById(String path) async {
    final headers = await _getAuthenticatedHeaders();
    final uri = Uri.parse('$baseUrl$path');

    debugPrint("getById Request to: $uri");

    final response = await http.get(uri, headers: headers);
    return _processResponse(response);
  }

  // Centraliza la obtención del token y la creación de headers
  Future<Map<String, String>> _getAuthenticatedHeaders() async {
    String? token = await UserAuthContext.getJwtToken();
    if (token == null) {
      // Considera manejar esto de una forma más elegante, como redirigir a login
      // o lanzar una excepción de un tipo específico.
      throw Exception(
          "Token de autenticación no encontrado. El usuario debe iniciar sesión.");
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // Centraliza el procesamiento de la respuesta HTTP
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.bodyBytes.isEmpty) {
        // Para respuestas como 204 No Content que no tienen cuerpo
        return null;
      }
      // Decodifica usando utf8 para manejar tildes y caracteres especiales
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      // Lanza una excepción estandarizada con información útil
      debugPrint(
          "Error en la respuesta del API. Código: ${response.statusCode}, Cuerpo: ${response.body}");
      throw Exception(
          "Fallo en la solicitud al API. Código: ${response.statusCode}");
    }
  }
}
