import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../controllers/RoleController.dart';
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
  // --- CONTROLLERS ---
  final LogsController _controller = LogsController();
  final RoleController _roleController = RoleController();
  final TextEditingController _userControllerText = TextEditingController();

  // --- UI STATE ---
  bool _isLoading = true;
  bool _areFiltersLoading = true;
  String _errorMessage = '';
  Timer? _debounce;

  // --- DYNAMIC FILTER OPTIONS ---
  List<String> _moduleOptions = ['Todos'];
  List<String> _actionOptions = ['Todos'];
  List<String> _typeOptions = ['Todos']; // AÑADIDO para los tipos

  @override
  void initState() {
    super.initState();
    _userControllerText.addListener(_onUserFilterChanged);
    _loadInitialScreenData();
  }

  @override
  void dispose() {
    _userControllerText.removeListener(_onUserFilterChanged);
    _userControllerText.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- DATA FETCHING LOGIC ---

  Future<void> _loadInitialScreenData() async {
    setState(() {
      _isLoading = true;
      _areFiltersLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _loadFilterOptions(),
        _controller.initializeData(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar datos: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _areFiltersLoading = false;
        });
      }
    }
  }

  Future<void> _loadFilterOptions() async {
    try {
      final results = await Future.wait([
        _roleController.fetchModules(),
        _controller.fetchActions(),
        _controller.fetchLogTypes(), // AÑADIDO
      ]);
      final fetchedModules = results[0] as List<String>;
      final fetchedActions = results[1] as List<String>;
      final fetchedTypes = results[2] as List<String>; // AÑADIDO

      if (mounted) {
        setState(() {
          _moduleOptions = ['Todos', ...fetchedModules];
          _actionOptions = ['Todos', ...fetchedActions];
          _typeOptions = ['Todos', ...fetchedTypes]; // AÑADIDO
        });
      }
    } catch (e) {
      debugPrint("Error cargando opciones de filtros: $e");
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudieron cargar los filtros.';
        });
      }
    }
  }

  // --- EVENT HANDLERS ---

  void _onUserFilterChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_controller.searchUser != _userControllerText.text) {
        _triggerFilterChange();
      }
    });
  }

  void _triggerFilterChange() {
    if (!mounted) return;
    setState(() {
      _controller.currentPage = 0;
    });
    _applyFiltersAndReloadData();
  }

  Future<void> _applyFiltersAndReloadData() async {
    if (!mounted || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    _controller.searchUser = _userControllerText.text;

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

  // --- BUILD METHOD ---

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
            setState(() {
              _controller.currentPage = newPage;
            });
            _applyFiltersAndReloadData();
          }
        },
        onItemsPerPageChanged: (newSize) {
          if (_controller.pageSize != newSize) {
            setState(() {
              _controller.pageSize = newSize;
              _controller.currentPage = 0;
            });
            _applyFiltersAndReloadData();
          }
        },
      ),
    );
  }

  // --- UI WIDGET BUILDERS ---

  Widget _buildFiltersSection(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserTextFormField(
                  text: 'Usuario', controller: _userControllerText),
              const SizedBox(height: 15),
              _buildModulesDropdown(),
              const SizedBox(height: 15),
              _buildTypeDropdown(), // REEMPLAZADO
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
                      text: 'Usuario', controller: _userControllerText)),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildModulesDropdown()),
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildTypeDropdown()), // REEMPLAZADO
              const SizedBox(width: 15),
              Expanded(flex: 2, child: _buildActionDropdown()),
              const SizedBox(width: 15),
              Expanded(flex: 4, child: _buildDatePicker(context)),
            ],
          );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Tipo',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        isExpanded: true,
        value: _controller.selectedTypeFilter,
        items: _buildDropdownItems(_typeOptions),
        // Usa la lista de tipos
        onChanged: _areFiltersLoading
            ? null
            : (newValue) {
                if (newValue == null) return;
                setState(() {
                  _controller.selectedTypeFilter = newValue;
                });
                _triggerFilterChange();
              });
  }

  Widget _buildModulesDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Módulo',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      value: _controller.selectedModuleFilter,
      onChanged: _areFiltersLoading
          ? null
          : (newValue) {
              if (newValue == null) return;
              setState(() {
                _controller.selectedModuleFilter = newValue;
              });
              _triggerFilterChange();
            },
      items: _buildDropdownItems(_moduleOptions),
    );
  }

  Widget _buildActionDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Acción',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      isExpanded: true,
      value: _controller.selectedActionFilter,
      onChanged: _areFiltersLoading
          ? null
          : (newValue) {
              if (newValue == null) return;
              setState(() {
                _controller.selectedActionFilter = newValue;
              });
              _triggerFilterChange();
            },
      items: _buildDropdownItems(_actionOptions),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(List<String> options) {
    if (_areFiltersLoading && options.length <= 1) {
      // Muestra "Cargando..." solo si aún no hay opciones
      return [
        const DropdownMenuItem(
          value: 'Todos',
          enabled: false,
          child: Row(
            children: [
              Text('Cargando...'),
              SizedBox(width: 10),
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ],
          ),
        ),
      ];
    }
    return options.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value, overflow: TextOverflow.ellipsis),
      );
    }).toList();
  }

  // --- El resto del código permanece igual ---

  Widget _buildDatePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DatePickerButton(
            label: 'Desde',
            selectedDate: _controller.startDateFilter,
            onDateSelected: (date) {
              setState(() {
                _controller.startDateFilter = date;
              });
              _triggerFilterChange();
            },
            firstDate: DateTime(2000),
            lastDate: _controller.endDateFilter ?? DateTime.now(),
          ),
        ),
        if (_controller.startDateFilter != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            tooltip: 'Limpiar fecha de inicio',
            onPressed: () {
              setState(() => _controller.startDateFilter = null);
              _triggerFilterChange();
            },
          ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(Icons.arrow_forward, color: Colors.grey),
        ),
        Expanded(
          child: DatePickerButton(
            label: 'Hasta',
            selectedDate: _controller.endDateFilter,
            onDateSelected: (date) {
              setState(() {
                if (date == null) {
                  _controller.endDateFilter = null;
                } else {
                  _controller.endDateFilter =
                      DateTime(date.year, date.month, date.day, 23, 59, 59);
                }
              });
              _triggerFilterChange();
            },
            firstDate: _controller.startDateFilter ?? DateTime(2000),
            lastDate: DateTime.now(),
          ),
        ),
        if (_controller.endDateFilter != null)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            tooltip: 'Limpiar fecha de fin',
            onPressed: () {
              setState(() => _controller.endDateFilter = null);
              _triggerFilterChange();
            },
          ),
      ],
    );
  }

  Widget _buildHeadersMobile() {
    return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(children: [
          Expanded(flex: 3, child: Text('Usuario', style: _headerStyle())),
          Expanded(flex: 4, child: Text('Fecha', style: _headerStyle())),
          Expanded(flex: 5, child: Text('Detalles', style: _headerStyle()))
        ]));
  }

  Widget _buildHeaders() {
    return Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.12,
              child: Text('Usuario', style: _headerStyle())),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.12,
              child: Text('Módulo', style: _headerStyle())),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.12,
              child: Text('Tipo', style: _headerStyle())),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.14,
              child: Text('Acción', style: _headerStyle())),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.14,
              child: Text('Fecha', style: _headerStyle())),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.17,
              child: Text('Detalles', style: _headerStyle()))
        ]));
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
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
              child: isMobile
                  ? _buildLogRowMobile(log.username, _formatLogDate(log.date),
                      log.description ?? 'Sin detalles')
                  : _buildLogRowWeb(
                      log.username,
                      log.module,
                      log.type,
                      log.action,
                      _formatLogDate(log.date),
                      log.description ?? 'Sin detalles'));
        });
  }

  Widget _buildLogRowMobile(String user, String formattedDate, String details) {
    return Row(children: [
      Expanded(flex: 3, child: Text(user, overflow: TextOverflow.ellipsis)),
      Expanded(
          flex: 4, child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
      Expanded(
          flex: 5,
          child: Text(details, overflow: TextOverflow.ellipsis, maxLines: 1))
    ]);
  }

  Widget _buildLogRowWeb(String username, String module, String type,
      String action, String formattedDate, String details) {
    return Row(children: [
      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(username, overflow: TextOverflow.ellipsis)),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(module, overflow: TextOverflow.ellipsis)),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.12,
          child: Text(type, overflow: TextOverflow.ellipsis)),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.14,
          child: Text(action, overflow: TextOverflow.ellipsis)),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.14,
          child: Text(formattedDate, overflow: TextOverflow.ellipsis)),
      SizedBox(
          width: MediaQuery.of(context).size.width * 0.17,
          child: Text(details, overflow: TextOverflow.ellipsis, maxLines: 1))
    ]);
  }

  String _formatLogDate(DateTime dateValue) {
    return DateFormat('yyyy-MM-dd HH:mm', 'es_ES').format(dateValue);
  }

  TextStyle _headerStyle() {
    return TextStyle(
        fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 16);
  }
}
