import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ComedorAcceso.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/InformesVentas.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/MenuVenta.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../providers/ProfileProvider.dart';
import '../../../widgets/ProtectedWidget.dart';

class ModulosVenta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final userPermissions =
        Provider.of<ProfileProvider>(context).userProfile?.permissions ?? [];

    Future<void> requestCameraPermission() async {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        // Maneja el caso en que el usuario deniegue los permisos
        print('Permiso de cámara denegado');
      }
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Ventas'),
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
                      children: _buildModulos(context, isMobile,
                          requestCameraPermission, userPermissions),
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
                    itemCount: _buildModulos(context, isMobile,
                            requestCameraPermission, userPermissions)
                        .length,
                    itemBuilder: (context, index) {
                      return _buildModulos(context, isMobile,
                              requestCameraPermission, userPermissions)
                          .elementAt(index);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // Método para construir las Cards de los módulos
  List<Widget> _buildModulos(BuildContext context, bool isMobile,
      requestCameraPermission, List<String> userPermissions) {
    return [
      ProtectedWidget(
        requiredPermission: 'Caja',
        child: Container(
          padding: EdgeInsets.all(5),
          child: BuildCard(
            title: 'Iniciar Ventas',
            icon: Icons.attach_money,
            isEnabled: userPermissions.contains('Caja'),
            onTap: () {
              Navigator.push(context, createFadeRoute(MenuVentas()));
            },
          ),
        ),
      ),
      ProtectedWidget(
        requiredPermission: 'Reportes',
        child: Container(
          padding: EdgeInsets.all(5),
          child: BuildCard(
            title: 'Informes de Ventas',
            icon: Icons.bar_chart,
            isEnabled: userPermissions.contains('Reportes'),
            onTap: () {
              Navigator.push(context, createFadeRoute(InformesVentas()));
            },
          ),
        ),
      ),
      if (isMobile)
        ProtectedWidget(
          requiredPermission: 'Caja',
          child: Container(
            padding: EdgeInsets.all(5),
            child: BuildCard(
              title: 'Acceso al Comedor',
              icon: Icons.qr_code,
              isEnabled: userPermissions.contains('Caja'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComedorAcceso()),
                );
              },
            ),
          ),
        )
    ];
  }
}
