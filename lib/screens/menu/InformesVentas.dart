import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/Button.dart';
import '../../widgets/DatePickerButton.dart';
import '../../widgets/Pagination.dart';

class InformesVentas extends StatefulWidget {
  @override
  State<InformesVentas> createState() => _InformesVentasState();
}

class _InformesVentasState extends State<InformesVentas> {
  // Variables para almacenar las fechas seleccionadas
  DateTime? startDate;
  DateTime? endDate;

  // Lista simulada de informes agrupados por fecha
  final List<Map<String, dynamic>> informes = [
    {
      'fecha': '2023-10-01',
      'informes': [
        {
          'nombre': 'Informe Contabilidad',
          'archivo': 'contabilidad_2023-10-01.pdf'
        },
        {'nombre': 'Informe Alimentos', 'archivo': 'alimentos_2023-10-01.pdf'}
      ]
    },
    {
      'fecha': '2023-10-02',
      'informes': [
        {
          'nombre': 'Informe Contabilidad',
          'archivo': 'contabilidad_2023-10-02.pdf'
        },
        {'nombre': 'Informe Alimentos', 'archivo': 'alimentos_2023-10-02.pdf'}
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Informes de Ventas'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila con DatePickerButton y Botón Buscar
            Padding(
              padding: EdgeInsets.all(16.0),
              child: isMobile
                  ? Column(
                      children: [
                        buildRow(),
                        SizedBox(height: 15),
                        Button(
                          onPressed: () {},
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
                          onPressed: () {},
                          icon: Icons.search,
                          text: 'Buscar',
                        )
                      ],
                    ),
            ),

            // Lista de Cards con los informes
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: informes.length,
                itemBuilder: (context, index) {
                  final informe = informes[index];
                  return _buildInformeCard(informe);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Pagination(
        items: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        itemsPerPage: 10,
        itemBuilder: (context, item) {
          return ListTile(
            title: Text(item as String),
          );
        },
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
  Widget _buildInformeCard(Map<String, dynamic> informe) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final String fecha = informe['fecha'];
    final List<dynamic> listaInformes = informe['informes'];
    return Card(
      //margin: EdgeInsets.only(bottom: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha del informe
            Text(
              'Fecha: $fecha',
              style: TextStyle(
                  fontSize: isMobile ? 17 : 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700]),
            ),
            SizedBox(height: 5),

// Informes individuales
            ...listaInformes.map((item) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
// Nombre del informe
                  Text(
                    item['nombre'],
                    style: TextStyle(
                        fontSize: isMobile ? 16 : 15,
                        fontWeight: FontWeight.w500),
                  ),
// Ícono de descarga
                  IconButton(
                    icon:
                        Icon(Icons.download, color: Colors.red[900], size: 25),
                    onPressed: () {
// Simular la descarga del archivo PDF
                      print('Descargando ${item['archivo']}...');
                    },
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
