import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/menu/MenuController.dart';
import 'package:gestion_menu_ult_frontend/controllers/security/user/UserController.dart';
import 'package:gestion_menu_ult_frontend/controllers/ticket/TicketController.dart';
import 'package:gestion_menu_ult_frontend/models/UserEntity.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/menu/Ventas/MenuVenta.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../models/MenuEntity.dart';
import '../../../models/TicketEntity.dart';
import '../../../widgets/DynamicButton.dart';
import '../../../widgets/PlaceDropDown.dart';

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
  UserController userController = UserController();
  late TextEditingController userListController;
  Timer? _debounce; // El temporizador para el delay
  String? _qrDataString; // Los datos del QR en formato String (JSON)
  bool _isQrGenerating = true;
  String? selectedCafeteria = 'Lenin'; // Cafetería seleccionada por defecto
  final TicketController _ticketController = TicketController();
  final MenuEntityController _menuEntityController = MenuEntityController();

  // Estado para seguir los platos seleccionados
  Map<MenuRecipe, bool> selectedItems = {};

  // Lista simulada de nombres para el Autocomplete
  List<User> userList = [];

  // Nombre seleccionado
  String? selectedUser;
  String? selectedUserFullName;

  double get totalPrice {
    double total = 0;

    for (var entry in selectedItems.entries) {
      if (entry.value) {
        total += entry.key.price ?? 0.0;
      }
    }
    return total;
  }

  bool get _isActionable {
    return selectedUser != null && selectedItems.containsValue(true);
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _initializeUserList();
    _onDataChangedForQr();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeUserList() {
    userListController = TextEditingController();
    userListController.addListener(() {
      _onDataChangedForQr();
    });
  }

  Future<void> _fetchUsers() async {
    try {
      userList = await userController.getAllUsers();
      setState(() {});
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  String _generateQrDataString(String status) {
    // 1. Extraemos los nombres de los platos
    final List<String> recipeNames = [];
    for (var entry in selectedItems.entries) {
      if (entry.value) {
        recipeNames.add(entry.key.name as String);
      }
    }
    ;

    // 2. Creamos un mapa con toda la información
    final Map<String, dynamic> data = {
      'id': const Uuid().v4(), // Generamos un ID único para la venta
      'user': selectedUser ?? 'No seleccionado',
      'userFullName': selectedUserFullName ?? 'No seleccionado',
      'menuId': widget.menu!.id,
      'status': status,
      'date': widget.menu!.date,
      'recipes': recipeNames,
      'totalPrice': totalPrice, // Usamos el getter que ya calcula el total
    };

    // 3. Convertimos el mapa a un string en formato JSON
    return jsonEncode(data);
  }

  void _onDataChangedForQr() {
    // Si ya hay un timer corriendo, lo cancelamos para empezar de nuevo
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Mostramos el indicador de carga inmediatamente
    setState(() {
      _isQrGenerating = true;
    });

    // Creamos un nuevo timer con el delay de 1 segundo
    _debounce = Timer(const Duration(seconds: 1), () {
      // Cuando el timer termina, generamos los datos y actualizamos el estado
      final newData = _generateQrDataString('Reservado');
      if (mounted) {
        setState(() {
          _qrDataString = newData;
          _isQrGenerating = false; // Ocultamos el indicador de carga
        });
      }
    });
  }

  void _updateTotal() {
    setState(() {
      // Esta llamada a setState es para actualizar el precio total inmediatamente
    });
    // Adicionalmente, disparamos la lógica de regeneración del QR
    _onDataChangedForQr();
  }

  // NUEVO: Función para procesar la venta (Reservar/Pagar)
  Future<void> _processSale(String status) async {
    if (!_isActionable) return; // Doble chequeo de seguridad

    // Mostramos un spinner de carga modal para bloquear la UI
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (
        BuildContext context,
      ) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.red));
      },
    );

    // Generamos el QR final de forma síncrona (sin debounce)
    final finalQrData = _generateQrDataString(status);

    // Esperamos un instante para que el usuario perciba la acción
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    Navigator.of(context).pop(); // Cerramos el spinner de carga

    // Mostramos el modal de confirmación
    try {
      _showConfirmationDialog(finalQrData);
    } on Exception catch (e, stackTrace) {
      stackTrace.toString();
    }
  }

  // NUEVO: Función para mostrar el modal de confirmación
  Future<void> _showConfirmationDialog(String qrData) async {
    final data = jsonDecode(qrData);
    bool isMobile = MediaQuery.of(context).size.width < 600;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Confirmar',
              style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24),
            ),
          ),
          content: SizedBox(
            width: isMobile
                ? MediaQuery.of(context).size.width * 0.9
                : MediaQuery.of(context).size.width * 0.2,
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.45
                : MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: isMobile
                      ? MediaQuery.of(context).size.width * 0.7
                      : MediaQuery.of(context).size.width * 0.2,
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: isMobile ? 20 : 10),
                Text('Usuario: $selectedUserFullName',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                    'Total a pagar: \$${(data['totalPrice'] as double).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18)),
                //const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            isMobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DynamicButton(
                        onPressed: () => {
                          _generateDataAndPush(qrData),
                          _isQrGenerating = true, // Mostrar spinner de carga
                        },
                        text: 'Confirmar',
                        colorButton: Colors.green,
                        size: Size(isMobile ? 250 : 160, 50),
                      ),
                      SizedBox(height: 10),
                      DynamicButton(
                        onPressed: () => {Navigator.of(context).pop()},
                        text: 'Cancelar',
                        colorButton: Colors.red[900]!,
                        size: Size(isMobile ? 250 : 160, 50),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DynamicButton(
                        onPressed: () => {
                          _generateDataAndPush(qrData),
                          _isQrGenerating = true, // Mostrar spinner de carga
                        },
                        text: 'Confirmar',
                        colorButton: Colors.green,
                        size: Size(160, 50),
                      ),
                      SizedBox(width: 10),
                      DynamicButton(
                        onPressed: () => {Navigator.of(context).pop()},
                        text: 'Cancelar',
                        colorButton: Colors.red[900]!,
                        size: Size(160, 50),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }

  Future<void> _generateDataAndPush(String data) async {
    String qrImageBase64 = '';
    try {
      final qrValidationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );
      if (qrValidationResult.status == QrValidationStatus.valid) {
        final painter = QrPainter.withQr(
          qr: qrValidationResult.qrCode!,
          color: const Color(0xFF000000),
          emptyColor: const Color(0xFFFFFFFF),
          gapless: true,
        );
        final picData = await painter.toImageData(400, format: ImageByteFormat.png);
        if (picData != null) {
          qrImageBase64 = base64Encode(picData.buffer.asUint8List());
        }
      }
      Map<String, dynamic> dataMap = jsonDecode(data);
      TicketEntityRequest request = TicketEntityRequest(
        id: const Uuid().v4(),
        user: dataMap['user'] as String,
        campus: selectedCafeteria,
        menu: dataMap['menuId'] as String,
        status: dataMap['status'] as String,
        recipes: selectedItems.keys.map((e) => e.id as String).toList(),
        totalPrice: totalPrice,
        qr: qrImageBase64,
      );
      await _ticketController.createTicket(request.toJson());
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _qrDataString = data;
          _isQrGenerating = false; // Ocultamos el spinner de carga
        });
        resetFields();
      }
    }  catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usted ya tiene un ticket reservado para esa fecha.'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
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
            // Usamos un AnimatedSwitcher para una transición suave entre el spinner y el QR
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isQrGenerating
                  ? const CircularProgressIndicator(
                      color: Colors.red) // Muestra el spinner
                  : QrImageView(
                      // Muestra el QR cuando está listo
                      key: ValueKey(_qrDataString),
                      // Key para que la animación funcione
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
          SizedBox(height: 15),
          // Buscador de Usuarios
          SizedBox(
            width: isMobile
                ? MediaQuery.of(context).size.width * 0.85
                : MediaQuery.of(context).size.width * 0.20,
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.08
                : MediaQuery.of(context).size.height * 0.08,
            child: SingleChildScrollView(
              child: Autocomplete<User>(
                displayStringForOption: (User option) =>
                    '${option.name} ${option.lastName}',
                initialValue: TextEditingValue(text: userListController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<User>.empty();
                  }
                  return userList.where((User option) =>
                      '${option.name} ${option.lastName}'
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (User selection) {
                  setState(() {
                    selectedUser = selection.username;
                    selectedUserFullName =
                        '${selection.name} ${selection.lastName}';
                  });
                  if(isMobile){
                    Focus.of(context).unfocus();
                  }
                  _updateTotal();
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
              ),
            ),
          ),
          const SizedBox(height: 10),
          PlaceDropDown(
              widthFactor1: 0.2,
              widthFactor: 0.85,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCafeteria = newValue!;
                });
              },
              value: 'Lenin'),
          const SizedBox(height: 25),
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
                    onPressed: _isActionable
                        ? () => _processSale('Reservado')
                        : null, //
                    text: 'Reservar',
                    colorButton:
                        _isActionable ? Colors.red.shade900 : Colors.grey, //
                    size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50),
                  ),
                  SizedBox(height: 15),
                  DynamicButton(
                      onPressed: _isActionable
                          ? () => _processSale('Pago')
                          : null, // Lógica aquí
                      text: 'Pagar',
                      colorButton:
                          _isActionable ? Colors.red.shade900 : Colors.grey,
                      size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50)),
                  SizedBox(height: 15),
                  CloseSalesButton(isMobile)
                ])
              : Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      DynamicButton(
                        onPressed: _isActionable
                            ? () => _processSale('Reservado')
                            : null, // Lógica aquí
                        text: 'Reservar',
                        colorButton: _isActionable
                            ? Colors.red.shade900
                            : Colors.grey, // Estilo deshabilitado
                        size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50),
                      ),
                      const SizedBox(width: 10),
                      DynamicButton(
                          onPressed: _isActionable
                              ? () => _processSale('Pago')
                              : null, // Lógica aquí
                          text: 'Pagar',
                          colorButton: _isActionable
                              ? Colors.red.shade900
                              : Colors.grey, // Estilo deshabilitado
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
      onPressed: () {
      showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar cierre de ventas'),
                      content: const Text('¿Estás seguro de cerrar las ventas? Esta acción marcará el menú como vendido.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Cambiar el estado del menú a "Vendido"
                            await _menuEntityController.changeStatusMenu(
                              widget.menu!.id as String, 'Vendido');
                            Navigator.of(context).pop();
                            Navigator.of(context).pushReplacement(createFadeRoute(MenuVentas()));
                          },
                          child: const Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
      },
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

  // Función para dejar todos los campos por defecto
  void resetFields() {
    setState(() {
      // Limpiar campo de usuario
      userListController.clear();
      userListController.text = '';
      selectedUser = null;
      selectedUserFullName = null;
      // Desmarcar todos los checkbox
      selectedItems = {for (var item in widget.menu!.recipes) item: false};
      // Reiniciar cafetería seleccionada si lo deseas
      selectedCafeteria = 'Lenin';
      // Regenerar QR
      _onDataChangedForQr();
    });
  }
}
