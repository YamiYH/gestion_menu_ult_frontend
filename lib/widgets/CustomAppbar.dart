import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Help.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Login.dart';
import 'package:gestion_menu_ult_frontend/screens/common/Notifications.dart';

import '../controllers/auth/LoginController.dart';
import '../screens/common/Perfil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName = 'Yamilet Yero'; // Nombre del usuario logeado
  final List<String> notifications = [
    'Propuesta de menú esperando aprobación',
    'Propuesta de menú aprobada',
    'Reserva de tickets disponible',
  ]; // Lista de notificaciones
  final String title;
  final PreferredSizeWidget? bottom;

  CustomAppBar({
    Key? key,
    required this.title,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.red[900],
      titleSpacing: 0,
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
                          userName,
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
                    tooltip: 'Manual de Usuarios',
                    onPressed: () {
                      Navigator.push(context, createFadeRoute(Help()));
                    },
                    icon: Icon(Icons.help_outline)),
                //SizedBox(width: isMobile ? 10 : 20),
                PopupMenuButton<String>(
                  position: PopupMenuPosition.under,
                  tooltip: 'Mostrar notificaciones',
                  onSelected: (String value) {
                    if (value == 'view_all') {
                      Navigator.push(
                          context,
                          createFadeRoute(
                              Notifications())); // Navegar a la pantalla de todas las notificaciones
                    }
                  },
                  itemBuilder: (context) => [
                    ...notifications.map((notification) {
                      return PopupMenuItem<String>(
                        value: notification,
                        child: Text(notification,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'view_all',
                      child: Text('Mostrar Todas'),
                    ),
                  ],
                  child: Builder(
                    builder: (buttonContext) {
                      final int unreadCount = notifications.length;

                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: isMobile ? 22 : 25,
                          ),
                          if (unreadCount >
                              0) // Solo se muestra si hay notificaciones sin leer
                            Positioned(
                              top: -4,
                              right: -2,
                              child: Container(
                                padding:
                                    EdgeInsets.all(unreadCount > 9 ? 3 : 2),
                                // Padding un poco mayor para '9+'
                                decoration: BoxDecoration(
                                  color: Colors.red, // Color típico para badges
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: 1.5), // Borde opcional
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18, // Ancho mínimo
                                  minHeight: 18, // Alto mínimo
                                ),
                                child: Center(
                                  child: Text(
                                    // Muestra el número o '9+' si son demasiadas
                                    unreadCount > 9 ? '9+' : '$unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      height:
                                          1.1, // Ajuste fino de altura de línea
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                        ],
                      );
                    },
                  ),
                ),
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
      //bottom: bottom,
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
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              onPressed: () async {
                final LoginController loginController =
                    LoginController(); // O obtén la instancia
                await loginController.logout();
                // Navegar a la pantalla de login y remover todas las rutas anteriores
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) =>
                      false, // Esto elimina todas las rutas anteriores de la pila
                ); // Cerrar el diálogo
              },
              child: Text(
                'ACEPTAR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                Navigator.push(
                    context,
                    createFadeRoute(
                        Login())); // Ir a la pantalla de inicio de sesión
              },
              child: Text('CANCELAR',
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 14 : 16)),
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
