import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon; // Ícono opcional
  final Size? size; // Tamaño opcional

  const Button({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.size,
    MaterialColor? colorButton,
  }) : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    Size defaultSize =
        Size(isMobile ? 180 : MediaQuery.of(context).size.width * 0.13, 50);
    Size buttonSize = widget.size ?? defaultSize;

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: buttonSize,
        elevation: 3,
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 40,
          vertical: isMobile ? 11 : 18,
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
            style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18),
          ),
        ],
      ),
    );
  }
}
