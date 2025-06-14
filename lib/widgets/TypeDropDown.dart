// lib/widgets/TypeDropDown.dart

import 'package:flutter/material.dart';

import '../controllers/security/user/UserController.dart'; // Asegúrate que la ruta es correcta

class TypeDropDown extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String label;

  const TypeDropDown({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
    this.label = 'Tipo',
  }) : super(key: key);

  @override
  State<TypeDropDown> createState() => _TypeDropDownState();
}

class _TypeDropDownState extends State<TypeDropDown> {
  final UserController _userController = UserController();
  late Future<List<String>> _fetchTypesFuture;

  @override
  void initState() {
    super.initState();
    _fetchTypesFuture = _loadTypeNames();
  }

  // Método que llama al controlador para obtener los nombres de los tipos
  Future<List<String>> _loadTypeNames() async {
    try {
      final typeNames = await _userController.fetchUserTypes();

      return ['Todos', ...typeNames];
    } catch (e) {
      debugPrint("Error cargando tipos de usuario para el dropdown: $e");
      throw Exception("No se pudieron cargar los tipos");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _fetchTypesFuture,
      builder: (context, snapshot) {
        // --- ESTADO DE CARGA ---
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DropdownButtonFormField<String>(
            decoration: _inputDecoration(widget.label),
            hint: const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Cargando tipos...'),
              ],
            ),
            items: const [],
            onChanged: null,
          );
        }

        // --- ESTADO DE ERROR ---
        if (snapshot.hasError) {
          return TextFormField(
            readOnly: true,
            decoration: _inputDecoration(widget.label).copyWith(
              errorText: 'Error al cargar',
              suffixIcon: IconButton(
                tooltip: 'Reintentar',
                icon: const Icon(Icons.refresh, color: Colors.red),
                onPressed: () {
                  // Permite al usuario reintentar la carga
                  setState(() {
                    _fetchTypesFuture = _loadTypeNames();
                  });
                },
              ),
            ),
          );
        }

        // --- ESTADO DE ÉXITO (DATOS CARGADOS) ---
        final availableTypes = snapshot.data ?? ['Todos'];

        return DropdownButtonFormField<String>(
          value: widget.selectedValue,
          isExpanded: true,
          decoration: _inputDecoration(widget.label),
          items: availableTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: widget.onChanged,
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
