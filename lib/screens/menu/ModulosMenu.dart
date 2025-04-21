import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/MenuPropuesta.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import 'Inventario.dart';
import 'LibroRecetas.dart';
import 'MenuConfig.dart';
import 'Ventas/ModulosVenta.dart';

class ModulosMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: CustomAppBar(title: 'Menú'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                //opacity: 0.9,
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: SingleChildScrollView(
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
                builder: (context) => Inventario(),
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPropuesta(),
              ),
            );
          },
          title: 'Propuestas de Menú',
          icon: Icons.fastfood_sharp,
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ModulosVenta(),
              ),
            );
          },
          title: 'Ventas',
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
                builder: (context) => LibroRecetas(),
              ),
            );
          },
          title: 'Libro de Recetas',
          icon: Icons.book,
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Configuración',
          icon: Icons.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuConfig(),
              ),
            );
          },
        ),
      ),
    ];
  }
}
