import 'package:intl/intl.dart' show DateFormat;

class LogsController {
  // Variables de filtro (NO usar final)
  String? searchUser;
  String? selectedTypeFilter;
  String? selectedActionFilter;
  String? selectedModuleFilter;
  DateTime? startDateFilter;
  DateTime? endDateFilter;

  // Datos simulados
  final List<Map<String, dynamic>> _allLogs = [
    {
      'type': 'login',
      'details': 'Inicio de sesión exitoso',
      'user': 'admin',
      'date': '2023-10-01 10:15 AM',
      'module': 'Configuración',
      'action': 'Crear'
    },
    {
      'type': 'error',
      'details': 'Error al acceder a la base de datos',
      'user': 'system',
      'date': '2023-10-01 11:30 AM',
      'module': 'Roles',
      'action': 'Activar'
    },
  ];

// Logs filtrados (getter)
  List<Map<String, dynamic>> get filteredLogs {
    return _allLogs.where((log) {
      DateTime logDate = DateFormat('yyyy-MM-dd hh:mm a').parse(log['date']);
      bool matchesUser = searchUser == null ||
          log['user'].toLowerCase().contains(searchUser!.toLowerCase());
      bool matchesDate = (startDateFilter == null || endDateFilter == null) ||
          (logDate.isAfter(startDateFilter!) &&
              logDate.isBefore(endDateFilter!.add(Duration(days: 1))));
      bool matchesType =
          selectedTypeFilter == null || log['type'] == selectedTypeFilter;
      return matchesUser && matchesDate && matchesType;
    }).toList();
  }

  // Si necesitas inicializar datos
  void initializeData() {
    // Puedes inicializar filtros aquí si es necesario
  }
}
