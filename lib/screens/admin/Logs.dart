import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../controllers/LogsController.dart';
import '../../widgets/CustomAppbar.dart';
import '../../widgets/DatePickerButton.dart';
import '../../widgets/Pagination.dart';
import '../../widgets/UserTextFormField.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final LogsController _controller = LogsController();
  final TextEditingController _userController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userController.addListener(_applyFilters);

    _controller.initializeData();
    _applyFilters();
  }

  @override
  void dispose() {
    _userController.removeListener(_applyFilters);
    _userController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _controller.searchUser = _userController.text;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Auditoría'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildFiltersSection(context, isMobile),
          ),
          const SizedBox(height: 20),
          isMobile ? _buildHeadersMobile() : _buildHeaders(),
          const SizedBox(height: 10),
          Expanded(
            child: _buildLogsList(isMobile),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        itemBuilder: (context, item) {
          return ListTile(title: Text(item as String));
        },
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            children: [
              UserTextFormField(text: 'Usuario', controller: _userController),
              const SizedBox(height: 15),
              _buildDatePicker(context),
              const SizedBox(height: 15),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  child: UserTextFormField(
                      text: 'Usuario', controller: _userController)),
              const SizedBox(width: 15),
              Flexible(child: _buildModulesDropdown()),
              const SizedBox(width: 15),
              Flexible(child: _buildTypeDropdown()),
              const SizedBox(width: 15),
              Flexible(child: _buildActionDropdown()),
              const SizedBox(width: 15),
              _buildDatePicker(context),
            ],
          );
  }

  Widget _buildHeadersMobile() {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          SizedBox(width: width * 0.03),
          Expanded(flex: 3, child: Text('Usuario', style: _headerStyle())),
          Expanded(flex: 3, child: Text('Fecha', style: _headerStyle())),
          const SizedBox(width: 20),
          Expanded(flex: 3, child: Text('Detalles', style: _headerStyle())),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Expanded(flex: 2, child: Text('Usuario', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Módulo', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Tipo', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Acción', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Fecha', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Detalles', style: _headerStyle())),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DatePickerButton(
          label: 'Desde',
          selectedDate: _controller.startDateFilter,
          onDateSelected: (date) {
            if (date == null) return; // Protección extra
            _controller.startDateFilter = date;
            // Ajusta 'Hasta' si es necesario
            if (_controller.endDateFilter != null &&
                _controller.startDateFilter != null &&
                _controller.endDateFilter!
                    .isBefore(_controller.startDateFilter!)) {
              _controller.endDateFilter = _controller.startDateFilter;
            }
            _applyFilters();
          },
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          includeTime: false,
        ),
        const SizedBox(width: 10),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        const SizedBox(width: 10),
        DatePickerButton(
          label: 'Hasta',
          selectedDate: _controller.endDateFilter,
          onDateSelected: (date) {
            if (date == null) {
              _controller.endDateFilter = null; // Permite borrar la fecha final
            } else {
              // Establece la hora al final del día seleccionado
              _controller.endDateFilter =
                  DateTime(date.year, date.month, date.day, 23, 59, 59);
            }
            _applyFilters();
          },
          firstDate: _controller.startDateFilter ?? DateTime(2000),
          lastDate: DateTime.now(),
          includeTime: false, // La hora se ajusta manualmente en onDateSelected
        ),
      ],
    );
  }

  Widget _buildModulesDropdown() {
    final List<String> moduleOptions = [
      'Todos',
      'Usuarios',
      'Seguridad',
      'Roles',
      'Tickets',
      'Ventas',
      'Menú',
      'Inventario',
      'Reportes',
      'Configuración'
    ];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Módulo',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: _controller.selectedModuleFilter,
      onChanged: (newValue) {
        if (newValue == null) return;

        _controller.selectedModuleFilter = newValue;
        _applyFilters();
      },
      items: moduleOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }

  Widget _buildTypeDropdown() {
    final List<String> typeOptions = ['Todos', 'login', 'error', 'Warning'];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Tipo',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: _controller.selectedTypeFilter,
      onChanged: (String? newValue) {
        if (newValue == null) return;

        _controller.selectedTypeFilter = newValue;
        _applyFilters();
      },
      items: typeOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }

  Widget _buildActionDropdown() {
    final List<String> actionOptions = [
      'Todos',
      'Crear',
      'Actualizar',
      'Eliminar',
      'Activar',
      'Desactivar',
      'Iniciar sesión',
      'Cerrar sesión',
      'Cambiar contraseña',
    ];

    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Acción',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      value: _controller.selectedActionFilter,
      onChanged: (String? newValue) {
        if (newValue == null) return;
        _controller.selectedActionFilter = newValue;
        _applyFilters();
      },
      items: actionOptions.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
    );
  }

  Widget _buildLogsList(bool isMobile) {
    final List<Map<String, dynamic>> filteredLogs = _controller.filteredLogs;

    if (filteredLogs.isEmpty) {
      return const Center(child: Text('No existen logs.'));
    }

    return ListView.builder(
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final log = filteredLogs[index];

        String formattedDate = _formatLogDate(log['date']);
        String user = log['username']?.toString() ?? 'N/A';
        String module = log['module']?.toString() ?? 'N/A';
        String type = log['type']?.toString() ?? 'N/A';
        String action = log['action']?.toString() ?? 'N/A';
        String details = log['details']?.toString() ?? 'N/A';

        Widget logRow = isMobile
            ? _buildLogRowMobile(user, formattedDate, details)
            : _buildLogRowWeb(
                user, module, type, action, formattedDate, details);

        return Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: logRow,
            ),
            const Divider(height: 1, thickness: 1),
          ],
        );
      },
    );
  }

  Widget _buildLogRowMobile(String user, String formattedDate, String details) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.03),
        Expanded(flex: 3, child: Text(user, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 3,
            child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 20),
        Expanded(
            flex: 3, child: Text(details, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildLogRowWeb(String username, String module, String type,
      String action, String formattedDate, String details) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
        Expanded(
            flex: 2, child: Text(username, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(module, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(type, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(action, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2,
            child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 2, child: Text(details, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  String _formatLogDate(dynamic dateValue) {
    if (dateValue == null) return 'Fecha N/A';
    DateTime? parsedDate;
    if (dateValue is DateTime) {
      parsedDate = dateValue;
    } else if (dateValue is String) {
      try {
        parsedDate = DateFormat('yyyy-MM-dd hh:mm a').parse(dateValue);
      } catch (e) {
        try {
          parsedDate = DateTime.parse(dateValue);
        } catch (e2) {
          return dateValue; // O 'Fecha inválida'
        }
      }
    } else {
      return 'Tipo fecha no válido';
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
