import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/TypeDropDown.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../controllers/logs/LogsController.dart';
import '../../models/Logs.dart';
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
  bool _isLoading = true;
  String _errorMessage = '';
  final String _selectedType = 'Todos';

  @override
  void initState() {
    super.initState();
    _userController.addListener(_onUserFilterChanged);
    _fetchInitialLogs();
  }

  Future<void> _fetchInitialLogs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _controller.initializeData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar logs: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _userController.removeListener(_onUserFilterChanged);
    _userController.dispose();
    super.dispose();
  }

  void _onUserFilterChanged() {
    if (_controller.searchUser != _userController.text) {
      _triggerFilterChange();
    }
  }

  void _triggerFilterChange() {
    // Cuando cualquier filtro cambia, reseteamos a la página 0 y volvemos a buscar
    _controller.currentPage = 0;
    _applyFiltersAndReloadData();
  }

  Future<void> _applyFiltersAndReloadData() async {
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true;
    });

    // Pasa los valores actuales de la UI al controller antes de la llamada
    _controller.searchUser = _userController.text;

    try {
      await _controller.applyFilters();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al aplicar filtros: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          const SizedBox(height: 10),
          isMobile ? _buildHeadersMobile() : _buildHeaders(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16)))
                    : _buildLogsList(isMobile),
          ),
        ],
      ),
      bottomNavigationBar: Pagination(
        currentPage: _controller.currentPage,
        totalPages: _controller.totalPages,
        itemsPerPage: _controller.pageSize,
        onPageChanged: (newPage) {
          if (_controller.currentPage != newPage) {
            _controller.currentPage = newPage;
            _applyFiltersAndReloadData(); // No resetea filtros, solo cambia de página
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            _controller.pageSize = newSize;
            _controller.currentPage = 0; // Vuelve a la primera página
            _applyFiltersAndReloadData();
          }
        },
      ),
    );
  }

  Widget _buildFiltersSection(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserTextFormField(text: 'Usuario', controller: _userController),
              const SizedBox(height: 15),
              _buildModulesDropdown(),
              const SizedBox(height: 15),
              TypeDropDown(
                selectedValue: _selectedType,
                onChanged: (value) {},
              ),
              const SizedBox(height: 15),
              _buildActionDropdown(),
              const SizedBox(height: 15),
              _buildDatePicker(context),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: UserTextFormField(
                      text: 'Usuario', controller: _userController)),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildModulesDropdown()),
              const SizedBox(width: 15),
              Expanded(
                  flex: 2,
                  child: TypeDropDown(
                    selectedValue: _selectedType,
                    onChanged: (value) {},
                  )),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildActionDropdown()),
              const SizedBox(width: 15),
              Expanded(flex: 4, child: _buildDatePicker(context)),
            ],
          );
  }

  Widget _buildHeadersMobile() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Usuario', style: _headerStyle())),
          Expanded(flex: 4, child: Text('Fecha', style: _headerStyle())),
          Expanded(flex: 5, child: Text('Detalles', style: _headerStyle())),
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
          Expanded(flex: 2, child: Text('Usuario', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Módulo', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Tipo', style: _headerStyle())),
          Expanded(flex: 2, child: Text('Acción', style: _headerStyle())),
          Expanded(flex: 3, child: Text('Fecha', style: _headerStyle())),
          Expanded(flex: 4, child: Text('Detalles', style: _headerStyle())),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        DatePickerButton(
          label: 'Desde',
          selectedDate: _controller.startDateFilter,
          onDateSelected: (date) {
            _controller.startDateFilter = date;
            _triggerFilterChange();
          },
          firstDate: DateTime(2000),
          lastDate: _controller.endDateFilter ?? DateTime.now(),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.arrow_forward, color: Colors.grey),
        ),
        DatePickerButton(
          label: 'Hasta',
          selectedDate: _controller.endDateFilter,
          onDateSelected: (date) {
            if (date == null) {
              _controller.endDateFilter = null;
            } else {
              _controller.endDateFilter =
                  DateTime(date.year, date.month, date.day, 23, 59, 59);
            }
            _triggerFilterChange();
          },
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildModulesDropdown() {
    final List<String> moduleOptions = [];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
          labelText: 'Módulo',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
      isExpanded: true,
      value: _controller.selectedModuleFilter,
      onChanged: (newValue) {
        if (newValue == null || _controller.selectedModuleFilter == newValue)
          return;
        _controller.selectedModuleFilter = newValue;
        _triggerFilterChange();
      },
      items: moduleOptions
          .map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis)))
          .toList(),
    );
  }

  Widget _buildActionDropdown() {
    final List<String> actionOptions = [];
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
          labelText: 'Acción',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
      isExpanded: true,
      value: _controller.selectedActionFilter,
      onChanged: (String? newValue) {
        if (newValue == null || _controller.selectedActionFilter == newValue)
          return;
        _controller.selectedActionFilter = newValue;
        _triggerFilterChange();
      },
      items: actionOptions
          .map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value, overflow: TextOverflow.ellipsis)))
          .toList(),
    );
  }

  Widget _buildLogsList(bool isMobile) {
    final List<Log> filteredLogs = _controller.filteredLogs;
    if (filteredLogs.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No se encontraron logs con los filtros aplicados.',
                  style: TextStyle(fontSize: 16))));
    }
    return ListView.separated(
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1),
      itemCount: filteredLogs.length,
      itemBuilder: (context, index) {
        final Log log = filteredLogs[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          child: isMobile
              ? _buildLogRowMobile(log.username, _formatLogDate(log.date),
                  log.description ?? 'Sin detalles')
              : _buildLogRowWeb(log.username, log.module, log.type, log.action,
                  _formatLogDate(log.date), log.description ?? 'Sin detalles'),
        );
      },
    );
  }

  Widget _buildLogRowMobile(String user, String formattedDate, String details) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(user, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 4,
            child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 5,
            child: Text(details, overflow: TextOverflow.ellipsis, maxLines: 1)),
      ],
    );
  }

  Widget _buildLogRowWeb(String username, String module, String type,
      String action, String formattedDate, String details) {
    return Row(
      children: [
        Expanded(
            flex: 2, child: Text(username, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(module, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(type, overflow: TextOverflow.ellipsis)),
        Expanded(flex: 2, child: Text(action, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 3,
            child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
        Expanded(
            flex: 4,
            child: Text(details, overflow: TextOverflow.ellipsis, maxLines: 1)),
      ],
    );
  }

  String _formatLogDate(DateTime dateValue) {
    return DateFormat('yyyy-MM-dd HH:mm', 'es_ES').format(dateValue);
  }

  TextStyle _headerStyle() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red[900],
      fontSize: 16,
    );
  }
}
