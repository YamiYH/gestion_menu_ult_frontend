import 'package:flutter/material.dart';

/// Un widget que simula un Dropdown pero permite selección múltiple con checkboxes en un diálogo.
/// Incluye una opción "Todos" que actúa como "Seleccionar/Deseleccionar Todo".
class MultiSelectAccessDropdown extends StatefulWidget {
  /// La lista de valores (strings) actualmente seleccionados (NO debe incluir "Todos").
  final List<String> selectedValues;

  /// Callback que se ejecuta cuando la selección cambia. Devuelve la nueva lista de seleccionados (sin "Todos").
  final ValueChanged<List<String>> onSelectionChanged;

  /// La lista de todas las opciones posibles a mostrar (DEBE incluir "Todos").
  final List<String> allOptions;

  /// Etiqueta a mostrar encima o junto al control (estilo FormField).
  final String label;

  /// Texto a mostrar en el botón cuando no hay nada seleccionado o como placeholder.
  final String buttonHint;

  /// Validador opcional para usar con Forms.
  final FormFieldValidator<List<String>>? validator;

  const MultiSelectAccessDropdown({
    super.key,
    required this.selectedValues,
    required this.onSelectionChanged,
    // Asegúrate que esta lista incluya "Todos"
    this.allOptions = const ['Todos', 'Menu', 'Tickets', 'Inventario'],
    this.label = 'Accesos',
    this.buttonHint = 'Seleccionar...',
    this.validator,
  });

  @override
  State<MultiSelectAccessDropdown> createState() =>
      _MultiSelectAccessDropdownState();
}

class _MultiSelectAccessDropdownState extends State<MultiSelectAccessDropdown> {
  // --- Muestra el diálogo de selección múltiple (CON LÓGICA "TODOS") ---
  void _showMultiSelectDialog() async {
    // Copia la lista actual para modificarla temporalmente en el diálogo
    List<String> temporarySelectedValues = List.from(widget.selectedValues);
    const String todosOption = "Todos";
    // Lista de opciones reales (excluyendo "Todos") para la lógica interna
    final List<String> otherOptions =
        widget.allOptions.where((opt) => opt != todosOption).toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isMobile = MediaQuery.of(context).size.width < 600;
        return AlertDialog(
          title: Center(
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          content: StatefulBuilder(
            builder: (ctx, dialogSetState) {
              bool isTodosChecked = otherOptions.isNotEmpty &&
                  otherOptions
                      .every((opt) => temporarySelectedValues.contains(opt));

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Crea un CheckboxListTile para cada opción de widget.allOptions
                  children: widget.allOptions.map((option) {
                    final bool isCurrentOptionTodos = (option == todosOption);

                    return CheckboxListTile(
                      activeColor: Colors.red.shade400,
                      dense: true,
                      title: Text(
                        option,
                        style: TextStyle(fontSize: 15),
                      ),
                      // --- Valor del Checkbox ---
                      value: isCurrentOptionTodos
                          ? isTodosChecked // "Todos" usa el valor calculado
                          : temporarySelectedValues.contains(option),
                      onChanged: (bool? isChecked) {
                        // Actualiza usando el setState del diálogo!
                        dialogSetState(() {
                          if (isCurrentOptionTodos) {
                            // --- Si se hizo clic en "Todos" ---
                            if (isChecked == true) {
                              // Seleccionar Todo: Añade todas las *otras* opciones
                              temporarySelectedValues.addAll(otherOptions);
                              // Asegurar que no haya duplicados
                              temporarySelectedValues =
                                  temporarySelectedValues.toSet().toList();
                            } else {
                              // Deseleccionar Todo: Limpiar la lista
                              temporarySelectedValues.clear();
                            }
                          } else {
                            // --- Si se hizo clic en OTRA opción ---
                            if (isChecked == true) {
                              temporarySelectedValues
                                  .add(option); // Añade la opción
                              // No es necesario tocar "Todos" aquí, se recalculará solo
                            } else {
                              temporarySelectedValues
                                  .remove(option); // Quita la opción
                              // Al quitar una, "Todos" se desmarcará solo en el recalculado
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                        color: Colors.red[800],
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra sin guardar cambios
                  },
                ),
                SizedBox(width: 20), // Espacio entre botones
                TextButton(
                  child: Text('OK',
                      style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : 18)),
                  onPressed: () {
                    // --- Devuelve al padre SOLO las opciones reales seleccionadas ---
                    // Filtra "Todos" si estuviera presente (no debería con esta lógica, pero por seguridad)
                    List<String> finalSelection = temporarySelectedValues
                        .where((opt) => opt != todosOption)
                        .toSet() // Quita duplicados
                        .toList();

                    // Llama al callback del widget padre con la lista filtrada
                    widget.onSelectionChanged(finalSelection);
                    Navigator.of(context).pop(); // Cierra guardando cambios
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // --- Genera el texto a mostrar en el botón cerrado (ACTUALIZADO) ---
  String _displayString() {
    // Lista de opciones reales (excluyendo "Todos")
    final List<String> otherOptions =
        widget.allOptions.where((opt) => opt != "Todos").toList();
    // Verifica si todas las opciones reales están en la lista de seleccionados del widget
    final bool allActualOptionsSelected = otherOptions.isNotEmpty &&
        otherOptions.every((opt) => widget.selectedValues.contains(opt));

    if (widget.selectedValues.isEmpty) {
      return widget.buttonHint;
    }
    // Si todas las opciones disponibles (menos "Todos") están seleccionadas, muestra "Todos"
    if (allActualOptionsSelected && otherOptions.isNotEmpty) {
      // Asegura que haya otras opciones
      return "Todos";
    }
    // Si no, muestra la lista concatenada (como en tu versión)
    return widget.selectedValues
        .join(', '); // Mantenemos tu lógica original aquí
  }

  // --- El método build principal se mantiene igual ---
  @override
  Widget build(BuildContext context) {
    // (El código del build con FormField/InputDecorator/InkWell es el mismo que antes)
    return FormField<List<String>>(
      key: widget.key,
      initialValue: widget.selectedValues,
      validator: widget.validator,
      builder: (FormFieldState<List<String>> field) {
        return InputDecorator(
          decoration: InputDecoration(
            errorText: field.errorText,
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          ),
          child: InkWell(
            onTap: _showMultiSelectDialog,
            child: Container(
              height: 30,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _displayString(), // Usa la función display actualizada
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} // Fin de _MultiSelectAccessDropdownState
