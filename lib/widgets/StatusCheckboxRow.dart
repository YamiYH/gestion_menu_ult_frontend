import 'package:flutter/material.dart';

/// Un widget que muestra una fila con una etiqueta y opciones de estado
/// (Activo/Inactivo) seleccionables mediante Checkbox.
/// Se asegura de que solo una opción pueda estar seleccionada a la vez.
class StatusCheckboxRow extends StatelessWidget {
  /// El estado actual ('Activo', 'Inactivo', o null si ninguno está seleccionado inicialmente).
  final String? currentStatus;

  /// Callback que se ejecuta cuando el estado seleccionado cambia.
  /// Devuelve 'Activo' o 'Inactivo'.
  final ValueChanged<String?> onStatusChanged;

  /// La etiqueta a mostrar antes de las opciones.
  final String label;

  const StatusCheckboxRow({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.label = 'Estado:', // Etiqueta por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Determina si es móvil para ajustar estilos (opcional)
    bool isMobile = MediaQuery.of(context).size.width < 600;
    // Estilos de texto consistentes
    final textStyle = TextStyle(fontSize: isMobile ? 14 : 16);

    // Hace los checkboxes un poco más compactos
    const visualDensity = VisualDensity(horizontal: -4, vertical: -4);

    return Row(
      // mainAxisSize: MainAxisSize.min, // Para que la Row no ocupe más de lo necesario horizontalmente
      crossAxisAlignment: CrossAxisAlignment.center,
      // Alinea verticalmente los elementos
      children: <Widget>[
        Text(label,
            style:
                textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(width: 40.0),
        Checkbox(
          value: currentStatus == 'Activo',
          activeColor: Colors.red.shade400,

          // Marcado si el estado actual es 'Activo'
          onChanged: (bool? isChecked) {
            // Solo llama al callback si se está MARCANDO esta opción
            if (isChecked == true) {
              onStatusChanged('Activo');
            }
          },
          visualDensity: visualDensity,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        SizedBox(width: 10.0),
        Text('Activo', style: TextStyle(fontSize: 15)),

        SizedBox(width: 40.0), // Espacio entre las dos opciones

        Checkbox(
          value: currentStatus == 'Inactivo',
          activeColor: Colors.red.shade400,
          onChanged: (bool? isChecked) {
            // Solo llama al callback si se está MARCANDO esta opción
            if (isChecked == true) {
              onStatusChanged('Inactivo');
            }
          },
          visualDensity: visualDensity,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        SizedBox(width: 10.0),
        Text(
          'Inactivo',
          style: TextStyle(fontSize: 15),
        )
      ],
    );
  }
}
