import 'package:flutter/material.dart';

class NumField extends StatefulWidget {
  final TextEditingController controller;
  final String text;

  const NumField({super.key, required this.controller, required this.text});

  @override
  State<NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<NumField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.text,
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[900]!),
            borderRadius: BorderRadius.circular(5)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red[900]!),
            borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
