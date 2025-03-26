import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/ModulosMenu.dart';
import 'package:gestion_menu_ult_frontend/screens/ticket/Gestionar_Ticket.dart';

import '../../widgets/BuildCard.dart';
import '../../widgets/CustomAppbar.dart';
import '../admin/Admin.dart'; // Importar los widgets de las tarjetas

class Options extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: CustomAppBar(title: ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 20 : 60),
          child: isMobile
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: _buildWidgetList(context),
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
                  itemCount: _buildWidgetList(context).length,
                  itemBuilder: (context, index) {
                    return _buildWidgetList(context).elementAt(index);
                  },
                ),
        ),
      ),
    );
  }

  List<Widget> _buildWidgetList(BuildContext context) {
    return [
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
            title: 'Administración',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminScreen(),
                ),
              );
            },
            icon: Icons.admin_panel_settings),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
            title: 'Menú',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ModulosMenu(),
                ),
              );
            },
            icon: Icons.restaurant_menu),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
            icon: Icons.qr_code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GestionarTicket(),
                ),
              );
            },
            title: 'Tickets'),
      ),
    ];
  }
}
