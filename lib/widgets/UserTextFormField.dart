import 'package:flutter/material.dart';

class UserTextFormField extends StatefulWidget {
  final String text;
  final Function(String)? onChanged;
  final TextEditingController? controller;

  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  const UserTextFormField({
    super.key,
    required this.text,
    this.onChanged,
    this.controller,
    this.validator,
    this.autovalidateMode,
  });

  @override
  State<UserTextFormField> createState() => _UserTextFormFieldState();
}

class _UserTextFormFieldState extends State<UserTextFormField> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.90
          : MediaQuery.of(context).size.width * 0.14,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.07
          : MediaQuery.of(context).size.height * 0.10,
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(5)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(5)),
        ),
        onChanged: widget.onChanged,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
      ),
    );
  }
}
