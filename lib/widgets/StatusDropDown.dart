import 'package:flutter/material.dart';

class StatusDropDown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const StatusDropDown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Mantenemos la lógica de isMobile para el estilo del texto
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // Usamos la estructura exacta que proporcionaste (Container > Row > Text > SizedBox > Expanded > DropdownButton)
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 150 : 200),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Estado:',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              onChanged: onChanged,
              items: ['Todos', 'Activo', 'Inactivo']
                  .map<DropdownMenuItem<String>>((String itemValue) {
                return DropdownMenuItem<String>(
                  value: itemValue,
                  child: Text(itemValue, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
