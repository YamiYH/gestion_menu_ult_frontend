import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/ModulosAdmin.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/ModulosMenu.dart';
import 'package:gestion_menu_ult_frontend/screens/ticket/GestionarTicket.dart';
import 'package:gestion_menu_ult_frontend/widgets/ProtectedWidget.dart';
import 'package:provider/provider.dart';

import '../../providers/ProfileProvider.dart';
import '../../routes/PageRouteBuilder.dart';
import '../../widgets/BuildCard.dart';
import '../../widgets/CustomAppbar.dart';

class Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    final userPermissions =
        Provider.of<ProfileProvider>(context).userProfile?.permissions ?? [];

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _buildWidgetList(context, userPermissions),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing:
                          MediaQuery.of(context).size.width * 0.03,
                      mainAxisSpacing: MediaQuery.of(context).size.width * 0.03,
                      childAspectRatio: 2.5,
                    ),
                    itemCount:
                        _buildWidgetList(context, userPermissions).length,
                    itemBuilder: (context, index) {
                      return _buildWidgetList(context, userPermissions)
                          .elementAt(index);
                    },
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildWidgetList(
      BuildContext context, List<String> userPermissions) {
    return [
      ProtectedWidget(
        requiredPermission: 'Menu',
        child: Container(
          padding: EdgeInsets.all(5),
          child: BuildCard(
            title: 'Menú',
            icon: Icons.restaurant_menu,
            isEnabled: userPermissions.contains('Menu'),
            onTap: () {
              Navigator.push(context, createFadeRoute(ModulosMenu()));
            },
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Tickets',
          icon: Icons.qr_code,
          onTap: () {
            Navigator.push(context, createFadeRoute(GestionarTicket()));
          },
        ),
      ),
      ProtectedWidget(
        requiredPermission: 'Administrador',
        child: Container(
          padding: EdgeInsets.all(5),
          child: BuildCard(
            title: 'Administración',
            icon: Icons.admin_panel_settings,
            isEnabled: userPermissions.contains('Administrador'),
            onTap: () {
              Navigator.push(context, createFadeRoute(ModulosAdmin()));
            },
          ),
        ),
      ),
    ];
  }
}
