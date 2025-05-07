import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para FilteringTextInputFormatter
import 'package:gestion_menu_ult_frontend/widgets/Button.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/DynamicButton.dart';

import '../../../widgets/SmallButton.dart';

class AprobarMenu extends StatefulWidget {
  @override
  State<AprobarMenu> createState() => _AprobarMenuState();
}

class _AprobarMenuState extends State<AprobarMenu> {
  // 1. Datos simulados con 'id' y 'price' (vendrían del backend)
  List<Map<String, dynamic>> menuItems = [
    {'id': 1, 'name': 'Plato 1', 'price': 10.50},
    {'id': 2, 'name': 'Plato 2', 'price': 8.75},
    {'id': 3, 'name': 'Plato 3', 'price': 12.00},
  ];

  // 2. Controladores para los precios editables
  // Usamos Map<int, TextEditingController> donde int es el id del plato
  Map<int, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in menuItems) {
      final int itemId = item['id'];
      final double initialPrice = item['price']?.toDouble() ?? 0.0;
      final controller = TextEditingController(
        text: initialPrice.toStringAsFixed(2), // Formato con 2 decimales
      );
      controller.addListener(_updateTotal);
      _priceControllers[itemId] = controller;
    }
  }

  // --- Función para actualizar el estado (y recalcular el total) ---
  void _updateTotal() {
    // Simplemente llama a setState para forzar la reconstrucción y
    // que el getter 'totalPrice' se vuelva a evaluar.
    setState(() {});
  }

  @override
  void dispose() {
    _priceControllers.values.forEach((controller) {
      controller.removeListener(_updateTotal);
      controller.dispose();
    });
    super.dispose();
  }

  double get totalPrice {
    double total = 0;
    _priceControllers.forEach((id, controller) {
      total += double.tryParse(controller.text) ?? 0.0;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
        appBar: CustomAppBar(title: 'Aprobar Menú'),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(isMobile ? 15.0 : 30.0),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MenuApprovalSection(isMobile, context),
                        BuildButtons(isMobile)
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          MenuApprovalSection(isMobile, context),
                          BuildButtons(isMobile),
                        ])),
        ));
  }

  Widget MenuApprovalSection(bool isMobile, BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        width: isMobile
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.65,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustar Precios', // Título más específico
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(height: 15),

            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final menuItem = menuItems[index];
                  final int itemId = menuItem['id'];
                  return BuildCard(menuItem, _priceControllers[itemId]!);
                }),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16, // Tamaño ligeramente menor
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30), // Espacio antes de los botones

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.grey[800]),
                  child: Text('Cancelar',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: isMobile ? 14 : 16,
                      )),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(width: 15), // Espacio entre botones
                SmallButton(
                  onPressed: () {
                    Map<int, double> updatedPrices = {};
                    _priceControllers.forEach((id, controller) {
                      updatedPrices[id] =
                          double.tryParse(controller.text) ?? 0.0;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Precios guardados')),
                    );
                  },
                  size: Size(isMobile ? 100 : 180, 40),
                  text: isMobile ? 'Guardar' : 'Guardar Cambios',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget BuildButtons(bool isMobile) {
    return Container(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.3,
      //padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          SizedBox(
            height: isMobile ? 50 : 20,
          ),
          DynamicButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'Aprobar',
              colorButton: Colors.green,
              icon: Icons.done,
              size: Size(isMobile ? 180 : 230, 50)),
          SizedBox(
            height: 20,
          ),
          Button(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: 'No Aprobar',
              icon: Icons.close,
              size: Size(isMobile ? 180 : 230, 50))
        ],
      ),
    );
  }

  Widget BuildCard(
      Map<String, dynamic> menuItem, TextEditingController priceController) {
    return Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300) // Borde ligero
            ),
        elevation: 1,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            menuItem['name'],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: SizedBox(
              width: 100,
              child: TextFormField(
                controller: priceController,
                // Asigna el controlador
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Permite números y un solo punto decimal
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  // Símbolo de dólar como prefijo
                  isDense: true,
                  // Hace el campo más compacto
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  // Relleno interno
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Borde cuando está habilitado
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Borde cuando tiene foco
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.red.shade900, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (double.tryParse(value!) == null) {
                    return 'Precio inválido';
                  }
                  return null;
                },
              )),
        ));
  }
}
