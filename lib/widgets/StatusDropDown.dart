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
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      constraints: BoxConstraints(maxWidth: isMobile ? 150 : 200),
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
          const SizedBox(width: 10),
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
