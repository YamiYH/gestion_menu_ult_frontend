// lib/controllers/LogsController.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/BaseController.dart';
import 'package:gestion_menu_ult_frontend/controllers/user/UserAuthContext.dart';
import 'package:gestion_menu_ult_frontend/models/Logs.dart'; // Asegúrate que la ruta sea correcta
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LogsController extends BaseController {
  // --- ESTADO DE FILTROS ---
  String? searchUser;
  DateTime? startDateFilter;
  DateTime? endDateFilter;
  String selectedModuleFilter = 'Todos';
  String selectedTypeFilter = 'Todos';
  String selectedActionFilter = 'Todos';

  // --- ESTADO DE PAGINACIÓN ---
  int currentPage = 0;
  int totalPages = 1;
  int pageSize = 10;

  List<Log> _allLogs = [];

  @override
  final String endPoint = "/api/v1/logs";

  List<Log> get filteredLogs => _allLogs;

  Future<void> initializeData() async {
    // Resetea todos los filtros y la paginación al estado inicial
    searchUser = null;
    startDateFilter = null;
    endDateFilter = null;
    selectedModuleFilter = 'Todos';
    selectedTypeFilter = 'Todos';
    selectedActionFilter = 'Todos';
    currentPage = 0;
    pageSize = 10;
    debugPrint('[LogsController] Filtros y paginación inicializados.');
    await fetchLogsFromBackend();
  }

  Future<void> fetchLogsFromBackend() async {
    String? token = await UserAuthContext.getJwtToken();
    if (token == null) throw Exception("Token no encontrado.");

    Map<String, String> queryParams = {
      'pageNo': currentPage.toString(),
      'pageSize': pageSize.toString(),
      'sortType': 'desc',
      // Para logs, 'desc' es común para ver los más recientes primero
      'sortBy': 'timestamp',
    };

    if (searchUser != null && searchUser!.isNotEmpty) {
      queryParams['username'] = searchUser!;
    }
    if (startDateFilter != null) {
      queryParams['startDate'] =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(startDateFilter!);
    }
    if (endDateFilter != null) {
      queryParams['endDate'] =
          DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(endDateFilter!);
    }
    if (selectedModuleFilter != 'Todos') {
      queryParams['module'] = selectedModuleFilter;
    }
    if (selectedTypeFilter != 'Todos') queryParams['type'] = selectedTypeFilter;
    if (selectedActionFilter != 'Todos') {
      queryParams['action'] = selectedActionFilter;
    }

    var uri =
        Uri.parse('$baseUrl$endPoint').replace(queryParameters: queryParams);
    debugPrint("Fetching logs from: $uri");

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
          List<dynamic> logsListJson = responseData['content'];

          totalPages = responseData['totalPages'] ?? 1;
          currentPage = responseData['number'] ?? 0;

          _allLogs = logsListJson.map((data) => Log.fromJson(data)).toList();
          debugPrint(
              "[LogsController] Éxito. Página: $currentPage, Total Páginas: $totalPages");
        } else {
          throw Exception("Formato de respuesta de logs inesperado.");
        }
      } else {
        throw Exception("Fallo al cargar logs. Código: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción en fetchLogs: $e");
      throw Exception("Excepción al conectar con el backend: $e");
    }
  }

  // El método applyFilters ahora solo necesita llamar a fetch para que el backend filtre.
  Future<void> applyFilters() async {
    await fetchLogsFromBackend();
  }

  Future<List<String>> fetchActions() async {
    try {
      final responseData = await super.get('/api/v1/metadata/log/actions');
      final actionsList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return actionsList;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchLogTypes() async {
    try {
      final responseData = await super.get('/api/v1/metadata/log/types');
      final logTypesList =
          List<String>.from((responseData as List).map((t) => t.toString()));
      return logTypesList;
    } catch (e) {
      rethrow;
    }
  }
}
