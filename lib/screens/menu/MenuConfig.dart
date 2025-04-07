import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class MenuConfig extends StatefulWidget {
  const MenuConfig({super.key});

  @override
  State<MenuConfig> createState() => _MenuConfigState();
}

class _MenuConfigState extends State<MenuConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Configuración'),
    );
  }
}
