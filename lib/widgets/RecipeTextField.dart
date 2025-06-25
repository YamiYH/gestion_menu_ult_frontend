import 'package:flutter/material.dart';

class RecipeTextField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String text;
  final int? lines;

  const RecipeTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.text,
    this.lines,
  });

  @override
  State<RecipeTextField> createState() => _RecipeTextFieldState();
}

class _RecipeTextFieldState extends State<RecipeTextField> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return TextField(
      maxLines: widget.lines,
      controller: widget.controller,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.text,
        border: OutlineInputBorder(),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red[900]!),
        ),
        labelStyle:
            TextStyle(color: widget.enabled ? Colors.black : Colors.black87),
      ),
      style: TextStyle(color: widget.enabled ? Colors.black : Colors.black87),
    );
  }
}
