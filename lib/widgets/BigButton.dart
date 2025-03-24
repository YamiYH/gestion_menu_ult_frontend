import 'package:flutter/material.dart';

class BigButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const BigButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  State<BigButton> createState() => _ButtonState();
}

class _ButtonState extends State<BigButton> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[900],
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 80 : 20,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        widget.text,
        style: TextStyle(fontSize: screenWidth > 600 ? 20 : 15),
      ),
    );
  }
}
