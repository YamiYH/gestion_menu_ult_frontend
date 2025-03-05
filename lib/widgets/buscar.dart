import 'package:flutter/material.dart';

class SearchButton extends StatefulWidget {
  final VoidCallback onPressed;

  const SearchButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<SearchButton> {
  bool isMobile = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(isMobile ? 150 : 200, isMobile ? 40 : 50),
        elevation: 3,
        backgroundColor: Colors.red[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 30 : 50,
          vertical: 15,
        ),
      ),
      child: Text(
        'BUSCAR',
        style: TextStyle(color: Colors.white, fontSize: 17),
      ),
    );
  }
}
