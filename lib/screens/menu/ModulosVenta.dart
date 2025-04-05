import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/InformesVentas.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class ModulosVenta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Menú'),
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
                builder: (context) => Ventas(),
              ),
            );
          },
          title: 'Iniciar Ventas',
          icon: Icons.attach_money,
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InformesVentas(),
              ),
            );
          },
          title: 'Informes de Ventas',
          icon: Icons.bar_chart,
        ),
      ),
    ];
  }
}
