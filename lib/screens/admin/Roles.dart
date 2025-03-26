import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Roles extends StatefulWidget {
  const Roles({super.key});

  @override
  State<Roles> createState() => _RolesState();
}

class _RolesState extends State<Roles> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Roles'),
    );
  }
}
