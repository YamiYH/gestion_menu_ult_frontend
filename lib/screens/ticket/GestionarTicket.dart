import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/controllers/ticket/TicketController.dart';
import 'package:gestion_menu_ult_frontend/models/MenuEntity.dart';
import 'package:gestion_menu_ult_frontend/models/TicketEntity.dart';
import 'package:gestion_menu_ult_frontend/models/UserProfile.dart';
import 'package:gestion_menu_ult_frontend/providers/ProfileProvider.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Configuracion/Payment.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/DatePickerButton.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/menu/MenuController.dart';
import '../../controllers/security/user/UserAuthContext.dart';
import '../../widgets/Button.dart';
import '../../widgets/DynamicButton.dart';
import '../../widgets/SmallButton.dart';
import '../../widgets/WhitePlaceDropDown.dart'; // Para formatear fechas

class GestionarTicket extends StatefulWidget {
  @override
  _GestionarTicketState createState() => _GestionarTicketState();
}

class _GestionarTicketState extends State<GestionarTicket> with TickerProviderStateMixin{

  TicketController _ticketController = TicketController();
  MenuEntityController _menuController = MenuEntityController();
  Map<MenuRecipe, bool> selectedItems = {};

  late TabController _tabController;

  // Variables para los filtros
  String selectedCafeteria = 'Lenin';
  String selectedMealType = 'Almuerzo';
  DateTime? _reservationDay = DateTime.now().add(Duration(days: 1));
  Timer? _debounce;
  String? _qrDataString; // Los datos del QR en formato String (JSON)
  bool _isQrGenerating = true; // Flag para mostrar el spinner de carga del QR

