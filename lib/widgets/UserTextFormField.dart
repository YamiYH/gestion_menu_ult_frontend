import 'package:flutter/material.dart';

class Usertextformfield extends StatefulWidget {
  final String text;
  final Function(String) onChanged;

  Usertextformfield({super.key, required this.text, required this.onChanged});

  @override
  State<Usertextformfield> createState() => _UsertextformfieldState();
}

class _UsertextformfieldState extends State<Usertextformfield> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.85
          : MediaQuery.of(context).size.width * 0.14,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.07
          : MediaQuery.of(context).size.height * 0.10,
      child: TextFormField(
        decoration: InputDecoration(
          labelText: widget.text,
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red[900]!),
              borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) => widget.onChanged,
      ),
    );
  }
}
