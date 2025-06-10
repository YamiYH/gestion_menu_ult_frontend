// lib/widgets/StatusDropDown.dart

import 'package:flutter/material.dart';

class StatusDropDown extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String label;

  const StatusDropDown({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
    this.label = 'Estado', // Etiqueta por defecto
  }) : super(key: key);

  @override
  State<StatusDropDown> createState() => _StatusDropDownState();
}

class _StatusDropDownState extends State<StatusDropDown> {
  // Usamos un Future para mantener la consistencia arquitectónica con TypeDropDown
  late Future<List<String>> _fetchStatusFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de datos una sola vez cuando el widget se crea
    _fetchStatusFuture = _loadStatusOptions();
  }

  // A diferencia de TypeDropDown, aquí cargamos una lista local,
  // pero lo envolvemos en un Future para simular el mismo patrón asíncrono.
  Future<List<String>> _loadStatusOptions() async {
    // Usamos Future.delayed para simular una carga muy rápida y evitar problemas de build.
    await Future.delayed(Duration.zero);
    return ['Todos', 'Activo', 'Inactivo'];
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un FutureBuilder para manejar los estados de carga, error y éxito
    return FutureBuilder<List<String>>(
      future: _fetchStatusFuture,
      builder: (context, snapshot) {
        // --- ESTADO DE CARGA (será casi instantáneo) ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField<String>(
            decoration: _inputDecoration(widget.label),
            hint: const Text('Cargando...'), // Un hint simple es suficiente
            items: const [],
            onChanged: null, // Deshabilitado mientras carga
          );
        }

        // --- ESTADO DE ÉXITO (DATOS CARGADOS) ---
        // (Un estado de error es muy improbable aquí, pero el patrón lo soportaría)
        final availableStatus = snapshot.data ?? ['Todos'];

        return DropdownButtonFormField<String>(
          value: availableStatus.contains(widget.selectedValue)
              ? widget.selectedValue
              : 'Todos',
          // Asegura que el valor exista en la lista
          isExpanded: true,
          decoration: _inputDecoration(widget.label),
          items: availableStatus.map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: widget.onChanged,
          // Notifica al widget padre
          validator: widget.validator,
        );
      },
    );
  }

  // Helper para la decoración, para mantener un estilo consistente
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}
