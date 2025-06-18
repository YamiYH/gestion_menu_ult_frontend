import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/security/user/UserAuthContext.dart';
import 'package:gestion_menu_ult_frontend/models/SalesReport.dart'; // Importa los nuevos modelos
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ReportController {
  // Estado de paginación y filtros
  int currentPage = 0;
  int totalPages = 1;
  int pageSize = 10;
  DateTime? startDate;
  DateTime? endDate;

  final String _baseUrl = 'http://192.168.1.111:8887'; // IP de tu backend
  final String _endPoint =
      '/api/v1/reports'; // Asume este endpoint para informes de ventas

  Future<List<DailyReportGroup>> fetchReports() async {
    String? token = await UserAuthContext.getJwtToken();
    if (token == null) throw Exception("Token de autenticación no encontrado.");

    Map<String, String> queryParams = {
      'pageNo': currentPage.toString(),
      'pageSize': pageSize.toString(),
      'sortType': 'desc',
      // Generalmente se quieren los informes más recientes primero
      'sortBy': 'fecha',
    };

    if (startDate != null) {
      queryParams['startDate'] = DateFormat('yyyy-MM-dd').format(startDate!);
    }
    if (endDate != null) {
      queryParams['endDate'] = DateFormat('yyyy-MM-dd').format(endDate!);
    }

    var uri =
        Uri.parse('$_baseUrl$_endPoint').replace(queryParameters: queryParams);
    debugPrint("Fetching reports from: $uri");

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
          List<dynamic> reportListJson = responseData['content'];

          totalPages = responseData['totalPages'] ?? 1;
          currentPage = responseData['number'] ?? 0;

          return reportListJson
              .map((data) => DailyReportGroup.fromJson(data))
              .toList();
        } else {
          throw Exception("Formato de respuesta inesperado.");
        }
      } else {
        throw Exception(
            "Fallo al cargar informes. Código: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción en fetchReports: $e");
      throw Exception("Excepción al conectar con el backend: $e");
    }
  }
}
