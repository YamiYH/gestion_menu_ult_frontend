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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Center(
            child: Text(
              widget.label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Column(
              children: [
                Divider(
                  height: 1,
                  color: Colors.black45,
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isMobile ? 16 : 18),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    TextButton(
                      child: Text('OK',
                          style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 18 : 18)),
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
            ),
          ],
        );
      },
    );
  }

  String _displayString() {
    final List<String> otherOptions =
        widget.allOptions.where((opt) => opt != "Todos").toList();
    final bool allActualOptionsSelected = otherOptions.isNotEmpty &&
        otherOptions.every((opt) => widget.selectedValues.contains(opt));

    if (widget.selectedValues.isEmpty) {
      return widget.buttonHint;
    }
    if (allActualOptionsSelected && otherOptions.isNotEmpty) {
      return "Todos";
    }

    return widget.selectedValues.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return FormField<List<String>>(
      key: widget.key,
      initialValue: widget.selectedValues,
      validator: widget.validator,
      builder: (FormFieldState<List<String>> field) {
        return InputDecorator(
          decoration: InputDecoration(
            errorText: field.errorText,
            labelText: widget.label,
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
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
                      _displayString(),
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
