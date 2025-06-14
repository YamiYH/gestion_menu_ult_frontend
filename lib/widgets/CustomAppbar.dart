import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Help.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Login.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Options.dart';
import 'package:provider/provider.dart';

import '../controllers/security/LoginController.dart';
import '../providers/ProfileProvider.dart';
import '../screens/common/Perfil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;

  CustomAppBar({
    Key? key,
    required this.title,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.userProfile;
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final bool canGoBack = Navigator.canPop(context);

    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.red[900],
      titleSpacing: 0,

      automaticallyImplyLeading: false,

      // 3. Definimos el widget 'leading' con nuestra lógica condicional.
      leading: canGoBack
          ? const BackButton(
              color: Colors.white) // Si podemos volver, muestra el botón.
          : const SizedBox(width: 56.0),
      // Si no, muestra un espacio invisible del mismo ancho.

      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: isMobile
                ? SizedBox()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage('assets/icons/user.png'),
                        radius: 16,
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: isMobile
                            ? 80
                            : MediaQuery.of(context).size.width * 0.1,
                        child: Text(
                          user?.name ?? 'Cargando...',
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile
                                ? 13
                                : MediaQuery.of(context).size.width * 0.011,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          //SizedBox(width: isMobile ? 0 : 60),
          Expanded(
            flex: isMobile ? 12 : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                    )),
                SizedBox(width: isMobile ? 5 : 20),
                IconButton(
                    tooltip: 'Página principal',
                    onPressed: () {
                      Navigator.push(context, createFadeRoute(Options()));
                    },
                    icon: Icon(Icons.home)),
                IconButton(
                    tooltip: 'Manual de Usuarios',
                    onPressed: () {
                      Navigator.push(context, createFadeRoute(Help()));
                    },
                    icon: Icon(Icons.help_outline)),
                //SizedBox(width: isMobile ? 10 : 20),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.push(context,
                          createFadeRoute(Perfil())); // Navegar a editar perfil
                    } else if (value == 'logout') {
                      _logout(context, isMobile); // Cerrar sesión
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Text('Mi Perfil'),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Cerrar Sesión'),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: isMobile ? 22 : 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: bottom,
    );
  }

  // Método para cerrar sesión
  void _logout(BuildContext context, isMobile) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Center(child: Text('Cerrar Sesión')),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cancelar',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () async {
                final LoginController loginController = LoginController();
                await loginController.logout();
                Provider.of<ProfileProvider>(context, listen: false)
                    .clearProfile();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Aceptar',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize {
    // Suma la altura del bottom si está presente
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }
}
