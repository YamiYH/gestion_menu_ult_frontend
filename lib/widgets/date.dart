import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class DatePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final DateTime? selectedDate; // Fecha seleccionada
  final Function(DateTime) onDateSelected; // Callback para actualizar la fecha

  const DatePickerButton({
    Key? key,
    required this.label,
    this.icon = Icons.calendar_today,
    this.iconColor = Colors.red,
    this.textColor = Colors.red,
    required this.selectedDate,
    required this.onDateSelected, // Añadir este parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 150 : 170, isMobile ? 40 : 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: iconColor!, width: 1),
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
                dialogBackgroundColor: Colors.white,
                textTheme: TextTheme(
                  headlineMedium: TextStyle(fontSize: 16),
                  bodyLarge: TextStyle(fontSize: 14),
                  bodyMedium: TextStyle(fontSize: 12),
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          onDateSelected(
              pickedDate); // Llamar al callback con la fecha seleccionada
        }
      },
      icon: Icon(Icons.calendar_today, color: Colors.red[900]),
      label: Text(
        selectedDate == null
            ? label
            : DateFormat('yyyy-MM-dd hh:mm a').format(selectedDate!),
        style: TextStyle(
          fontSize: isMobile ? 14 : 18,
          color: Colors.red[900],
        ),
      ),
    );
  }
}
