import 'package:flutter/material.dart';

/// Muestra un diálogo de confirmación estándar antes de realizar una acción destructiva.
///
/// [context]: El BuildContext actual.
/// [title]: El título del diálogo (por defecto: 'Confirmar Eliminación').
/// [itemName]: El nombre o identificador del ítem que se eliminará, para mostrarlo en el mensaje.
/// [itemType]: (Opcional) El tipo de ítem (ej: 'el rol', 'al usuario', 'la notificación') para un mensaje más claro.
/// [contentPrefix]: (Opcional) El inicio del mensaje de confirmación.
/// [onConfirm]: La función [VoidCallback] que se ejecutará si el usuario presiona 'ELIMINAR'.
/// [confirmActionText]: Texto del botón de confirmación.
/// [cancelActionText]: Texto del botón de cancelación.
///
/// Devuelve `Future<bool?>` que será `true` si se confirmó, `false` si se canceló, `null` si se cerró de otra forma.
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
  String title = 'Confirmar Eliminación',
  String contentPrefix = '¿Seguro que quieres eliminar',
  String itemType = '', // Ejemplo: 'el rol', 'al usuario', 'la notificación'
  String confirmActionText = 'ELIMINAR',
  String cancelActionText = 'CANCELAR',
}) async {
  // Construye el mensaje dinámicamente
  final String itemTypeString = itemType.isNotEmpty ? '$itemType ' : '';
  final String message = '$contentPrefix $itemTypeString"$itemName"?';

  // Determina si es móvil para ajustar estilos (basado en el contexto del diálogo)
  bool isMobile = MediaQuery.of(context).size.width < 600;
  final titleStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 20);
  final actionStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: isMobile ? 14 : 16);

  // Muestra el AlertDialog y espera el resultado
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Opcional: Evita cerrar tocando fuera
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Center(child: Text(title, style: titleStyle)),
        content: Text(message, textAlign: TextAlign.center), // Centra el texto
        actionsAlignment: MainAxisAlignment.spaceEvenly, // Espaciado de botones
        actions: <Widget>[
          // Botón Cancelar
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: Text(cancelActionText, style: actionStyle),
            onPressed: () {
              // Cierra el diálogo y devuelve 'false'
              Navigator.of(dialogContext).pop(false);
            },
          ),
          // Botón Confirmar (Eliminar)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red[800]),
            child: Text(confirmActionText, style: actionStyle),
            onPressed: () {
              onConfirm();
              Navigator.of(dialogContext).pop(true);
            },
          ),
        ],
      );
    },
  );
}
