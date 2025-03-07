import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon; // Ícono opcional

  const Button(
      {Key? key, required this.onPressed, required this.text, this.icon})
      : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 170 : 220, isMobile ? 40 : 50),
        elevation: 3,
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 50,
          vertical: 15,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: Colors.white,
              size: isMobile ? 16 : 20,
            ),
          ],
          SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 16),
          ),
        ],
      ),
    );
  }
}
