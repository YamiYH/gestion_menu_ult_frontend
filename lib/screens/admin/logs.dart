import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/buscar.dart';
import 'package:gestion_menu_ult_frontend/widgets/dropdownfield.dart';
import 'package:gestion_menu_ult_frontend/widgets/fecha.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  _LogsScreenState createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  // Variables para los filtros
  String? searchUser; // Usuario ingresado en el TextFormField
  String? selectedTypeFilter; // Tipo de log seleccionado para filtrar
  DateTime? startDate;
  DateTime? endDate;
  DateTime? startDateFilter; // Fecha inicial para filtrar
  DateTime? endDateFilter; // Fecha final para filtrar

  // Lista simulada de logs
  final List<Map<String, dynamic>> _allLogs = [
    {
      'type': 'login',
      'message': 'Inicio de sesión exitoso',
      'user': 'admin',
      'date': '2023-10-01 10:15 AM',
    },
    {
      'type': 'error',
      'message': 'Error al acceder a la base de datos',
      'user': 'system',
      'date': '2023-10-01 11:30 AM',
    },
    {
      'type': 'logout',
      'message': 'Cierre de sesión',
      'user': 'admin',
      'date': '2023-10-01 12:00 PM',
    },
    {
      'type': 'warning',
      'message': 'Intento fallido de inicio de sesión',
      'user': 'guest',
      'date': '2023-10-01 01:45 PM',
    },
  ];

  // Lista de logs filtrados
  List<Map<String, dynamic>> _filteredLogs = [];

  // Función para aplicar filtros
  void _applyFilters() {
    setState(() {
      _filteredLogs = _allLogs.where((log) {
        bool matchesUser = searchUser == null ||
            log['user'].toLowerCase().contains(searchUser!.toLowerCase());
        bool matchesDate = (startDateFilter == null || endDateFilter == null) ||
            (DateTime.parse(log['date']).isAfter(startDateFilter!) &&
                DateTime.parse(log['date']).isBefore(endDateFilter!));
        bool matchesType =
            selectedTypeFilter == null || log['type'] == selectedTypeFilter;

        return matchesUser && matchesDate && matchesType;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredLogs = _allLogs; // Inicialmente mostrar todos los logs
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Registros',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isMobile ? FontWeight.bold : FontWeight.normal,
            fontSize: isMobile ? 20 : 25,
          ),
        ),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtros responsivos
              isMobile
                  ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: isMobile
                                ? screenWidth * 0.8
                                : screenWidth * 0.4,
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Buscar Usuario',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon:
                                    Icon(Icons.person, color: Colors.red[900]),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchUser = value;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: isMobile
                                ? screenWidth * 0.8
                                : screenWidth * 0.4,
                            child: DropDownField(),
                          ),
                          SizedBox(height: 15),
                          SizedBox(
                            width: isMobile
                                ? screenWidth * 0.8
                                : screenWidth * 0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DatePickerButton(
                                  label: 'Desde',
                                  selectedDate: startDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      startDate = date;
                                    });
                                  },
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward,
                                    color: Colors.red[900]),
                                SizedBox(width: 10),
                                DatePickerButton(
                                  label: 'Hasta',
                                  selectedDate: endDate,
                                  onDateSelected: (date) {
                                    setState(() {
                                      endDate = date;
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          SearchButton(
                            onPressed: _applyFilters,
                          )
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Buscar Usuario',
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10.0)),
                              suffixIcon:
                                  Icon(Icons.person, color: Colors.red[900]),
                            ),
                            onChanged: (value) {
                              setState(() {
                                searchUser = value;
                              });
                            },
                          ),
                        ),

                        SizedBox(width: 15),

                        // Selector de tipo de log
                        SizedBox(
                          width: screenWidth * 0.2,
                          child: DropDownField(),
                        ),

                        SizedBox(width: 15),

                        DatePickerButton(
                          label: 'Desde',
                          selectedDate: startDate,
                          onDateSelected: (date) {
                            setState(() {
                              startDate = date;
                            });
                          },
                        ),

                        SizedBox(width: 3),
                        Icon(Icons.arrow_forward, color: Colors.red[900]),
                        SizedBox(width: 3),

                        DatePickerButton(
                          label: 'Hasta',
                          selectedDate: endDate,
                          onDateSelected: (date) {
                            setState(() {
                              endDate = date;
                            });
                          },
                        ),

                        SizedBox(width: 15),
                        SearchButton(onPressed: _applyFilters),
                      ],
                    ),
              SizedBox(height: 50),

              // Encabezados de las columnas
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Usuario',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Fecha',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Actividad',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Divider(),

              // Lista de logs filtrados
              if (_filteredLogs.isEmpty)
                Center(child: Text('No hay logs disponibles'))
              else
                ..._filteredLogs.map((log) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(log['user']),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(log['date']),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(log['message']),
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
