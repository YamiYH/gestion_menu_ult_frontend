import 'package:flutter/material.dart';

class AddButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final Icon? icon;

  const AddButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
  }) : super(key: key);

  @override
  State<AddButton> createState() => _ButtonState();
}

class _ButtonState extends State<AddButton> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.green,
          fixedSize: Size(
              isMobile ? MediaQuery.of(context).size.width * 0.35 : 150, 50)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            size: isMobile ? 18 : 20,
            Icons.add,
            color: Colors.white,
          ),
          SizedBox(width: 2),
          Text(widget.text,
              style:
                  TextStyle(color: Colors.white, fontSize: isMobile ? 15 : 18)),
        ],
      ),
    );
  }
}
