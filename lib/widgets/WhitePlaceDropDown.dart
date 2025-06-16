import 'package:flutter/material.dart';

class WhitePlaceDropDown extends StatefulWidget {
  final String value;
  final void Function(String?)? onChanged;
  final double widthFactor;
  final double widthFactor1;

  const WhitePlaceDropDown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.widthFactor,
    required this.widthFactor1,
  });

  @override
  State<WhitePlaceDropDown> createState() => _WhitePlaceDropDownState();
}

class _WhitePlaceDropDownState extends State<WhitePlaceDropDown> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return SizedBox(
      width: isMobile
          ? MediaQuery.of(context).size.width * widget.widthFactor
          : MediaQuery.of(context).size.width * widget.widthFactor1,
      height: isMobile ? 60 : 50,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: widget.value,
            onChanged: widget.onChanged,
            items: ['Lenin', 'Pepito Tey']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: TextStyle(fontSize: 17)),
              );
            }).toList(),
            icon: Icon(Icons.arrow_drop_down_circle, color: Colors.red[900]),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
            isExpanded: true,
          ),
        ),
      ),
    );
  }
}
