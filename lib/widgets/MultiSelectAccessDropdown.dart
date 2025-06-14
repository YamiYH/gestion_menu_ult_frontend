import 'package:flutter/material.dart';

class MultiSelectAccessDropdown extends StatefulWidget {
  final List<String> selectedValues;
  final ValueChanged<List<String>> onSelectionChanged;
  final List<String> allOptions;
  final String label;
  final String buttonHint;
  final FormFieldValidator<List<String>>? validator;

  const MultiSelectAccessDropdown({
    super.key,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.allOptions = const [],
    this.label = 'Accesos',
    this.buttonHint = 'Seleccionar...',
    this.validator,
  });

  @override
  State<MultiSelectAccessDropdown> createState() =>
      _MultiSelectAccessDropdownState();
}

class _MultiSelectAccessDropdownState extends State<MultiSelectAccessDropdown> {
  void _showMultiSelectDialog(FormFieldState<List<String>> field) async {
    List<String> temporarySelectedValues = List.from(widget.selectedValues);
    const String todosOption = "Todos";
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
                  children: widget.allOptions.map((option) {
                    final bool isCurrentOptionTodos = (option == todosOption);

                    return CheckboxListTile(
                      activeColor: Colors.red.shade400,
                      dense: true,
                      title: Text(
                        option,
                        style: TextStyle(fontSize: 15),
                      ),
                      value: isCurrentOptionTodos
                          ? isTodosChecked
                          : temporarySelectedValues.contains(option),
                      onChanged: (bool? isChecked) {
                        dialogSetState(() {
                          if (isCurrentOptionTodos) {
                            if (isChecked == true) {
                              temporarySelectedValues.addAll(otherOptions);

                              temporarySelectedValues =
                                  temporarySelectedValues.toSet().toList();
                            } else {
                              temporarySelectedValues.clear();
                            }
                          } else {
                            if (isChecked == true) {
                              temporarySelectedValues.add(option);
                            } else {
                              temporarySelectedValues.remove(option);
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
                        color: Colors.grey.shade700,
                        //fontWeight: FontWeight.bold,
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
                    List<String> finalSelection = temporarySelectedValues
                        .where((opt) => opt != todosOption)
                        .toSet()
                        .toList();

                    field.didChange(finalSelection);
                    widget.onSelectionChanged(finalSelection);
                    Navigator.of(context).pop();
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
            onTap: () => _showMultiSelectDialog(field),
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
