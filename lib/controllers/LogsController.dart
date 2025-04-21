import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class LogsController {
  // Variables de filtro (NO usar final)
  String? searchUser;
  DateTime? startDateFilter;
  DateTime? endDateFilter;

  String? selectedTypeFilter = 'Todos';
  String? selectedActionFilter = 'Todos';
  String? selectedModuleFilter = 'Todos';

  // Datos simulados
  final List<Map<String, dynamic>> _allLogs = [
    {
      'id': 1,
      'type': 'login',
      'details': 'Inicio de sesión exitoso',
      'user': 'admin',
      'date': '2023-10-01 10:15 AM',
      'module': 'Configuración',
      'action': 'Crear'
    },
    {
      'id': 2,
      'type': 'error',
      'details': 'Error al acceder a la base de datos',
      'user': 'system',
      'date': '2023-10-01 11:30 AM',
      'module': 'Roles',
      'action': 'Activar'
    },
    {
      'id': 3,
      'type': 'Warning',
      'details': 'Stock bajo para item X',
      'user': 'tecnico_inv',
      'date': '2024-04-20 08:00 PM', // Fecha más reciente
      'module': 'Inventario',
      'action': 'Actualizar'
    },
  ];

  List<Map<String, dynamic>> get filteredLogs {
    // Imprimir filtros actuales para depuración (opcional)
    // debugPrint('Filtrando con: User=$searchUser, Mod=$selectedModuleFilter, Type=$selectedTypeFilter, Act=$selectedActionFilter, Start=$startDateFilter, End=$endDateFilter');

    return _allLogs.where((log) {
      // --- Filtro de Usuario ---
      final userMatch = searchUser == null ||
          searchUser!.isEmpty || // Considerar vacío como sin filtro
          (log['user'] as String? ?? '')
              .toLowerCase()
              .contains(searchUser!.toLowerCase());

      // --- Filtro de Fecha ---
      bool dateMatch = true; // Asumir que coincide si no hay rango
      DateTime? logDate;
      if (log['date'] != null) {
        // Intenta parsear la fecha de forma segura
        try {
          logDate = DateFormat('yyyy-MM-dd hh:mm a').parse(log['date']);
        } catch (e) {
          debugPrint("Error parseando fecha: ${log['date']} - $e");
          // Decide qué hacer con fechas inválidas, ¿excluirlas?
          // dateMatch = false; // Opción: excluir si la fecha es inválida
        }
      } else {
        // dateMatch = false; // Opción: excluir si no hay fecha
      }

      if (logDate != null &&
          (startDateFilter != null || endDateFilter != null)) {
        // Comprueba si está DESPUÉS o IGUAL al inicio del día de startDateFilter
        final afterStartDate = startDateFilter == null ||
            logDate.isAfter(startDateFilter!) ||
            logDate.isAtSameMomentAs(startDateFilter!);

        // Comprueba si está ANTES del inicio del día SIGUIENTE a endDateFilter
        // (esto incluye todo el día de endDateFilter)
        final beforeEndDate;
        if (endDateFilter == null) {
          beforeEndDate = true;
        } else {
          // Usamos la fecha final tal como viene de la UI (con hora 23:59:59)
          beforeEndDate = logDate.isBefore(endDateFilter!) ||
              logDate.isAtSameMomentAs(endDateFilter!);
        }
        dateMatch = afterStartDate && beforeEndDate;
      }

      // --- Filtro de Módulo ---
      final moduleMatch = selectedModuleFilter == 'Todos' ||
          (log['module'] as String? ?? '') == selectedModuleFilter;

      // --- Filtro de Tipo ---
      final typeMatch = selectedTypeFilter == 'Todos' ||
          (log['type'] as String? ?? '') == selectedTypeFilter;

      // --- Filtro de Acción ---
      final actionMatch = selectedActionFilter == 'Todos' ||
          (log['action'] as String? ?? '') == selectedActionFilter;

      // Devuelve true si cumple TODOS los filtros
      return userMatch && dateMatch && moduleMatch && typeMatch && actionMatch;
    }).toList();
  }

  void applyFilters() {
    debugPrint(
        'ApplyFilters llamado en Controller'); // Para confirmar que se llama
  }

  // Si necesitas inicializar datos
  void initializeData() {
    searchUser = null; // O '' si prefieres
    startDateFilter = null;
    endDateFilter = null;
    selectedModuleFilter = 'Todos';
    selectedTypeFilter = 'Todos';
    selectedActionFilter = 'Todos';
  }
}
