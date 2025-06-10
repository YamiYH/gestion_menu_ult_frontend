// lib/widgets/AccessDropDown.dart

import 'package:flutter/material.dart';

class AccessDropDown extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<String>
      availableAccesses; // <-- NUEVA PROPIEDAD para recibir las opciones
  final String label;

  const AccessDropDown({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    required this.availableAccesses, // <-- Requerido en el constructor
    this.label = 'Accesos', // Etiqueta por defecto
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      // Usamos DropdownButtonFormField para una mejor integración con formularios.
      value: selectedValue,
      isExpanded: true,
      // Para que el texto no se corte si es largo
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      // --- CAMBIO CLAVE: Construimos los items usando la lista que recibimos ---
      items: availableAccesses.map((String access) {
        return DropdownMenuItem<String>(
          value: access,
          child: Text(
            access,
            overflow: TextOverflow.ellipsis, // Evita que el texto se desborde
          ),
        );
      }).toList(),
      onChanged: onChanged,
      // Opcional: añade un validador si este campo es requerido
      validator: (value) {
        if (value == null || value == 'Todos') {
          // Asumiendo que 'Todos' no es una selección válida en algunos formularios
          // return 'Debe seleccionar un acceso';
        }
        return null;
      },
    );
  }
}
