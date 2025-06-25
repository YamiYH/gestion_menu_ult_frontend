import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class DatePickerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool includeTime;

  // Callback para actualizar la fecha

  const DatePickerButton({
    Key? key,
    required this.label,
    this.icon = Icons.calendar_today,
    this.iconColor = Colors.red,
    this.textColor = Colors.red,
    required this.selectedDate,
    required this.onDateSelected,
    required this.firstDate,
    required this.lastDate,
    this.includeTime = false, // Añadir este parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 150 : 170, 50),
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
        // Selector de fecha y hora
        final pickedDate = await _showDatePicker(context);
        if (pickedDate != null) {
          onDateSelected(pickedDate);
        }
      },
      icon: Icon(Icons.calendar_today, color: Colors.red[900]),
      label: Text(
        selectedDate == null
            ? label
            : DateFormat('yyyy-MM-dd').format(selectedDate!),
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          color: Colors.red[900],
        ),
      ),
    );
  }

// Método para mostrar el selector de fecha
  Future<DateTime?> _showDatePicker(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now().add(Duration(days: 30)),
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
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
  }


}
