import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/logs.dart';
import 'package:gestion_menu_ult_frontend/screens/almacen/inventario.dart';

class ModulosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600; // Define si la pantalla es móvil

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Módulos',
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
          child: isMobile
              ? Center(
                  child: Column(
                    children: _buildModulos(context, isMobile),
                  ),
                )
              : Container(
                  padding: EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _buildModulos(context, isMobile),
                  ),
                ),
        ),
      ),
    );
  }

  // Método para construir las Cards de los módulos
  List<Widget> _buildModulos(BuildContext context, bool isMobile) {
    return [
      _buildModuleCard(
        'Administración',
        Icons.admin_panel_settings,
        isMobile,
        onTap: () {},
      ),
      _buildModuleCard(
        'Almacén',
        Icons.inventory,
        isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GestionarAlmacen(),
            ),
          );
        },
      ),
      _buildModuleCard(
        'Menú',
        Icons.restaurant_menu,
        isMobile,
        onTap: () {
          // Acción para el módulo de Menú
          print('Módulo de Menú seleccionado');
        },
      ),
      _buildModuleCard(
        'Seguridad',
        Icons.security,
        isMobile,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogsScreen(),
            ),
          );
        },
      ),
    ];
  }

  // Método para construir una Card de módulo
  Widget _buildModuleCard(String title, IconData icon, bool isMobile,
      {required VoidCallback onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Container(
            width: isMobile ? 180 : 300,
            height: isMobile ? 150 : 240,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: isMobile ? 40 : 60,
                  color: Colors.red[900],
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
