import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/ScheduleButton.dart';

import '../../../widgets/Button.dart';
import '../../../widgets/CustomAppbar.dart';

class MenuConfig extends StatefulWidget {
  const MenuConfig({Key? key}) : super(key: key);

  @override
  State<MenuConfig> createState() => _MenuConfigState();
}

class _MenuConfigState extends State<MenuConfig> {
  // Variables para almacenar los horarios
  TimeOfDay _horaReserva =
      TimeOfDay(hour: 8, minute: 0); // Hora inicial por defecto
  TimeOfDay _horaCancelacion = TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _horaVentaAlmuerzo = TimeOfDay(hour: 12, minute: 0);

  // Método para abrir el TimePicker
  Future<void> _selectTime(
      BuildContext context, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(

              // Cambia el color de la selección (círculo activo)
              colorScheme: ColorScheme.light(
                primary: Colors.red.shade700,
                // Cambia el color principal a rojo
                onPrimary: Colors.white, // Texto en el botón "OK"
              ),
              // Cambia el color del texto del botón "CANCEL"
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  foregroundColor:
                      Colors.red, // Cambia el color del texto a rojo
                ),
              ),
              timePickerTheme: TimePickerThemeData(
                dayPeriodColor: Colors.grey[300],
              )),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: CustomAppBar(
          title: isMobile ? 'Configuración' : 'Configuración de Menú'),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 15.0 : 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horarios',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              SizedBox(height: 20),

              // Hora de reserva de tickets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMobile
                        ? 'Hora máxima para reserva:'
                        : 'Hora máxima para reserva de tickets:',
                    style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  ScheduleButton(
                      onPressed: () =>
                          _selectTime(context, (time) => _horaReserva = time),
                      defaultTime: _horaReserva),
                ],
              ),

              SizedBox(height: 10),

              // Hora de cancelación de tickets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMobile
                        ? 'Hora máx. para cancelación:'
                        : 'Hora máxima para cancelación de tickets:',
                    style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  ScheduleButton(
                      onPressed: () => _selectTime(
                          context, (time) => _horaCancelacion = time),
                      defaultTime: _horaCancelacion),
                ],
              ),
              SizedBox(height: 10),

              // Hora de venta de almuerzo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isMobile
                        ? 'Hora de inicio de almuerzos:'
                        : 'Hora de inicio de venta de almuerzos:',
                    style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20),
                  ScheduleButton(
                      onPressed: () => _selectTime(
                          context, (time) => _horaVentaAlmuerzo = time),
                      defaultTime: _horaVentaAlmuerzo),
                ],
              ),
              SizedBox(height: isMobile ? 60 : 100),
              Divider(),
              SizedBox(height: isMobile ? 10 : 30),
              // Botón para guardar los cambios
              Center(
                child: Button(
                  icon: Icons.save_alt,
                  text: 'Guardar',
                  onPressed: () {
                    // Aquí puedes guardar los horarios en una base de datos o en SharedPreferences
                    print('Horario de reserva: ${_formatTime(_horaReserva)}');
                    print(
                        'Horario de cancelación: ${_formatTime(_horaCancelacion)}');
                    print(
                        'Horario de venta de almuerzos: ${_formatTime(_horaVentaAlmuerzo)}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Horarios guardados correctamente')),
                    );
                  },
                  size: Size(isMobile ? 180 : 250, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Formatear la hora en formato HH:mm
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
