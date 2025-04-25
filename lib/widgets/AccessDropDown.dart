import 'package:flutter/material.dart';

class AccessDropDown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  AccessDropDown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      constraints: BoxConstraints(maxWidth: isMobile ? 150 : 200),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Accesos:',
            style: TextStyle(
                fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              onChanged: onChanged,
              items: const ['Todos', 'Menu', 'Tickets', 'Inventario']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
    ;
  }
}
