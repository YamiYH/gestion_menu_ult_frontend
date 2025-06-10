// lib/widgets/RoleDropDown.dart

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/RoleController.dart'; // Asegúrate que la ruta es correcta

class RoleDropDown extends StatefulWidget {
  final String?
      selectedValue; // El valor que la pantalla padre tiene seleccionado
  final ValueChanged<String?>
      onChanged; // La función para notificar a la pantalla padre de un cambio
  final String? Function(String?)? validator; // Validador opcional
  final String label;

  const RoleDropDown({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
    this.validator,
    this.label = 'Rol', // Etiqueta por defecto
  }) : super(key: key);

  @override
  State<RoleDropDown> createState() => _RoleDropDownState();
}

class _RoleDropDownState extends State<RoleDropDown> {
  // Estado interno del widget
  final RoleController _roleController = RoleController();
  late Future<List<String>> _fetchRolesFuture;

  @override
  void initState() {
    super.initState();
    // Iniciamos la carga de datos una sola vez cuando el widget se crea
    _fetchRolesFuture = _loadRoleNames();
  }

  // Método que llama al controlador para obtener los nombres de los roles
  Future<List<String>> _loadRoleNames() async {
    try {
      // Usamos el método que creamos anteriormente en RoleController
      final roleNames = await _roleController.fetchRoleNames();
      // Añadimos la opción "Todos" al principio de la lista para los filtros
      return ['Todos', ...roleNames];
    } catch (e) {
      // Si hay un error, lo lanzamos para que el FutureBuilder lo capture
      debugPrint("Error cargando nombres de roles para el dropdown: $e");
      throw Exception("No se pudieron cargar los roles");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos un FutureBuilder para manejar los estados de carga, error y éxito
    return FutureBuilder<List<String>>(
      future: _fetchRolesFuture,
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
                Text('Cargando roles...'),
              ],
            ),
            items: const [],
            onChanged: null, // Deshabilitado mientras carga
          );
        }

        // --- ESTADO DE ERROR ---
        if (snapshot.hasError) {
          return TextFormField(
            readOnly: true,
            decoration: _inputDecoration(widget.label).copyWith(
              errorText: 'Error al cargar',
              hintText: 'Reintentar',
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Permite al usuario reintentar la carga
                  setState(() {
                    _fetchRolesFuture = _loadRoleNames();
                  });
                },
              ),
            ),
          );
        }

        // --- ESTADO DE ÉXITO (DATOS CARGADOS) ---
        final availableRoles = snapshot.data ?? ['Todos'];

        return DropdownButtonFormField<String>(
          value: widget.selectedValue,
          isExpanded: true,
          decoration: _inputDecoration(widget.label),
          items: availableRoles.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: widget.onChanged,
          // Notifica al widget padre
          validator: widget.validator, // Usa el validador pasado desde el padre
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
