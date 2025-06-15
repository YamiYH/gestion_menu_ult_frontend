import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Contabilidad/Contabilidad.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Menu/MenuPropuesta.dart';
import 'package:gestion_menu_ult_frontend/widgets/CardStyle.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:provider/provider.dart';

import '../../providers/ProfileProvider.dart';
import '../../widgets/ProtectedWidget.dart';
import 'Inventario/Inventario.dart';
import 'LibroDeRecetas/LibroRecetas.dart';
import 'Menu/MenuConfig.dart';
import 'Ventas/ModulosVenta.dart';

class ModulosMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final userPermissions =
        Provider.of<ProfileProvider>(context).userProfile?.permissions ?? [];

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
                      children:
                          _buildModulos(context, isMobile, userPermissions),
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
                    itemCount: _buildModulos(context, isMobile, userPermissions)
                        .length,
                    itemBuilder: (context, index) {
                      return _buildModulos(context, isMobile, userPermissions)
                          .elementAt(index);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // Método para construir las Cards de los módulos
  List<Widget> _buildModulos(
      BuildContext context, bool isMobile, List<String> userPermissions) {
    return [
      ProtectedWidget(
        requiredPermission: 'Inventario',
        child: CardStyle(
            title: 'Inventario',
            icon: Icons.inventory,
            onTap: () {
              Navigator.push(context, createFadeRoute(Inventario()));
            },
            isEnabled: userPermissions.contains('Inventario')),
      ),
      ProtectedWidget(
          requiredPermission: 'Propuestas',
          child: CardStyle(
              title: 'Propuestas de Menú',
              icon: Icons.fastfood_sharp,
              onTap: () {
                Navigator.push(context, createFadeRoute(MenuPropuesta()));
              },
              isEnabled: userPermissions.contains('Propuestas'))),
      ProtectedWidget(
          requiredPermission: 'Ventas',
          child: CardStyle(
              title: 'Ventas',
              icon: Icons.attach_money,
              onTap: () {
                Navigator.push(context, createFadeRoute(ModulosVenta()));
              },
              isEnabled: userPermissions.contains('Ventas'))),
      ProtectedWidget(
          requiredPermission: 'Recetas',
          child: CardStyle(
            title: 'Libro de Recetas',
            icon: Icons.book,
            onTap: () {
              Navigator.push(context, createFadeRoute(LibroRecetas()));
            },
            isEnabled: userPermissions.contains('Recetas'),
          )),
      ProtectedWidget(
          requiredPermission: 'Contabilidad',
          child: CardStyle(
              title: 'Contabilidad',
              icon: Icons.calculate_outlined,
              onTap: () {
                Navigator.push(context, createFadeRoute(Contabilidad()));
              },
              isEnabled: userPermissions.contains('Contabilidad'))),
      ProtectedWidget(
          requiredPermission: 'Configuraciones',
          child: CardStyle(
            title: 'Configuración',
            icon: Icons.settings,
            onTap: () {
              Navigator.push(context, createFadeRoute(MenuConfig()));
            },
            isEnabled: userPermissions.contains('Configuraciones'),
          )),
    ];
  }
}
