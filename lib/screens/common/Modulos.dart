import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/Build_Card.dart';

import '../inventario/Inventario.dart';
import '../security/Logs.dart';

class ModulosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Módulos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: isMobile ? FontWeight.bold : FontWeight.normal,
            fontSize: isMobile ? 18 : 25,
          ),
        ),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 60),
          child: isMobile
              ? Center(
                  child: Column(
                    children: _buildModulos(context, isMobile),
                  ),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 40,
                    mainAxisSpacing: 40,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _buildModulos(context, isMobile).length,
                  itemBuilder: (context, index) {
                    return _buildModulos(context, isMobile).elementAt(index);
                  },
                ),
        ),
      ),
    );
  }

  // Método para construir las Cards de los módulos
  List<Widget> _buildModulos(BuildContext context, bool isMobile) {
    return [
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GestionarAlmacen(),
              ),
            );
          },
          title: 'Inventario',
          icon: Icons.inventory,
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          onTap: () {
            // Acción para el módulo de Menú
            print('Módulo de Menú seleccionado');
          },
          title: 'Menú',
          icon: Icons.restaurant_menu,
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogsScreen(),
              ),
            );
          },
          title: 'Ventas',
          icon: Icons.attach_money,
        ),
      ),
    ];
  }
}
