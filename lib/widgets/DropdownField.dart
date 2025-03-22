import 'package:flutter/material.dart';

class DropDownField extends StatefulWidget {
  const DropDownField({super.key});

  @override
  State<DropDownField> createState() => _DropDownFieldState();
}

class _DropDownFieldState extends State<DropDownField> {
  String? selectedTypeFilter;

  // Tipo de log seleccionado para filtrar
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: selectedTypeFilter,
        decoration: InputDecoration(
          labelText: 'Buscar por Actividad',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (String? newValue) {
          setState(() {
            selectedTypeFilter = newValue;
          });
        },
        items: [
          'default',
          'login',
          'logout',
          'error',
          'warning',
          'info',
          'create',
          'update',
          'delete'
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}
