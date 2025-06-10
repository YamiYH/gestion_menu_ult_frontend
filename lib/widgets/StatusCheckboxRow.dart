// lib/widgets/StatusCheckboxRow.dart

import 'package:flutter/material.dart';

/// Un widget que muestra una fila con una etiqueta y un único Checkbox.
/// Ideal para filtros de tipo "Solo Activos".
class StatusCheckboxRow extends StatelessWidget {
  /// El valor booleano actual del checkbox (true si está marcado, false si no).
  final bool value;

  /// Callback que se llama cuando el valor del checkbox cambia.
  final ValueChanged<bool?> onChanged;

  final String label;

  const StatusCheckboxRow({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label = 'Activo',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 16,
      fontWeight:
          FontWeight.normal, // Un estilo más estándar para el label del filtro
    );

    // Hace el checkbox un poco más compacto
    const visualDensity = VisualDensity(horizontal: -4, vertical: -4);

    // Usar un InkWell o GestureDetector hace que toda la fila sea clickable
    return InkWell(
      onTap: () {
        onChanged(!value); // Invierte el valor actual al tocar la fila
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // Para que no ocupe todo el ancho si no es necesario
          children: <Widget>[
            Checkbox(
              value: value,
              activeColor: Colors.red.shade700,
              onChanged: onChanged, // Pasa el callback directamente
              visualDensity: visualDensity,
            ),
            const SizedBox(width: 4.0),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
