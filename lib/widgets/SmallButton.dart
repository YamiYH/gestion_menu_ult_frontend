import 'package:flutter/material.dart';

class SmallButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Size? size; // Tamaño opcional

  const SmallButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.size,
  }) : super(key: key);

  @override
  State<SmallButton> createState() => _ButtonState();
}

class _ButtonState extends State<SmallButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    // Definir el tamaño predeterminado si no se proporciona uno
    Size defaultSize = Size(isMobile ? 100 : 220, 40);
    Size buttonSize = widget.size ?? defaultSize;

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red[900],
          fixedSize: buttonSize),
      child: Text(widget.text,
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 15)),
    );
  }
}
