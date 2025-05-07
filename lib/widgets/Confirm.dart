import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String itemName,
  required VoidCallback onConfirm,
  String title = 'Confirmar Eliminación',
  String contentPrefix = '¿Seguro que quieres eliminar',
  String itemType = '', // Ejemplo: 'el rol', 'al usuario', 'la notificación'
  String confirmActionText = 'Eliminar',
  String cancelActionText = 'Cancelar',
}) async {
  // Construye el mensaje dinámicamente
  final String itemTypeString = itemType.isNotEmpty ? '$itemType ' : '';
  final String message = '$contentPrefix $itemTypeString"$itemName"?';

  // Determina si es móvil para ajustar estilos (basado en el contexto del diálogo)
  bool isMobile = MediaQuery.of(context).size.width < 600;
  final titleStyle = TextStyle(fontSize: isMobile ? 18 : 20);

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
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
            child: Text(cancelActionText,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: isMobile ? 16 : 16,
                )),
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red[800]),
            child: Text(confirmActionText,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isMobile ? 16 : 16,
                )),
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
