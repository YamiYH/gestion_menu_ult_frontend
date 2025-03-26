import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBar(title: 'Configuración'));
  }
}
