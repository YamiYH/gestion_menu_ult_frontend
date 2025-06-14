import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/admin/Configuracion/Payment.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';
import 'package:gestion_menu_ult_frontend/widgets/DatePickerButton.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/Button.dart';
import '../../widgets/SmallButton.dart'; // Para formatear fechas

class GestionarTicket extends StatefulWidget {
  @override
  _GestionarTicketState createState() => _GestionarTicketState();
}

class _GestionarTicketState extends State<GestionarTicket> {
  // Variables para los filtros
  String selectedCafeteria = 'Lenin';
  String selectedMealType = 'Almuerzo';
  DateTime? startDate;
  DateTime? endDate;

  List<Map<String, dynamic>> availableMenus = [];
  List<Map<String, dynamic>> myTickets = [];

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
    _horaMaximaReservaConfig = _defaultHoraMaximaReserva;
    _horaMaximaCancelacionConfig = _defaultHoraMaximaCancelacion;
    _loadConfiguredTimes();
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

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a', 'es_ES').format(dt); // Formato AM/PM
  }

  void _searchMenus() {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona un rango de fechas')),
      );
      return;
    }

    setState(() {
      availableMenus = [
        {
          'id': 'menu1_${DateFormat('yyyy-MM-dd').format(startDate!)}',
          // ID único
          'price': 150.0,
          // Precio de ejemplo
          'cafeteria': selectedCafeteria,
          'mealType': selectedMealType,
          'date': DateFormat('yyyy-MM-dd').format(startDate!),
          'menu': 'Menú 1',
          'ingredients': [
            {'name': 'Arroz', 'selected': false},
            {'name': 'Pollo', 'selected': false},
            {'name': 'Ensalada', 'selected': false},
          ],
        },
        {
          'id': 'menu2_${DateFormat('yyyy-MM-dd').format(endDate!)}',
          // ID único
          'price': 120.50,
          // Precio de ejemplo
          'cafeteria': selectedCafeteria,
          'mealType': selectedMealType,
          'date': DateFormat('yyyy-MM-dd').format(endDate!),
          'menu': 'Menú 2',
          'ingredients': [
            {'name': 'Pasta', 'selected': false},
            {'name': 'Salsa', 'selected': false},
            {'name': 'Queso', 'selected': false},
          ],
        },
      ];
    });
  }

  // Función para reservar un menú
  void _reserveMenu(Map<String, dynamic> menu) {
    final selectedIngredients = menu['ingredients']
        .where((ingredient) => ingredient['selected'] == true)
        .map((ingredient) => ingredient['name'])
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menú reservado: ${menu['menu']} con ${selectedIngredients.join(", ")}',
        ),
      ),
    );

    setState(() {
      myTickets.add({
        'cafeteria': menu['cafeteria'],
        'mealType': menu['mealType'],
        'date': menu['date'],
        'menu': menu['menu'],
        'ingredients': selectedIngredients,
      });
    });

    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Menú reservado: ${menu['menu']} con ${selectedIngredients.join(", ")}',
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
                SizedBox(height: isMobile ? 10 : 50),
                Text(
                  'Menús Disponibles:',
                  style: TextStyle(
                      fontSize: isMobile ? 15 : 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (availableMenus.isEmpty)
                  Center(child: Text('No hay menús disponibles'))
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
        fontSize: isMobile ? 15 : 20,
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
              borderRadius: BorderRadius.circular(10),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Mis Tickets'),
          ),
        ),
      ],
    );
  }

  Card buildCardMenu(
      Map<String, dynamic> menu, bool isMobile, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(
              menu['menu'],
              style: TextStyle(
                  fontSize: isMobile ? 14 : 17,
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${menu['cafeteria']} - ${menu['mealType']} (${menu['date']})',
              style: TextStyle(
                  fontSize: isMobile ? 13 : 16, fontStyle: FontStyle.italic),
            ),
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
                ...menu['ingredients'].map((ingredient) {
                  return CheckboxListTile(
                    title: Text(
                      ingredient['name'],
                      style: TextStyle(fontSize: isMobile ? 13 : 16),
                    ),
                    value: ingredient['selected'],
                    activeColor: Colors.red,
                    onChanged: (bool? value) {
                      setState(() {
                        ingredient['selected'] = value!;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          //SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: SmallButton(
              size: Size(isMobile ? 110 : 150, 40),
              onPressed: () {
                if (DateTime.now().hour >= 23) {
                  // 23 = 11:00 PM
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Reservas disponibles solo hasta la 11:00 PM')),
                  );
                } else {
                  _reserveMenu(menu); // Lógica de reserva
                }
              },
              text: 'Reservar',
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  SingleChildScrollView buildSingleChildScrollView(isMobile) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            if (myTickets.isEmpty)
              const Center(child: Text('No tienes tickets'))
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
                        ticket['menu'],
                        style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${ticket['cafeteria']} - ${ticket['mealType']} (${ticket['date']})'),
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
  void _showTicketDetails(BuildContext context, Map<String, dynamic> ticket) {
    bool canCancel = _canCancelReservation(ticket['date']);

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
                'Comedor: ${ticket['cafeteria']}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
              Text(
                'Tipo de Comida: ${ticket['mealType']}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
              Text(
                'Fecha: ${ticket['date']}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
              Text(
                'Menú: ${ticket['menu']}',
                style: TextStyle(fontSize: isMobile ? 14 : 18),
              ),
              Text(
                'Ingredientes: ${ticket['ingredients'].join(", ")}',
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
                      color: Colors.red.shade800,
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold),
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
  void _cancelReservation(Map<String, dynamic> ticket) {
    setState(() {
      myTickets.remove(ticket); // Eliminar el ticket de la lista
    });

    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva cancelada: ${ticket['menu']}'),
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
          // Dropdown para Comedor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildOptionTitle('Comedor', Icons.restaurant_menu),
              SizedBox(height: 8),
              PlaceDropDown(isMobile),
            ],
          ),
          SizedBox(width: 20),
          // Dropdown para Menú
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              _buildOptionTitle('Menú', Icons.food_bank),
              SizedBox(height: 8),
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
              label: 'Desde',
              selectedDate: startDate,
              onDateSelected: (date) {
                setState(() {
                  startDate = date;
                });
              },
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 30))),
          SizedBox(width: isMobile ? 10 : 20),
          Icon(Icons.arrow_forward, color: Colors.red[900]),
          SizedBox(width: isMobile ? 10 : 20),
          DatePickerButton(
            label: 'Hasta',
            selectedDate: endDate,
            onDateSelected: (date) {
              setState(() {
                endDate = date;
              });
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 30)),
          ),
        ],
      ),
      SizedBox(height: 20, width: isMobile ? 20 : 40),
      // Botón BUSCAR
      Button(
        icon: Icons.search,
        text: 'BUSCAR',
        onPressed: () {
          if (startDate != null && endDate != null) {
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

  SizedBox PlaceDropDown(bool isMobile) {
    return SizedBox(
      width: isMobile ? 150 : 200,
      height: isMobile ? 65 : 50,
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
            value: selectedCafeteria,
            onChanged: (String? newValue) {
              setState(() {
                selectedCafeteria = newValue!;
              });
            },
            items: ['Lenin', 'Pepito Tey']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 18)),
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

  SizedBox FoodDropDown(bool isMobile) {
    return SizedBox(
      width: isMobile ? 150 : 200,
      height: isMobile ? 65 : 50,
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
                child: Text(value, style: TextStyle(fontSize: 18)),
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
