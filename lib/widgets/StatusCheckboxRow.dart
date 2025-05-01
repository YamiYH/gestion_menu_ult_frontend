import 'package:flutter/material.dart';

/// Un widget que muestra una fila con una etiqueta y opciones de estado
/// (Activo/Inactivo) seleccionables mediante Checkbox.
/// Se asegura de que solo una opción pueda estar seleccionada a la vez.
class StatusCheckboxRow extends StatelessWidget {
  final String? currentStatus;
  final ValueChanged<String?> onStatusChanged;
  final String label;

  const StatusCheckboxRow({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.label = 'Estado:', // Etiqueta por defecto
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final textStyle = TextStyle(fontSize: isMobile ? 14 : 16);

    // Hace los checkboxes un poco más compactos
    const visualDensity = VisualDensity(horizontal: -4, vertical: -4);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(label,
            style:
                textStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(width: 40.0),
        Checkbox(
          value: currentStatus == 'Activo',
          activeColor: Colors.red.shade400,
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
        SizedBox(width: 40.0),
        Checkbox(
          value: currentStatus == 'Inactivo',
          activeColor: Colors.red.shade400,
          onChanged: (bool? isChecked) {
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
