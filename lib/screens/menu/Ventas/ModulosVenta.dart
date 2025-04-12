import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/ComedorAcceso.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/InformesVentas.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/Ventas.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:permission_handler/permission_handler.dart';

class ModulosVenta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

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
                image: AssetImage('assets/img/background3.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 60),
            child: isMobile
                ? Center(
                    child: Column(
                      children: _buildModulos(
                          context, isMobile, requestCameraPermission),
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
                    itemCount: _buildModulos(
                            context, isMobile, requestCameraPermission)
                        .length,
                    itemBuilder: (context, index) {
                      return _buildModulos(
                              context, isMobile, requestCameraPermission)
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
      BuildContext context, bool isMobile, requestCameraPermission) {
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
      if (isMobile)
        Container(
          padding: EdgeInsets.all(5),
          child: BuildCard(
            onTap: () async {
              await requestCameraPermission();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ComedorAcceso()),
              );
            },
            title: 'Acceso al Comedor',
            icon: Icons.qr_code,
          ),
        )
    ];
  }
}
