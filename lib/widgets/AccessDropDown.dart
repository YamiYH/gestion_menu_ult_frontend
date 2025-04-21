import 'package:flutter/material.dart';

class AccessDropDown extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const AccessDropDown(
      {super.key, required this.selectedValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.50
          : MediaQuery.of(context).size.width * 0.15,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Permisos:',
            style: TextStyle(
                fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedValue,
            onChanged: onChanged,
            items: ['Todos', 'Menu', 'Tickets', 'Inventario']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
    ;
  }
}
