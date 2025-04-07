import 'package:flutter/material.dart';

class DateWidget extends StatefulWidget {
  final bool isMobile;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final double width1;

  const DateWidget({
    Key? key,
    required this.isMobile,
    required this.selectedDate,
    required this.onDateSelected,
    required this.width1,
  }) : super(key: key);

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isMobile ? MediaQuery.of(context).size.width * 0.90 : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Selector de Fecha
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              fixedSize: Size(
                widget.width1,
                MediaQuery.of(context).size.height * 0.07,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.red[900]!, width: 1),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 10 : 20,
                vertical: widget.isMobile ? 8 : 12,
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
                      textTheme: TextTheme(
                        headlineMedium: TextStyle(fontSize: 16),
                        bodyLarge: TextStyle(fontSize: 14),
                        bodyMedium: TextStyle(fontSize: 12),
                      ),
                      dialogTheme: DialogTheme(
                        backgroundColor: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                widget.onDateSelected(pickedDate);
              }
            },
            icon: Icon(Icons.calendar_today, color: Colors.red[900]),
            label: Text(
              widget.selectedDate == null
                  ? 'Seleccionar Fecha'
                  : '${widget.selectedDate!.day}/${widget.selectedDate!.month}/${widget.selectedDate!.year}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
