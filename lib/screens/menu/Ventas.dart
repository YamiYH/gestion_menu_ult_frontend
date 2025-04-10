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
  DateTime? selectedDate = DateTime.now().add(Duration(days: 1));

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
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(isMobile ? 25.0 : 30.0),
            child: isMobile
                ? Column(
                    children: _buildSales(isMobile, context),
                    mainAxisAlignment: MainAxisAlignment.center,
                  )
                : Row(children: _buildSales(isMobile, context))),
      ),
    );
  }

  List<Widget> _buildSales(bool isMobile, BuildContext context) {
    return [
      MenuExpanded(isMobile, context),
      SizedBox(
          width: isMobile ? 0 : MediaQuery.of(context).size.width * 0.08,
          height: isMobile ? 30 : 0),
      SaleExpanded(isMobile, context)
    ];
  }

  Widget MenuExpanded(bool isMobile, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.90
            : MediaQuery.of(context).size.width * 0.6,
        height: isMobile ? null : MediaQuery.of(context).size.height * 0.8,
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
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  return BuildCard(menuItem, index);
                }),
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
    );
  }

  Widget SaleExpanded(bool isMobile, BuildContext context) {
    return Container(
      width: isMobile ? MediaQuery.of(context).size.width * 0.90 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Selector de Fecha
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(
                isMobile
                    ? MediaQuery.of(context).size.width * 0.85
                    : MediaQuery.of(context).size.width * 0.20,
                MediaQuery.of(context).size.height * 0.07,
              ),
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
                      dialogTheme:
                          DialogThemeData(backgroundColor: Colors.white),
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
            icon: Icon(Icons.calendar_today, color: Colors.red[900]),
            label: Text(
              selectedDate == null
                  ? 'Seleccionar Fecha'
                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Buscador de Usuarios
          SizedBox(
            width: isMobile
                ? MediaQuery.of(context).size.width * 0.85
                : MediaQuery.of(context).size.width * 0.20,
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.08
                : MediaQuery.of(context).size.height * 0.08,
            child: SingleChildScrollView(
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
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
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
          ),
          const SizedBox(height: 20),

          // Espacio para Código QR
          Container(
            width: isMobile
                ? MediaQuery.of(context).size.width * 0.70
                : MediaQuery.of(context).size.width * 0.20,
            height: isMobile
                ? MediaQuery.of(context).size.width * 0.70
                : MediaQuery.of(context).size.width * 0.20,
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
          SizedBox(height: 30),

          isMobile
              ? Column(children: [
                  DynamicButton(
                    onPressed: () {},
                    text: 'Reservar',
                    colorButton: Colors.red.shade900,
                    size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50),
                  ),
                  SizedBox(height: 15),
                  DynamicButton(
                      onPressed: () {},
                      text: 'Pagar',
                      colorButton: Colors.red.shade900,
                      size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50)),
                  SizedBox(height: 15),
                  CloseSalesButton(isMobile)
                ])
              : Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      DynamicButton(
                        onPressed: () {},
                        text: 'Reservar',
                        colorButton: Colors.red.shade900,
                        size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50),
                      ),
                      const SizedBox(width: 10),
                      DynamicButton(
                          onPressed: () {},
                          text: 'Pagar',
                          colorButton: Colors.red.shade900,
                          size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50)),
                    ]),
                    SizedBox(height: 15),
                    CloseSalesButton(isMobile)
                  ],
                )
        ],
      ),
    );
  }

  ElevatedButton CloseSalesButton(bool isMobile) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 300 : 330, isMobile ? 60 : 50),
        elevation: 3,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 20,
          vertical: isMobile ? 11 : 18,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock,
            color: Colors.white,
            size: isMobile ? 18 : 20,
          ),
          SizedBox(width: 8),
          Text(
            'Cerrar Ventas',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Card BuildCard(Map<String, dynamic> menuItem, int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
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
    );
  }
}
