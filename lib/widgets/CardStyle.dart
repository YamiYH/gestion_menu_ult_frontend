import 'package:flutter/material.dart';

import 'BuildCard.dart';

class CardStyle extends StatefulWidget {
  final String title;
  final IconData icon;
  final void Function() onTap;
  final bool isEnabled;

  const CardStyle(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap,
      this.isEnabled = true});

  @override
  State<CardStyle> createState() => _CardStyleState();
}

class _CardStyleState extends State<CardStyle> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(5),
        child: BuildCard(
            title: widget.title, icon: widget.icon, onTap: widget.onTap));
  }
}
