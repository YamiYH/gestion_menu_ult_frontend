import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/Confirm.dart';
import '../../widgets/CustomAppbar.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
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

  late List<Map<String, dynamic>> _displayNotifications;

  @override
  void initState() {
    super.initState();

    _displayNotifications = List.from(_allNotifications);
    _sortNotifications();
  }

  void _sortNotifications() {
    _displayNotifications.sort((a, b) {
      final bool aIsRead = a['isRead'] as bool;
      final bool bIsRead = b['isRead'] as bool;

      int readCompare;
      if (aIsRead == bIsRead) {
        readCompare = 0;
      } else if (aIsRead == false) {
        readCompare = -1;
      } else {
        readCompare = 1;
      }

      if (readCompare != 0) {
        return readCompare;
      } else {
        final DateTime aTimestamp =
            a['timestamp'] as DateTime? ?? DateTime(1970);
        final DateTime bTimestamp =
            b['timestamp'] as DateTime? ?? DateTime(1970);
        return bTimestamp.compareTo(aTimestamp);
      }
    });
  }

  void _markAsRead(int id) {
    final index = _displayNotifications.indexWhere((n) => n['id'] == id);
    if (index != -1 && !_displayNotifications[index]['isRead']) {
      setState(() {
        _displayNotifications[index]['isRead'] = true;

        _sortNotifications();
      });
    }
  }

  void _deleteNotification(int id) async {
    final notificationIndex =
        _allNotifications.indexWhere((n) => n['id'] == id);
    if (notificationIndex == -1) {
      print("Notificación con ID $id no encontrada en _allNotifications.");
      final displayIndex =
          _displayNotifications.indexWhere((n) => n['id'] == id);
      if (displayIndex != -1) {
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
                  color: isRead ? Colors.white : Colors.red.shade50,
                  child: InkWell(
                    onTap: () => _markAsRead(notification['id'] as int),
                    child: ListTile(
                      leading: Icon(
                        isRead
                            ? Icons.notifications_none_outlined
                            : Icons.notifications_active,
                        color: isRead ? Colors.grey : Colors.red[700],
                        size: 28,
                      ),
                      title: Text(
                        notification['message'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              isRead ? FontWeight.normal : FontWeight.bold,
                          color: isRead ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        _formatTimestamp(notification['timestamp'] as DateTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon:
                            Icon(Icons.delete_outline, color: Colors.grey[600]),
                        tooltip: 'Eliminar notificación',
                        onPressed: () =>
                            _deleteNotification(notification['id'] as int),
                      ),
                      dense: true,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
