import 'package:flutter/material.dart';

class ScheduleButton extends StatelessWidget {
  final VoidCallback onPressed; // Función a ejecutar al presionar el botón
  final TimeOfDay defaultTime; // Hora por defecto

  const ScheduleButton({
    Key? key,
    required this.onPressed,
    required this.defaultTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 100 : 130, isMobile ? 45 : 50),
        elevation: 3,
        backgroundColor: Colors.grey.shade300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(
        _formatTime(defaultTime),
        style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16),
      ),
    );
  }

  // Formatear la hora en formato HH:mm
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
