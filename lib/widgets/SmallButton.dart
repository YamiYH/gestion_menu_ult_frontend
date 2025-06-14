import 'package:flutter/material.dart';

class SmallButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final Size? size; // Tamaño opcional

  const SmallButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.size,
  }) : super(key: key);

  @override
  State<SmallButton> createState() => _ButtonState();
}

class _ButtonState extends State<SmallButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    Size defaultSize = Size(isMobile ? 110 : 220, 40);
    Size buttonSize = widget.size ?? defaultSize;
    bool isLoading = widget.isLoading;

    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.red[900],
          fixedSize: buttonSize),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(widget.text,
          style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 15)),
    );
  }
}
