import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/menu_card.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class ReservarTicket extends StatefulWidget {
  @override
  _ReservarTicketState createState() => _ReservarTicketState();
}

class _ReservarTicketState extends State<ReservarTicket> {
  // Variables para los filtros
  String selectedCafeteria = 'Lenin'; // Comedor seleccionado
  String selectedMealType = 'Desayuno'; // Tipo de comida seleccionado
  DateTime? startDate; // Fecha inicial
  DateTime? endDate; // Fecha final
  // Lista simulada de menús disponibles
  List<Map<String, dynamic>> availableMenus = [];

  // Función para buscar menús según los filtros
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Reservar Ticket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 20 : 25,
          ),
        ),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior con opciones (responsive)
              isMobile
                  ? Column(children: _buildOptions(context, isMobile))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildOptions(context, isMobile),
                    ),
              SizedBox(height: 30),

              // Lista de menús disponibles
              Text(
                'Menús Disponibles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    return MenuCard(
                      menu: menu,
                      onIngredientChanged: (updateData) {
                        // Actualizar el estado cuando un ingrediente cambia
                        setState(() {
                          final ingredient = updateData['ingredient'];
                          ingredient['selected'] = updateData['value'];
                        });
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir las opciones (responsive)
  List<Widget> _buildOptions(BuildContext context, bool isMobile) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dropdown para Comedor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionTitle('Comedor', Icons.restaurant_menu),
              SizedBox(height: 8),
              SizedBox(
                width: isMobile ? 150 : 200,
                height: 65,
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
                      icon: Icon(Icons.arrow_drop_down_circle,
                          color: Colors.red[900]),
                      dropdownColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 20),
          // Dropdown para Menú
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionTitle('Menú', Icons.food_bank),
              SizedBox(height: 8),
              SizedBox(
                width: isMobile ? 150 : 200,
                height: 65,
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
                      icon: Icon(Icons.arrow_drop_down_circle,
                          color: Colors.red[900]),
                      dropdownColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      isExpanded: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      SizedBox(height: 20),
      // Selector de fechas con iconos
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 30)),
              );
              if (pickedDate != null) {
                setState(() {
                  startDate = pickedDate;
                });
              }
            },
            icon: Icon(Icons.calendar_today, color: Colors.red[900]),
            label: Text(
              startDate == null
                  ? 'Desde'
                  : DateFormat('yyyy-MM-dd').format(startDate!),
              style: TextStyle(fontSize: 14, color: Colors.red[900]),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(Duration(days: 30)),
              );
              if (pickedDate != null) {
                setState(() {
                  endDate = pickedDate;
                });
              }
            },
            icon: Icon(Icons.calendar_today, color: Colors.red[900]),
            label: Text(
              endDate == null
                  ? 'Hasta'
                  : DateFormat('yyyy-MM-dd').format(endDate!),
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[900],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 20),
      // Botón BUSCAR
      ElevatedButton(
        onPressed: () {
          if (startDate != null && endDate != null) {
            _searchMenus();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selecciona un rango de fechas')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          elevation: 3,
          backgroundColor: Colors.red[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 30 : 50,
            vertical: 15,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          // Asegura que los elementos estén juntos
          children: [
            Icon(Icons.search, color: Colors.white, size: 20),
            // Ícono de búsqueda
            SizedBox(width: 8),
            // Espaciado entre el ícono y el texto
            Text(
              'BUSCAR',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
            // Texto del botón
          ],
        ),
      ),
    ];
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