  List<MenuEntity> availableMenus = [];
  List<TicketEntityResponse> myTickets = [];
  late UserProfile _user;


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
    return selectedItems.containsValue(true);
  }

  // Valores por defecto internos si el admin no configura
  final TimeOfDay _defaultHoraMaximaReserva =
      const TimeOfDay(hour: 13, minute: 0);

  late TimeOfDay _horaMaximaReservaConfig;

  @override
  void initState() {
    super.initState();
    _reservationDay = DateTime.now().add(Duration(days: 1));
    _horaMaximaReservaConfig = _defaultHoraMaximaReserva;
    _tabController = TabController(length: 2, vsync: this);
    _loadMyTicketsAndNavigate(false);
    _searchMenus();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      'user': _user.username,
      'userFullName': _user.fullName,
      'menuId': availableMenus.isNotEmpty
          ? availableMenus.first.id
          : 'No disponible', // Usamos el primer menú disponible
      'status': status,
      'date': availableMenus.isNotEmpty
          ? availableMenus.first.date
          : 'No disponible', // Usamos el primer menú disponible
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
                Text('Usuario: ${_user.fullName}',
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
                    _generateDataAndPush(qrData)
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
                    _generateDataAndPush(qrData)
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
        user: _user.username,
        campus: selectedCafeteria,
        menu: dataMap['menuId'] as String,
        status: 'Reservado',
        recipes: selectedItems.keys.map((e) => e.id as String).toList(),
        totalPrice: totalPrice,
        qr: qrImageBase64,
      );
      await _ticketController.createTicket(request.toJson());
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _loadMyTicketsAndNavigate(true);
        });
      }
    }  catch (e) {
      Navigator.pop(context);
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text('Usted ya tiene un ticket reservado para esa fecha.'),
         backgroundColor: Colors.red[700],
       ),
     );
     _loadMyTicketsAndNavigate(true);
    }
  }

  Future<void> _loadMyTicketsAndNavigate(bool navigate) async {
    String? username = '';
   try {
     username = _user.username;
   } catch (e) {
     username = await UserAuthContext.getUsername();
   }
    Map<String, String> filters = {
      'status': 'Reservado',
      'otherStatus': 'Pago',
      'user': username!,
    };
    return _ticketController.fetchTickets(filters: filters).then((tickets) {
      if (mounted) {
        setState(() {
          myTickets = tickets;
        });
        if (navigate) {
          _tabController.animateTo(1);
        }
      }

    }).catchError((error) {
      print('Error al cargar los tickets: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los tickets')),
      );
    });
  }


  Future<void> _searchMenus() async {

    setState(() {
      availableMenus.clear();// Limpiar la lista antes de buscar
    });

    Map<String, String> filters = {
      "status": "Aprobado",
      "otherStatus": "Venta",
      "category": "Trabajadores",
      'date': DateFormat('yyyy-MM-dd').format(_reservationDay!),
    };
    availableMenus = await _menuController.fetchMenu(filters: filters);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    final profileProvider = Provider.of<ProfileProvider>(context);
    _user = profileProvider.userProfile!;
    return Scaffold(
          appBar: CustomAppBar(
            title: 'Gestión de Tickets',
            bottom: buildTabBar(isMobile, _tabController),
          ),
          body: buildTabBarView(isMobile, context, _tabController),
        );
  }

  TabBarView buildTabBarView(bool isMobile, BuildContext context, TabController controller) {
    return TabBarView(
      controller: controller,
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isMobile
                    ? Column(children: _buildOptions(context, isMobile))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _buildOptions(context, isMobile),
                      ),
                SizedBox(height: isMobile ? 20 : 50),
                Text(
                  'Menús Disponibles:',
                  style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (availableMenus.isEmpty)
                  Column(
                    children: [
                      SizedBox(height: 100),
                      Center(
                          child: Text(
                        'No hay menús disponibles',
                        style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: isMobile ? 16 : 18),
                      )),
                    ],
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: availableMenus.length,
                    itemBuilder: (context, index) {
                      final menu = availableMenus[index];
                      return buildCardMenu(menu, isMobile, context);
                    },
                  ),
              ],
            ),
          ),
        ),

        // Pestaña "Mis Tickets"
        buildSingleChildScrollView(isMobile),
      ],
    );
  }

  TabBar buildTabBar(bool isMobile, TabController controller) {
    return TabBar(
      controller: controller,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Colors.white,
      ),
      labelStyle: TextStyle(
        fontSize: isMobile ? 16 : 20,
        fontWeight: FontWeight.bold,
      ),
      labelColor: Colors.red[900],
      unselectedLabelColor: Colors.white,
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      tabs: [
        Tab(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              'Reservar Ticket',
            ),
          ),
        ),
        Tab(
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text('Mis Tickets'),
          ),
        ),
      ],
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
            setState(() {
              _updateTotal();
            });
          },
        ),
      ),
    );
  }

  Card buildCardMenu(
      MenuEntity menu, bool isMobile, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: ListTile(
                title: Text(
                  menu.date,
                  style: TextStyle(
                      fontSize: isMobile ? 14 : 17,
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${menu.type} (${menu.category})',
                  style: TextStyle(
                      fontSize: isMobile ? 13 : 16, fontStyle: FontStyle.italic),
                ),
              ),),
              Padding(padding: EdgeInsets.all(20),
              child:Row (
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 10),
                  _buildOptionTitle('Comedor', Icons.restaurant_menu),
                  SizedBox(width: 20),
                  WhitePlaceDropDown(
                    widthFactor1: 0.13,
                    widthFactor: 0.38,
                    value: selectedCafeteria,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCafeteria = newValue!;
                      });
                    },
                  ),
                ],
              ),
              ),

            ],
          ),
          Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Platos:',
                  style: TextStyle(
                      fontSize: isMobile ? 14 : 17,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: menu.recipes.length,
                    itemBuilder: (context, index) {
                      final menuItem = menu.recipes[index];
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
                SizedBox(height: 10),
                Divider(),
              ],
            ),
          ),
          //SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: DynamicButton(
              onPressed: _isActionable && _canCreateOrCancelReservation(menu.date)
                  ? () => _processSale('Reservado')
                  : null, //
              text: 'Reservar',
              colorButton:
              _isActionable && _canCreateOrCancelReservation(menu.date) ? Colors.red.shade900 : Colors.grey, //
              size: Size(isMobile ? 300 : 160, isMobile ? 60 : 50),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  //Contruye la lista de Tickets
  SingleChildScrollView buildSingleChildScrollView(isMobile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (myTickets.isEmpty)
              Column(
                children: [
                  SizedBox(height: 100),
                  Center(
                      child: Text('No tienes tickets',
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: isMobile ? 16 : 18))),
                ],
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myTickets.length,
                itemBuilder: (context, index) {
                  final ticket = myTickets[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        ticket.date,
                        style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${ticket.campus} - ${ticket.menuType} (${ticket.date})'),
                      trailing: Row(
                        // Eliminado Expanded
                        mainAxisSize: MainAxisSize.min,
                        // Hace que el Row ocupe solo el espacio necesario para sus hijos
                        children: [
                          DynamicButton(
                            onPressed: () {_showTicketDetails(context, ticket);}, //
                            text: 'Detalles',
                            colorButton: Colors.red.shade900, //
                            size: Size(isMobile ? 110 : 140, 50),
                          ),
                          const SizedBox(width: 10),
                          // Espacio opcional entre botones
                          DynamicButton(
                            onPressed: ticket.status == 'Reservado'
                                ? () {Navigator.push(context, createFadeRoute(Payment(ticket: ticket)));}
                                : null, //
                            text: 'Pagar',
                            colorButton: ticket.status == 'Reservado' ? Colors.green : Colors.grey, //
                            size: Size(isMobile ? 110 : 140, 50),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Función para mostrar los detalles del ticket
 void _showTicketDetails(BuildContext context, TicketEntityResponse ticket) {
    bool canCancel = _canCreateOrCancelReservation(ticket.date) && ticket.status != 'Pago';
    TextEditingController confirmController = TextEditingController();
    ValueNotifier<bool> isConfirmEnabled = ValueNotifier<bool>(false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Center(
                child: Text(
                  'Detalles del Ticket',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 25),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ticket.qrImage.isNotEmpty)
                      Center(
                        child: Image.memory(
                          base64Decode(ticket.qrImage),
                          width: isMobile ? 180 : 300,
                          height: isMobile ? 180 : 300,
                          fit: BoxFit.contain,
                        ),
                      ),
                    const SizedBox(height: 15),
                    Text(
                      'Usuario: ${ticket.userFullName}',
                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Comedor: ${ticket.campus}',
                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                    ),
                    Text(
                      'Tipo de Comida: ${ticket.menuType}',
                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                    ),
                    Text(
                      'Fecha: ${ticket.date}',
                      style: TextStyle(fontSize: isMobile ? 14 : 18),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nota: Para obtener más detalles, escanea el código QR.',
                      style: TextStyle(fontSize: isMobile ? 14 : 18, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                    ),
                    if (ticket.status == 'Reservado' && _canCreateOrCancelReservation(ticket.date)) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Para cancelar la reserva, escribe CANCELAR en mayúsculas:',
                        style: TextStyle(fontSize: isMobile ? 13 : 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmController,
                        onChanged: (value) {
                          setState(() {
                            isConfirmEnabled.value = value.trim() == 'CANCELAR';
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'CANCELAR',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                if (canCancel)
                  ValueListenableBuilder<bool>(
                    valueListenable: isConfirmEnabled,
                    builder: (context, enabled, _) {
                      return DynamicButton(
                        onPressed: (ticket.status == 'Reservado' && !enabled)
                            ? null
                            : () {
                                _cancelReservation(ticket);
                                Navigator.of(context).pop();
                              },
                        text: 'Cancelar Reserva',
                        colorButton: enabled || ticket.status == 'Pago'
                            ? Colors.red.shade900
                            : Colors.grey,
                        size: Size(isMobile ? 300 : 200, isMobile ? 60 : 50),
                      );
                    },
                  ),
                DynamicButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  text: 'Cerrar',
                  colorButton: Colors.green,
                  size: Size(isMobile ? 300 : 150, isMobile ? 60 : 50),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Función para verificar si se puede cancelar la reserva
bool _canCreateOrCancelReservation(String reservationDate) {
  final now = DateTime.now();
  final reservationDateTime = DateFormat('yyyy-MM-dd').parse(reservationDate);
  final createOrCancelLimit = DateTime(
    reservationDateTime.year,
    reservationDateTime.month,
    reservationDateTime.day,
    _defaultHoraMaximaReserva.hour,
    _defaultHoraMaximaReserva.minute,
  ).subtract(const Duration(days: 1));
  return now.isBefore(createOrCancelLimit);
}

// Función para cancelar la reserva
  Future<void> _cancelReservation(TicketEntityResponse ticket) async {
    setState(() {
      myTickets.remove(ticket);// Eliminar el ticket de la lista
    });
    await _ticketController.deleteTicket(ticket.id); // Llamada al controlador para eliminar el ticket
    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva cancelada: ${ticket.date}'),
      ),
    );
    _loadMyTicketsAndNavigate(false);
  }

  // Método para construir las opciones (responsive)
  List<Widget> _buildOptions(BuildContext context, bool isMobile) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 20),
          // Dropdown para Menú
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildOptionTitle('Menú', Icons.food_bank),
              SizedBox(height: 10),
              FoodDropDown(isMobile),
            ],
          ),
        ],
      ),
      SizedBox(height: 20, width: isMobile ? 20 : 40),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DatePickerButton(
              label: 'Fecha',
              selectedDate: _reservationDay,
              onDateSelected: (date) {
                setState(() {
                  _reservationDay = date;
                });
              },
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 30))),
          SizedBox(width: isMobile ? 10 : 20),
        ],
      ),
      SizedBox(height: 20, width: isMobile ? 20 : 40),
      // Botón BUSCAR
      Button(
        icon: Icons.search,
        text: 'Buscar',
        onPressed: () {
          if (_reservationDay != null) {
            _searchMenus();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selecciona un rango de fechas')),
            );
          }
        },
      )
    ];
  }

  SizedBox FoodDropDown(bool isMobile) {
    return SizedBox(
      width: isMobile ? 150 : 200,
      height: isMobile ? 60 : 50,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMealType,
            onChanged: (String? newValue) {
              setState(() {
                selectedMealType = newValue!;
              });
            },
            items: ['Desayuno', 'Almuerzo', 'Comida']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 17)),
              );
            }).toList(),
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.red[900]),
            dropdownColor: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  // Método para crear títulos con iconos
  Widget _buildOptionTitle(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.red[900], size: 24),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[900],
          ),
        ),
      ],
    );
  }
}
