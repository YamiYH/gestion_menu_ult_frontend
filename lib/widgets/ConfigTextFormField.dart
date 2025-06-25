import 'package:flutter/material.dart';

class ConfigTextFormField extends StatefulWidget {
  final String text;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Icon icon;
  final IconButton? suffix;
  final bool obscureText;

  const ConfigTextFormField({
    super.key,
    required this.controller,
    required this.text,
    this.onChanged,
    required this.validator,
    required this.icon,
    this.suffix,
    this.obscureText = false,
  });

  @override
  State<ConfigTextFormField> createState() => _ConfigtextformfieldState();
}

class _ConfigtextformfieldState extends State<ConfigTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        obscureText: widget.obscureText,
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon: widget.icon,
          suffixIcon: widget.suffix,
          labelText: widget.text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(5)),
        ),
        validator: widget.validator);
  }
}
