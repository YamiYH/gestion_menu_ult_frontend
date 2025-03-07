import 'package:flutter/material.dart';

class SmallButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const SmallButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  State<SmallButton> createState() => _ButtonState();
}

class _ButtonState extends State<SmallButton> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.red[900],
      ),
      child: Text(widget.text,
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 12 : 15)),
    );
  }
}
