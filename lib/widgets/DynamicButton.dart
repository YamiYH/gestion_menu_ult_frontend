import 'package:flutter/material.dart';

class DynamicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final Color colorButton;
  final Size? size;

  const DynamicButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    required this.colorButton,
    required this.size,
  }) : super(key: key);

  @override
  State<DynamicButton> createState() => _DynamicButtonState();
}

class _DynamicButtonState extends State<DynamicButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: widget.size,
        elevation: 3,
        backgroundColor: widget.colorButton,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 20,
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
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
