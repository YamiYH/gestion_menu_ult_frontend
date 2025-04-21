import 'package:flutter/material.dart';

class TypeDropDown extends StatelessWidget {
  /// El valor ('Todos', 'Activo', 'Inactivo') actualmente seleccionado.
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const TypeDropDown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      // Añadir algo de padding
      constraints: BoxConstraints(maxWidth: isMobile ? 150 : 200),
      // Limitar ancho
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Tipo:',
              style: TextStyle(
                  fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Expanded(
            // Permitir que el Dropdown se expanda
            child: DropdownButton<String>(
              isExpanded: true, // Para que ocupe el espacio de Expanded
              value: selectedValue,
              onChanged: onChanged,
              items: [
                'Todos',
                'System',
                'Employee'
              ] // Asegúrate que estos valores coincidan con user['type']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
