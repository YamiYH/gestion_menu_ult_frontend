import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/Confirm.dart';
import '../../widgets/CustomAppbar.dart'; // Para formatear fechas (añadir a pubspec.yaml si no está)
// Importa tu AppBar personalizada si quieres usarla
// import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // --- DATOS DE EJEMPLO ---
  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': 1,
      'message': 'Reserva de tickets disponible',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 1))
    },
    {
      'id': 2,
      'message': 'Propuesta de menú esperando aprobación',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2))
    },
    {
      'id': 3,
      'message': 'Propuesta de menú aprobada',
      'isRead': false,
      'timestamp': DateTime.now().subtract(const Duration(days: 1))
    },
    {
      'id': 4,
      'message': 'Reserva de tickets disponible',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 1, hours: 3))
    },
    {
      'id': 5,
      'message': '¡Bienvenido a la aplicación!',
      'isRead': true,
      'timestamp': DateTime.now().subtract(const Duration(days: 5))
    },
  ];

  // Lista que se mostrará (puede ser filtrada o paginada en el futuro)
  late List<Map<String, dynamic>> _displayNotifications;

  @override
  void initState() {
    super.initState();
    // Inicializa la lista visible y ordena (más nuevas primero)
    _displayNotifications = List.from(_allNotifications);
    _sortNotifications();
  }

  void _sortNotifications() {
    _displayNotifications.sort((a, b) {
      final bool aIsRead = a['isRead'] as bool;
      final bool bIsRead = b['isRead'] as bool;

      // --- INICIO: Lógica de comparación CORREGIDA para booleanos ---
      int readCompare;
      if (aIsRead == bIsRead) {
        // 1. Si ambos son leídos o ambos no leídos, su orden es igual (0).
        //    Pasamos al siguiente criterio (timestamp).
        readCompare = 0;
      } else if (aIsRead == false /* && bIsRead == true */) {
        // 2. Si 'a' NO está leído y 'b' SÍ está leído, 'a' va primero (-1).
        readCompare = -1;
      } else /* aIsRead == true && bIsRead == false */ {
        // 3. Si 'a' SÍ está leído y 'b' NO está leído, 'b' va primero (1).
        readCompare = 1;
      }
      // --- FIN: Lógica de comparación CORREGIDA ---

      // Si el estado de leído/no leído es diferente, usamos ese resultado.
      if (readCompare != 0) {
        return readCompare;
      } else {
        // Si el estado de leído/no leído es el mismo, ordena por fecha descendente.
        // (Asegúrate de que 'timestamp' siempre exista o maneja el caso null)
        final DateTime aTimestamp = a['timestamp'] as DateTime? ??
            DateTime(1970); // Valor por defecto si es null
        final DateTime bTimestamp =
            b['timestamp'] as DateTime? ?? DateTime(1970);
        return bTimestamp.compareTo(aTimestamp); // Más nuevo primero
      }
    });
  }

  // --- Marcar como Leída ---
  void _markAsRead(int id) {
    // Busca el índice por ID por si la lista está ordenada/filtrada
    final index = _displayNotifications.indexWhere((n) => n['id'] == id);
    if (index != -1 && !_displayNotifications[index]['isRead']) {
      setState(() {
        // Marca como leída en la lista que se muestra
        _displayNotifications[index]['isRead'] = true;
        // !!! También deberías actualizar esto en tu fuente de datos real !!!

        // Reordena para moverla visualmente si es necesario
        _sortNotifications();
      });
    }
  }

  void _deleteNotification(int id) async {
    // Es mejor buscar en la lista original (_allNotifications) por si _displayNotifications está filtrada
    final notificationIndex =
        _allNotifications.indexWhere((n) => n['id'] == id);
    if (notificationIndex == -1) {
      print("Notificación con ID $id no encontrada en _allNotifications.");
      final displayIndex =
          _displayNotifications.indexWhere((n) => n['id'] == id);
      if (displayIndex != -1) {
        // Si sólo está en la lista visible (raro, pero posible si hay bugs), la quitamos de ahí
        setState(() {
          _displayNotifications.removeAt(displayIndex);
        });
      }
      return;
    }
    final notification = _allNotifications[notificationIndex];
    final String message =
        notification['message'] as String? ?? 'esta notificación';

    final bool? confirmed = await showConfirmDeleteDialog(
      context: context,
      itemName: message,
      itemType: 'la notificación',
      onConfirm: () {
        setState(() {
          _allNotifications.removeWhere((n) => n['id'] == id);
          _displayNotifications.removeWhere((n) => n['id'] == id);
        });
        // !!! Aquí deberías llamar a tu lógica para eliminar en el backend/DB !!!
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      print('Confirmada la eliminación de la notificación: $message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Notificación eliminada.'),
            duration: Duration(seconds: 2)),
      );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Notificaciones'),
      body: _displayNotifications.isEmpty
          ? const Center(
              // Mensaje cuando no hay notificaciones
              child: Text(
              'No tienes notificaciones.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ))
          : ListView.builder(
              itemCount: _displayNotifications.length,
              itemBuilder: (context, index) {
                final notification = _displayNotifications[index];
                final bool isRead = notification['isRead'] as bool;

                return Material(
                  // Añade Material para efecto InkWell
                  color: isRead ? Colors.white : Colors.red.shade50,
                  // Fondo diferente si no está leída
                  child: InkWell(
                    onTap: () => _markAsRead(notification['id'] as int),
                    child: ListTile(
                      // Icono principal diferente si está leída o no
                      leading: Icon(
                        isRead
                            ? Icons.notifications_none_outlined
                            : Icons.notifications_active,
                        color: isRead ? Colors.grey : Colors.red[700],
                        size: 28,
                      ),
                      title: Text(
                        notification['message'] as String,
                        maxLines: 2, // Limita a 2 líneas
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          // Texto en negrita si no está leída
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          // Color del texto más tenue si está leída
                          color: isRead ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      // Subtítulo con la fecha/hora formateada
                      subtitle: Text(
                        _formatTimestamp(notification['timestamp'] as DateTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      // Botón para eliminar
                      trailing: IconButton(
                        icon:
                            Icon(Icons.delete_outline, color: Colors.grey[600]),
                        tooltip: 'Eliminar notificación',
                        onPressed: () =>
                            _deleteNotification(notification['id'] as int),
                      ),
                      dense: true, // Hace el ListTile un poco más compacto
                    ),
                  ),
                );
              },
            ),
    );
  }
}
