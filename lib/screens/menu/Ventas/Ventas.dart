import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/MenuEntity.dart';
import '../../../widgets/DynamicButton.dart';

class Ventas extends StatefulWidget {
  final MenuEntity? menu;

  const Ventas({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<Ventas> createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  Timer? _debounce; // El temporizador para el delay
  String? _qrDataString; // Los datos del QR en formato String (JSON)
  bool _isQrGenerating = true; // Flag para mostrar el spinner de carga del QR

  // Estado para seguir los platos seleccionados
  Map<MenuRecipe, bool> selectedItems = {};

  // Lista simulada de nombres para el Autocomplete
  List<String> userNames = [];

  // Nombre seleccionado
  String? selectedUser;

  double get totalPrice {
    double total = 0;

    for (var entry in selectedItems.entries) {
      if (entry.value) {
        total += entry.key.price ?? 0.0;
      }
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _onDataChangedForQr();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _generateQrDataString() {
    final List<String> recipeNames = [];
    for (var entry in selectedItems.entries) {
      if (entry.value) {
        recipeNames.add(entry.key.name as String);
      }
    }
    ;

    final Map<String, dynamic> data = {
      'menuId': widget.menu!.id,
      'date': widget.menu!.date,
      'type': widget.menu!.type,
      'recipes': recipeNames,
      'totalPrice': totalPrice,
    };

    return jsonEncode(data);
  }

  void _onDataChangedForQr() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    setState(() {
      _isQrGenerating = true;
    });

    _debounce = Timer(const Duration(seconds: 1), () {
      final newData = _generateQrDataString();
      if (mounted) {
        setState(() {
          _qrDataString = newData;
          _isQrGenerating = false;
        });
      }
    });
  }

  void _updateTotal() {
    setState(() {});

    _onDataChangedForQr();
  }

  Widget _buildQrSection(bool isMobile) {
    double size = isMobile
        ? MediaQuery.of(context).size.width * 0.67
        : MediaQuery.of(context).size.width * 0.19;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: size,
            height: size,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isQrGenerating
                  ? const CircularProgressIndicator(color: Colors.red)
                  : QrImageView(
                      key: ValueKey(_qrDataString),
                      data: _qrDataString!,
                      version: QrVersions.auto,
                      size: size,
                      backgroundColor: Colors.white,
                    ),
            ),
          ),
        ),
      ],
    );
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildSales(isMobile, context),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Platos Disponibles',
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
                  itemCount: widget.menu!.recipes.length,
                  itemBuilder: (context, index) {
                    final menuItem = widget.menu!.recipes[index];
                    return BuildCard(menuItem, menuItem.id as String);
                  }),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Total: \$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
          SizedBox(
            width: isMobile
                ? MediaQuery.of(context).size.width * 0.85
                : MediaQuery.of(context).size.width * 0.20,
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.08
                : MediaQuery.of(context).size.height * 0.08,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red[900]!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                widget.menu!.date,
                style: TextStyle(
                    color: Colors.red[900]!,
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 30),
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
                          borderRadius: BorderRadius.circular(5)),
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
              child: _buildQrSection(isMobile)),
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

  Card BuildCard(MenuRecipe menuItem, String index) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          menuItem.name as String,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '\$${menuItem.price}',
          style: TextStyle(fontSize: 22),
        ),
        trailing: Checkbox(
          activeColor: Colors.red,
          value: selectedItems[menuItem] ?? false,
          onChanged: (value) {
            setState(() {
              selectedItems[menuItem] = value!;
            });
            _updateTotal();
          },
        ),
      ),
    );
  }
}
