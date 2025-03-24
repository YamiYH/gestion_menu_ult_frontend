import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/BuildCard.dart';

import '../security/Logs.dart';
import 'Users.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
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
                builder: (context) => UsersScreen(),
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
          onTap: () {},
        ),
      ),
      Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
          title: 'Pasarelas de Pago',
          icon: Icons.payment,
          onTap: () {},
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
                builder: (context) => LogsScreen(),
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
            // Acción para el módulo de Menú
            print('Módulo de Menú seleccionado');
          },
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Administración',
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 20 : 25,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red[900],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Lógica de cierre de sesión
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
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
    );
  }
}
