import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Contabilidad/AprobarMenu.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../../widgets/Button.dart';
import '../../../widgets/DatePickerButton.dart';
import '../../../widgets/SmallButton.dart';

class Contabilidad extends StatefulWidget {
  @override
  State<Contabilidad> createState() => _ContabilidadState();
}

class _ContabilidadState extends State<Contabilidad> {
  // Variables para almacenar las fechas seleccionadas
  DateTime? startDate;
  DateTime? endDate;

  // Lista simulada de informes agrupados por fecha
  final List<Map<String, dynamic>> propuestas = [
    {
      'fecha': '2025-03-01',
      'propuestas': [
        {
          'nombre': 'Almuerzo',
        },
      ]
    },
  ];

  List<Map<String, dynamic>> _filteredPropuestas = [];

  @override
  void initState() {
    super.initState();
    // Inicializa la lista filtrada con todos las propuestas al principio
    _filteredPropuestas = List.from(propuestas);
  }

  void _applyDateFilters() {
    setState(() {
      _filteredPropuestas = propuestas.where((propuesta) {
        final fechaString = propuesta['fecha'] as String?;
        // Ignorar propuestas sin fecha o con formato inválido
        if (fechaString == null) return false;
        final reportDate = DateTime.tryParse(fechaString);
        if (reportDate == null) return false;

        // Comprobar si la fecha está después o es igual a startDate (si existe)
        final bool afterStartDate = startDate == null ||
            reportDate.isAtSameMomentAs(startDate!) ||
            reportDate.isAfter(startDate!);

        final bool beforeEndDate;
        if (endDate == null) {
          beforeEndDate = true;
        } else {
          // Compara si la fecha de la propuesta es anterior al día siguiente de endDate
          final nextDayOfEndDate =
              DateTime(endDate!.year, endDate!.month, endDate!.day + 1);
          beforeEndDate = reportDate.isBefore(nextDayOfEndDate);
        }

        // El informe se incluye si cumple ambas condiciones
        return afterStartDate && beforeEndDate;
      }).toList();
    });
    // Opcional: Imprimir para depurar
    print(
        'Filtro aplicado. Start: $startDate, End: $endDate. Resultados: ${_filteredPropuestas.length}');
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Contabilidad'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: isMobile
                  ? Column(
                      children: [
                        buildRow(),
                        SizedBox(height: 15),
                        Button(
                          onPressed: _applyDateFilters,
                          icon: Icons.search,
                          text: 'Buscar',
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildRow(),
                        SizedBox(width: 30),
                        Button(
                          onPressed: _applyDateFilters,
                          icon: Icons.search,
                          text: 'Buscar',
                        )
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _filteredPropuestas.length,
                itemBuilder: (context, index) {
                  final informe = _filteredPropuestas[index];
                  return _buildInformeCard(informe);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DatePickerButton(
          label: 'Desde',
          selectedDate: startDate,
          onDateSelected: (date) {
            setState(() {
              startDate = date;
            });
          },
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
        SizedBox(width: 10),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        SizedBox(width: 10),
        DatePickerButton(
          label: 'Hasta',
          selectedDate: endDate,
          onDateSelected: (date) {
            setState(() {
              endDate = date;
            });
          },
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  // Widget para construir una Card de informe
  Widget _buildInformeCard(Map<String, dynamic> propuesta) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final String fecha = propuesta['fecha'];
    final List<dynamic> listaPropuestas = propuesta['propuestas'];
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: isMobile ? EdgeInsets.all(10.0) : EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha del informe
                Text(
                  isMobile ? 'Fecha: $fecha: ' : 'Fecha: $fecha :   ',
                  style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800]),
                ),
                SizedBox(height: 5),

                ...listaPropuestas.map((item) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['nombre'],
                        style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),
            SmallButton(
                onPressed: () {
                  Navigator.push(context, createFadeRoute(AprobarMenu()));
                },
                text: 'Revisar',
                size: Size(
                  isMobile ? 95 : 120,
                  40,
                ))
          ],
        ),
      ),
    );
  }
}
