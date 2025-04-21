import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Config.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Payment.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Roles.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';

import '../../widgets/CustomAppbar.dart';
import 'Logs.dart';
import 'Users.dart';

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
                //opacity: 0.9,
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
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Usuarios',
          icon: Icons.people,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Users(),
              ),
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Roles',
          icon: Icons.admin_panel_settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Roles(),
              ),
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Pasarelas de Pago',
          icon: Icons.payment,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Payment(),
              ),
            );
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Auditoría',
          icon: Icons.security,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Logs(),
              ),
            );
          },
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
                builder: (context) => Config(),
              ),
            );
          },
        ),
      ),
    ];
  }
}
