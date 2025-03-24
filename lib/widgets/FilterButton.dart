import 'package:flutter/material.dart';

class FilterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon; // Ícono opcional

  const FilterButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize:
            Size(isMobile ? MediaQuery.of(context).size.width * 0.35 : 220, 50),
        elevation: 3,
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 50,
          vertical: isMobile ? 10 : 18,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: Colors.white,
              size: isMobile ? 18 : 20,
            ),
          ],
          SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 15 : 18),
          ),
        ],
      ),
    );
  }
}
