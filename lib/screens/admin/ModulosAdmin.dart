import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Configuracion/Config.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Rol/Roles.dart';

import '../../widgets/CardStyle.dart';
import '../../widgets/CustomAppbar.dart';
import 'Auditoria/Logs.dart';
import 'Usuario/Users.dart';

class ModulosAdmin extends StatefulWidget {
  const ModulosAdmin({super.key});

  @override
  _ModulosAdminState createState() => _ModulosAdminState();
}

class _ModulosAdminState extends State<ModulosAdmin> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Administración',
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 60),
          child: isMobile
              ? SingleChildScrollView(
                  child: Center(
                  child: Column(
                    children: _buildAdmin(),
                  ),
                ))
              : SingleChildScrollView(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 40,
                      mainAxisSpacing: 40,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _buildAdmin().length,
                    itemBuilder: (context, index) {
                      return _buildAdmin().elementAt(index);
                    },
                  ),
                ),
        ),
      ),
    );
  }

  // Método para construir las Cards de administracion
  List<Widget> _buildAdmin() {
    return [
      CardStyle(
          icon: Icons.people,
          title: 'Usuarios',
          onTap: () {
            Navigator.push(context, createFadeRoute(Users()));
          }),
      CardStyle(
        icon: Icons.admin_panel_settings,
        title: 'Roles',
        onTap: () {
          Navigator.push(context, createFadeRoute(Roles()));
        },
      ),
      CardStyle(
        icon: Icons.security,
        title: 'Auditoría',
        onTap: () {
          Navigator.push(context, createFadeRoute(Logs()));
        },
      ),
      CardStyle(
        icon: Icons.settings,
        title: 'Configuración',
        onTap: () {
          Navigator.push(context, createFadeRoute(Config()));
        },
      )
    ];
  }
}
