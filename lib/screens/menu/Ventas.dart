import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

import '../../widgets/DynamicButton.dart';

class Ventas extends StatefulWidget {
  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  // Datos simulados de platos
  List<Map<String, dynamic>> menuItems = [
    {'name': 'Plato 1', 'price': 3.75},
    {'name': 'Plato 2', 'price': 4.00},
    {'name': 'Plato 3', 'price': 4.50},
  ];

  // Estado para seguir los platos seleccionados
  Map<int, bool> selectedItems = {};

  // Fecha seleccionada
  DateTime? selectedDate;

  // Lista simulada de nombres para el Autocomplete
  List<String> userNames = ['Juan Pérez', 'María López', 'Carlos Gómez'];

  // Nombre seleccionado
  String? selectedUser;

  double get totalPrice {
    double total = 0;
    for (var i = 0; i < menuItems.length; i++) {
      if (selectedItems[i] ?? false) {
        total += menuItems[i]['price'];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(title: 'Ventas'),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.8
                          : MediaQuery.of(context).size.width * 0.8,
                      height: isMobile
                          ? 150
                          : MediaQuery.of(context).size.height * 0.8,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menú Disponible',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...menuItems.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> menuItem = entry.value;
                            return BuildCard(menuItem, index);
                          }).toList(),
                          const SizedBox(height: 20),
                          Text(
                            'Total: \$${totalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context).size.width * 0.05,
                width: MediaQuery.of(context).size.width * 0.05),
            // Columna Derecha: Filtros y Acciones
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Selector de Fecha
                    SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.85
                          : MediaQuery.of(context).size.width * 0.20,
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.07
                          : MediaQuery.of(context).size.height * 0.07,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.red[900]!, width: 1),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 10 : 20,
                            vertical: isMobile ? 8 : 12,
                          ),
                        ),
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 30)),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData(
                                  primaryColor: Colors.red[900],
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.red[400]!,
                                  ),
                                  textTheme: TextTheme(
                                    headlineMedium: TextStyle(fontSize: 16),
                                    bodyLarge: TextStyle(fontSize: 14),
                                    bodyMedium: TextStyle(fontSize: 12),
                                  ),
                                  dialogTheme: DialogThemeData(
                                      backgroundColor: Colors.white),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        icon:
                            Icon(Icons.calendar_today, color: Colors.red[900]),
                        label: Text(
                          selectedDate == null
                              ? 'Seleccionar Fecha'
                              : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                          style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              color: Colors.red[900]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buscador de Usuarios
                    SizedBox(
                      width: isMobile
                          ? MediaQuery.of(context).size.width * 0.85
                          : MediaQuery.of(context).size.width * 0.20,
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.07
                          : MediaQuery.of(context).size.height * 0.07,
                      child: Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          return userNames.where((String option) {
                            return option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            selectedUser = selection;
                          });
                        },
                        fieldViewBuilder: (context, textEditingController,
                            focusNode, onFieldSubmitted) {
                          return TextField(
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Buscar Usuario',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              suffixIcon: Icon(Icons.search),
                            ),
                          );
                        },
                        displayStringForOption: (String option) => option,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Espacio para Código QR
                    Container(
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: MediaQuery.of(context).size.height * 0.40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          'Código QR\nGenerado aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      // Botones Reservar y Pagar
                      DynamicButton(
                        onPressed: () {},
                        text: 'Reservar',
                      ),
                      const SizedBox(width: 10),
                      DynamicButton(onPressed: () {}, text: 'Pagar'),
                    ])
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card BuildCard(Map<String, dynamic> menuItem, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      //elevation: 4,
      child: Container(
        child: ListTile(
          title: Text(
            menuItem['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('\$${menuItem['price']}'),
          trailing: Checkbox(
            activeColor: Colors.red,
            value: selectedItems[index] ?? false,
            onChanged: (value) {
              setState(() {
                selectedItems[index] = value!;
              });
            },
          ),
        ),
      ),
    );
  }
}
