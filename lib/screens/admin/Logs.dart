import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../controllers/LogsController.dart';
import '../../widgets/Button.dart';

class Logs extends StatefulWidget {
  const Logs({super.key});

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  final LogsController _controller = LogsController();

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(context, isMobile),
              SizedBox(height: 50),
              // Encabezados de las columnas
              _buildHeaders(),
              const Divider(),
              // Lista de logs filtrados
              _buildLogsList(),

              // Lista de logs filtrados
            ],
          ),
        ),
      ),
    );
  }

  // Widget para los encabezados
  Widget _buildHeaders() {
    return const Row(
      children: [
        Expanded(
            flex: 2,
            child:
                Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
            flex: 2,
            child:
                Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
            flex: 3,
            child: Text('Actividad',
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

// Widget para los filtros
  Widget _buildFilters(BuildContext context, bool isMobile) {
    return isMobile
        ? Column(
            children: [
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) {
                  setState(() {
                    _controller.searchUser = value;
                  });
                },
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _controller.selectedTypeFilter,
                decoration: InputDecoration(
                  labelText: 'Actividad',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (newValue) {
                  setState(() {
                    _controller.selectedTypeFilter = newValue;
                  });
                },
                items: ['login', 'logout', 'error', 'warning', 'info', 'all']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(isMobile ? 150 : 170, isMobile ? 40 : 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red[900]!, width: 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 20,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _controller.startDateFilter = pickedDate;
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.red[900]),
                    label: Text(
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        color: Colors.red[900],
                      ),
                      _controller.startDateFilter == null
                          ? 'Desde'
                          : DateFormat('yyyy-MM-dd')
                              .format(_controller.startDateFilter!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.red[900]),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(isMobile ? 150 : 170, isMobile ? 40 : 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red[900]!, width: 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 20,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          // Ajustar la fecha final al último segundo del día
                          _controller.endDateFilter = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            23,
                            59,
                            59,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.red[900]),
                    label: Text(
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        color: Colors.red[900],
                      ),
                      _controller.endDateFilter == null
                          ? 'Hasta'
                          : DateFormat('yyyy-MM-dd')
                              .format(_controller.endDateFilter!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Button(
                  onPressed: () => setState(() {}),
                  text: 'BUSCAR',
                  icon: Icons.search)
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //SizedBox(width: 45),
              SizedBox(
                width: 300,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _controller.searchUser = value;
                    });
                  },
                ),
              ),
              SizedBox(width: 20),
              SizedBox(
                width: 300,
                child: DropdownButtonFormField<String>(
                  value: _controller.selectedTypeFilter,
                  decoration: InputDecoration(
                    labelText: 'Actividad',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      _controller.selectedTypeFilter = newValue;
                    });
                  },
                  items: ['login', 'logout', 'error', 'warning', 'info', 'all']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
              SizedBox(width: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Reemplazar DatePickerButton con ElevatedButton
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(isMobile ? 150 : 170, isMobile ? 40 : 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red[900]!, width: 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 20,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              primaryColor: Colors.red[900],
                              colorScheme: ColorScheme.light(
                                primary: Colors.red[400]!,
                              ),
                              dialogBackgroundColor: Colors.white,
                              textTheme: TextTheme(
                                headlineMedium: TextStyle(fontSize: 16),
                                bodyLarge: TextStyle(fontSize: 14),
                                bodyMedium: TextStyle(fontSize: 12),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _controller.startDateFilter =
                              pickedDate; // Fecha con hora 00:00:00
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.red[900]),
                    label: Text(
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        color: Colors.red[900],
                      ),
                      _controller.startDateFilter == null
                          ? 'Desde'
                          : DateFormat('yyyy-MM-dd')
                              .format(_controller.startDateFilter!),
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.red[900]),
                  SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(isMobile ? 150 : 170, isMobile ? 40 : 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.red[900]!, width: 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 20,
                        vertical: isMobile ? 8 : 12,
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(Duration(days: 30)),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              primaryColor: Colors.red[900],
                              colorScheme: ColorScheme.light(
                                primary: Colors.red[400]!,
                              ),
                              dialogBackgroundColor: Colors.white,
                              textTheme: TextTheme(
                                headlineMedium: TextStyle(fontSize: 16),
                                bodyLarge: TextStyle(fontSize: 14),
                                bodyMedium: TextStyle(fontSize: 12),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          // Ajustar la fecha final al último segundo del día
                          _controller.endDateFilter = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            23,
                            59,
                            59,
                          );
                        });
                      }
                    },
                    icon: Icon(Icons.calendar_today, color: Colors.red[900]),
                    label: Text(
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
                        color: Colors.red[900],
                      ),
                      _controller.endDateFilter == null
                          ? 'Hasta'
                          : DateFormat('yyyy-MM-dd')
                              .format(_controller.endDateFilter!),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20),
              Button(
                  onPressed: _applyFilters, text: 'BUSCAR', icon: Icons.search)
            ],
          );
  }

// Widget para la lista de logs
  Widget _buildLogsList() {
    final filteredLogs =
        _controller.filteredLogs; // Obtener logs del controlador
    return Column(
      children: [
        if (filteredLogs.isEmpty)
          Center(child: Text('No hay logs disponibles'))
        else
          ...filteredLogs.map((log) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(flex: 2, child: Text(log['user'])),
                    Expanded(flex: 2, child: Text(log['date'])),
                    Expanded(flex: 3, child: Text(log['message'])),
                  ],
                ),
                const Divider(),
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
