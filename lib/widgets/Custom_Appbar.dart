import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName; // Nombre del usuario logeado
  final List<String> notifications; // Lista de notificaciones

  const CustomAppBar({
    Key? key,
    required this.userName,
    required this.notifications,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return AppBar(
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: Colors.red[900],
      titleSpacing: 0,
      // Elimina el espacio predeterminado entre el leading y el título
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/icons/user.png'),
                  radius: isMobile ? 16 : 20,
                ),
                SizedBox(width: 10),
                SizedBox(
                  width: isMobile ? 80 : 150,
                  child: Text(
                    userName,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 13 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //SizedBox(height: screenWidth * 0.15),

          SizedBox(width: isMobile ? 10 : 60),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'view_all') {
                      Navigator.pushNamed(context,
                          '/all-notifications'); // Navegar a la pantalla de todas las notificaciones
                    }
                  },
                  itemBuilder: (context) => [
                    ...notifications.map((notification) {
                      return PopupMenuItem<String>(
                        value: notification,
                        child: Text(notification),
                      );
                    }).toList(),
                    PopupMenuItem<String>(
                      value: 'view_all',
                      child: Text('Mostrar Todas'),
                    ),
                  ],
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: isMobile ? 20 : 25,
                  ),
                ),
                // Menú desplegable con opciones
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit_profile') {
                      Navigator.pushNamed(
                          context, '/edit-profile'); // Navegar a editar perfil
                    } else if (value == 'logout') {
                      _logout(context); // Cerrar sesión
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit_profile',
                      child: Text('Editar Perfil'),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Text('Cerrar Sesión'),
                    ),
                  ],
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: isMobile ? 20 : 25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Método para mostrar el menú de notificaciones
  void _showNotificationsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Notificaciones Recientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notifications[index]),
                  );
                },
              ),
            ),
            ListTile(
              title: Text('Mostrar Todas'),
              onTap: () {
                Navigator.pop(context); // Cerrar el menú
                Navigator.pushNamed(context,
                    '/all-notifications'); // Navegar a la pantalla de todas las notificaciones
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                Navigator.pushReplacementNamed(
                    context, '/login'); // Ir a la pantalla de inicio de sesión
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
