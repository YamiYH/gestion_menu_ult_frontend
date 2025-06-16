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
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../controllers/menu/MenuController.dart';
import '../../widgets/Button.dart';
import '../../widgets/DynamicButton.dart';
import '../../widgets/PlaceDropDown.dart';
import '../../widgets/SmallButton.dart';
import '../../widgets/WhitePlaceDropDown.dart'; // Para formatear fechas

class GestionarTicket extends StatefulWidget {
  @override
  _GestionarTicketState createState() => _GestionarTicketState();
}

class _GestionarTicketState extends State<GestionarTicket> {

  TicketController _ticketController = TicketController();
  MenuEntityController _menuController = MenuEntityController();
  Map<MenuRecipe, bool> selectedItems = {};

  // Variables para los filtros
  String selectedCafeteria = 'Lenin';
  String selectedMealType = 'Almuerzo';
  DateTime? _reservationDay = DateTime.now().add(Duration(days: 1));
  Timer? _debounce;
  String? _qrDataString; // Los datos del QR en formato String (JSON)
  bool _isQrGenerating = true; // Flag para mostrar el spinner de carga del QR

  List<MenuEntity> availableMenus = [];
  List<TicketEntityResponse> myTickets = [];
  ProfileProvider _profileProvider = ProfileProvider();


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
      const TimeOfDay(hour: 22, minute: 0); // 10 PM
  final TimeOfDay _defaultHoraMaximaCancelacion =
      const TimeOfDay(hour: 13, minute: 0); // 1 PM

  late TimeOfDay _horaMaximaReservaConfig;
  late TimeOfDay _horaMaximaCancelacionConfig;

  @override
  void initState() {
    super.initState();
    _reservationDay = DateTime.now().add(Duration(days: 1));
    _horaMaximaReservaConfig = _defaultHoraMaximaReserva;
    _horaMaximaCancelacionConfig = _defaultHoraMaximaCancelacion;
    _loadConfiguredTimes();
    _searchMenus();
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
      'user': _profileProvider.userProfile?.username ?? 'No seleccionado',
      'userFullName': _profileProvider.userProfile?.fullName ?? 'No seleccionado',
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
                : MediaQuery.of(context).size.width * 0.8,
            height: isMobile
                ? MediaQuery.of(context).size.height * 0.45
                : MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: MediaQuery.of(context).size.width * 0.7,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                Text('Usuario: ${_profileProvider.userProfile?.fullName} ?? "No seleccionado"',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text(
                    'Total a pagar: \$${(data['totalPrice'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18)),
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
                  onPressed: () => {},
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
                  onPressed: () => {},
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

  Future<String> _generateQrBase64(String data) async {
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
        return base64Encode(picData.buffer.asUint8List());
      }
    }
    return '';
  }

  Future<void> _loadConfiguredTimes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    int? resHour = prefs.getInt('hora_maxima_reserva_hour');
    int? resMinute = prefs.getInt('hora_maxima_reserva_minute');
    TimeOfDay loadedReservationTime = (resHour != null && resMinute != null)
        ? TimeOfDay(hour: resHour, minute: resMinute)
        : _defaultHoraMaximaReserva;

    int? cancelHour = prefs.getInt('hora_maxima_cancelacion_hour');
    int? cancelMinute = prefs.getInt('hora_maxima_cancelacion_minute');
    TimeOfDay loadedCancellationTime =
        (cancelHour != null && cancelMinute != null)
            ? TimeOfDay(hour: cancelHour, minute: cancelMinute)
            : _defaultHoraMaximaCancelacion;

    setState(() {
      _horaMaximaReservaConfig = loadedReservationTime;
      _horaMaximaCancelacionConfig = loadedCancellationTime;
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

  // Función para reservar un menú
  void _reserveMenu(MenuEntity menu) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menú reservado:'
        ),
      ),
    );

    setState(() {
      // TODO Agregar el ticket
      for (var ingredient in menu.recipes) {
      }
    });

    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menú reservado: ',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return DefaultTabController(
        length: 2, // Número de pestañas
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Gestión de Tickets',
            bottom: buildTabBar(isMobile),
          ),
          body: buildTabBarView(isMobile, context),
        ));
  }

  TabBarView buildTabBarView(bool isMobile, BuildContext context) {
    return TabBarView(
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

  TabBar buildTabBar(bool isMobile) {
    return TabBar(
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
              onPressed: _isActionable
                  ? () => _processSale('Reservado')
                  : null, //
              text: 'Reservar',
              colorButton:
              _isActionable ? Colors.red.shade900 : Colors.grey, //
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
                          SmallButton(
                            size: Size(isMobile ? 110 : 140, 40),
                            onPressed: () {
                              _showTicketDetails(context, ticket);
                            },
                            text: 'Detalles',
                          ),
                          const SizedBox(width: 8),
                          // Espacio opcional entre botones
                          SmallButton(
                            size: Size(isMobile ? 110 : 140, 40),
                            onPressed: () {
                              Navigator.push(
                                  context, createFadeRoute(Payment()));
                            },
                            text: 'Pagar',
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
    bool canCancel = _canCancelReservation(ticket.date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;
        return AlertDialog(
          title: Center(
            child: Text(
              'Detalles de la Reserva',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 25),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                'Menú: ${ticket.date}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
              Text(
                'Ingredientes: ${ticket.recipes.join(", ")}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
            ],
          ),
          actions: [
            if (canCancel)
              TextButton(
                onPressed: () {
                  // Cancelar la reserva
                  _cancelReservation(ticket);
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                child: Text(
                  'CANCELAR RESERVA',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text(
                'CERRAR',
                style: TextStyle(
                    color: Colors.red.shade800,
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

// Función para verificar si se puede cancelar la reserva
  bool _canCancelReservation(String reservationDate) {
    final now = DateTime.now();
    final reservationDateTime = DateFormat('yyyy-MM-dd').parse(reservationDate);

    // Obtener la fecha límite para cancelar antes de la 1:00 PM del dia de reserva
    final cancelDeadline = DateTime(
      reservationDateTime.year,
      reservationDateTime.month,
      reservationDateTime.day,
      23, // 11:00 PM
    );

    // Permitir cancelar solo si la hora actual es antes de la fecha límite
    return now.isBefore(cancelDeadline);
  }

// Función para cancelar la reserva
  void _cancelReservation(TicketEntityResponse ticket) {
    setState(() {
      myTickets.remove(ticket); // Eliminar el ticket de la lista
    });

    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva cancelada: ${ticket.date}'),
      ),
    );
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
