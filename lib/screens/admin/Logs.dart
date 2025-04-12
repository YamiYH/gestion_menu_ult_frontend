import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/UserTextFormField.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../controllers/LogsController.dart';
import '../../widgets/DatePickerButton.dart';
import '../../widgets/FilterButton.dart';
import '../../widgets/Pagination.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final LogsController _controller = LogsController();
  String selectedTypeFilter = 'Todos';
  String selectedActionFilter = 'Todos';
  String selectedModuleFilter = 'Todos';
  final TextEditingController _usercontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.initializeData(); // Inicializar datos si es necesario
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
              child: _buildFilters(context, isMobile)),
          SizedBox(height: 40),
          isMobile ? _buildHeadersMobile() : _buildHeaders(),
          SizedBox(height: isMobile ? 10 : 15),
          _buildLogsList(),
        ],
      ),
      bottomNavigationBar: Pagination(
        itemBuilder: (context, item) {
          return ListTile(
            title: Text(item as String),
          );
        },
      ),
      // Lista de logs filtrados
    );
  }

  // Encabezados responsivos
  Widget _buildHeadersMobile() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            height: 20,
            child: Text('Usuario', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            height: 20,
            child: Text('Fecha', style: _headerStyle()),
          ),
          SizedBox(width: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            height: 20,
            child: Text('Detalles', style: _headerStyle()),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Usuario', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Módulo', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Tipo', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Acción', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Fecha', style: _headerStyle()),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: 25,
            child: Text('Detalles', style: _headerStyle()),
          ),
        ],
      ),
    );
  }

// Widget para los filtros
  Widget _buildFilters(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            children: [
              SizedBox(height: 15),
              UserTextFormField(
                  text: 'Usuario',
                  onChanged: (value) {
                    setState(() {
                      _controller.searchUser = value;
                    });
                  },
                  controller: _usercontroller),
              SizedBox(height: 15),
              DatePicker(isMobile, context),
              SizedBox(height: 20),
              FilterButton(
                onPressed: () => _applyFilters(),
              )
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserTextFormField(
                  text: 'Usuario',
                  onChanged: (value) {
                    setState(() {
                      _controller.searchUser = value;
                    });
                  },
                  controller: _usercontroller),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              ModulesDropdown(),
              // SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              TypeDropdown(),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              ActionDropdown(),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              DatePicker(isMobile, context),
              SizedBox(width: MediaQuery.of(context).size.width * 0.015),
              FilterButton(onPressed: _applyFilters),
            ],
          );
  }

  Row DatePicker(bool isMobile, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botón "Desde"
        DatePickerButton(
          label: 'Desde',
          selectedDate: _controller.startDateFilter,
          onDateSelected: (date) {
            setState(() {
              _controller.startDateFilter = date;
            });
          },
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          includeTime: true,
        ),

        SizedBox(width: 10),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        SizedBox(width: 10),
        DatePickerButton(
            label: 'Hasta',
            selectedDate: _controller.endDateFilter,
            onDateSelected: (date) {
              setState(() {
                _controller.endDateFilter = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  23,
                  59,
                  59,
                );
              });
            },
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
      ],
    );
  }

  Widget ModulesDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.15,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Módulo:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 15),
          DropdownButton<String>(
            value: selectedModuleFilter,
            onChanged: (newValue) {
              setState(() {
                selectedModuleFilter = newValue!;
              });
            },
            items: [
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
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
    );
  }

  Widget ActionDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.16,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Acción:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 15),
          DropdownButton(
            value: selectedActionFilter,
            onChanged: (newValue) {
              setState(() {
                selectedActionFilter = newValue!;
              });
            },
            items: [
              'Todos',
              'Crear',
              'Actualizar',
              'Eliminar',
              'Activar',
              'Desactivar',
              'Iniciar sesión',
              'Cerrar sesión',
              'Cambiar contraseña',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
    );
  }

  Widget TypeDropdown() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.10,
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tipo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 15),
          DropdownButton(
            value: selectedTypeFilter,
            onChanged: (String? newValue) {
              setState(() {
                selectedTypeFilter = newValue!;
              });
            },
            items: [
              'Todos',
              'Success',
              'Error',
              'Warning',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          ),
        ],
      ),
    );
  }

// Widget para la lista de logs
  Widget _buildLogsList() {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final filteredLogs =
        _controller.filteredLogs; // Obtener logs del controlador

    return Column(
      children: [
        if (filteredLogs.isEmpty)
          Center(child: Text('No hay logs disponibles'))
        else
          ...filteredLogs.map((log) {
            // Validar y formatear la fecha
            String formattedDate = 'Fecha no disponible';
            if (log['date'] != null) {
              try {
                DateTime parsedDate =
                    DateFormat('yyyy-MM-dd hh:mm a').parse(log['date']);
                formattedDate =
                    DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
              } catch (e) {
                formattedDate = 'Formato de fecha inválido';
              }
            }

            return Column(
              children: [
                isMobile
                    ? Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              SizedBox(
                                child: Text(log['user']),
                                width: MediaQuery.of(context).size.width * 0.25,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(formattedDate),
                                width: MediaQuery.of(context).size.width * 0.35,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(width: isMobile ? 20 : 0),
                              SizedBox(
                                child: Text(log['details']),
                                width: MediaQuery.of(context).size.width * 0.30,
                                height: isMobile ? 20 : 25,
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03),
                              SizedBox(
                                child: Text(log['user']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(log['module']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(log['type']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(log['action']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(log['date']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                              SizedBox(
                                child: Text(log['details']),
                                width: MediaQuery.of(context).size.width * 0.15,
                                height: isMobile ? 20 : 25,
                              ),
                            ],
                          ),
                          Divider(),
                        ],
                      )
              ],
            );
          }).toList(),
      ],
    );
  }

  void _applyFilters() {
    setState(() {});
  }
}

// Estilo para encabezados
TextStyle _headerStyle() {
  return TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.red[900],
    fontSize: 16,
  );
}
