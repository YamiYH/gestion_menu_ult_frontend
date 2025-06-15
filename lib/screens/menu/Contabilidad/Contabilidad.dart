import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/menu/MenuController.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Contabilidad/AprobarMenu.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../../widgets/DatePickerButton.dart';
import '../../../widgets/MenuCardWithAction.dart';
import '../../../widgets/Pagination.dart';

class Contabilidad extends StatefulWidget {
  @override
  State<Contabilidad> createState() => _ContabilidadState();
}

class _ContabilidadState extends State<Contabilidad> {
  // Variables para almacenar las fechas seleccionadas
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now().add(Duration(days: 30));
  MenuEntityController _controller = MenuEntityController();

  // Lista simulada de informes agrupados por fecha
  List<MenuEntity> _menuList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
  }

  Future<void> _fetchMenus() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> filters = {
        "status": "Propuesto",
        if (startDate != null)
          "startDate": startDate!.toIso8601String().split('T').first,
        if (endDate != null)
          "endDate": endDate!.toIso8601String().split('T').first,
      };
      final menuListFiltered = await _controller.fetchMenu(filters: filters);
      if (mounted) {
        setState(() {
          _menuList = menuListFiltered;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar los menús: $e'), backgroundColor: Colors.red),
        );
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
    bool isMobile = MediaQuery
        .of(context)
        .size
        .width < 600;

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
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildRow(),
                ],
              ),
            ),
            _isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ) :Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _menuList.length,
                itemBuilder: (context, index) {
                  final menu = _menuList[index];
                  return MenuCardWithAction(context: context,
                      actionText: 'Revisar',
                      onPressed: () {
                        Navigator.push(context, createFadeRoute(AprobarMenu(menu: menu)));
                      }
                      ,menu: menu);
                },
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: Pagination(
          currentPage: _controller.currentPage,
          totalPages: _controller.totalPages,
          itemsPerPage: _controller.pageSize,
          onPageChanged: (newPage) {
            if (_controller.currentPage != newPage) {
              _controller.currentPage = newPage;
              _fetchMenus();
            }
          },
          onItemsPerPageChanged: (newSize) {
            if (_controller.pageSize != newSize) {
              _controller.pageSize = newSize;
              _controller.currentPage = 0;
              _fetchMenus();
            }
          },
        )
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
              _fetchMenus();
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30))
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
              _fetchMenus();
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30))
        ),
      ],
    );
  }
}
