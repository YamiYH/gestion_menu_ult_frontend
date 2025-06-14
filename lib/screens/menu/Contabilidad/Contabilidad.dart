import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/menu/MenuController.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
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
  MenuEntityController controller = MenuEntityController();

  // Lista simulada de informes agrupados por fecha
  List<MenuEntity> _menuList = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    Map<String, String> filters = {
      "status": "Propuesto"
    };
    final menuListFiltered = await controller.fetchMenu(filters: filters);
    setState(() {
      _menuList = menuListFiltered;
    });
  }

  void _applyDateFilters() async {
    Map<String, String> filters = {
      "startDate" : startDate!.toIso8601String().split('T').first,
      "endDate": endDate!.toIso8601String().split('T').first,
      "status": "Propuesto"
    };
    final menuListFiltered = await controller.fetchMenu(filters: filters);
    setState(() {
      _menuList = menuListFiltered;
    });
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
                itemCount: _menuList.length,
                itemBuilder: (context, index) {
                  final menu = _menuList[index];
                  return _buildInformeCard(menu);
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
          selectedDate: DateTime.now(),
          onDateSelected: (date) {
            setState(() {
              startDate = date;
            });
            _applyDateFilters();
          },
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(Duration(days: 30))
        ),
        SizedBox(width: 10),
        Icon(Icons.arrow_forward, color: Colors.red[900]),
        SizedBox(width: 10),
        DatePickerButton(
          label: 'Hasta',
          selectedDate: DateTime.now().add(Duration(days: 30)),
          onDateSelected: (date) {
            setState(() {
              endDate = date;
            });
            _applyDateFilters();
          },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30))
        ),
      ],
    );
  }

  // Widget para construir una Card de informe
  Widget _buildInformeCard(MenuEntity menu) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final String fecha = menu.date;
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
                  isMobile ? 'Fecha: $fecha: ' : 'Fecha: $fecha : ${menu.category} ',
                  style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800]),
                ),
                SizedBox(height: 5),
              ],
            ),
            SmallButton(
                onPressed: () {
                  Navigator.push(context, createFadeRoute(AprobarMenu(menu: menu)));
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
