import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text = 'Filtrar';
  final IconData icon = Icons.filter_alt;

  FilterButton({super.key, required this.onPressed});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize:
            Size(isMobile ? MediaQuery.of(context).size.width * 0.35 : 150, 50),
        elevation: 3,
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 30,
          vertical: isMobile ? 10 : 18,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            color: Colors.white,
            size: isMobile ? 18 : 20,
          ),
          SizedBox(width: 8),
          Text(
            'Filtrar',
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 15 : 18),
          ),
        ],
      ),
    );
  }
}
