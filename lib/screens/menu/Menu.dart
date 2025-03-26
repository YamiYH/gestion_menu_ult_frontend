import 'package:flutter/material.dart';

import '../../widgets/CustomAppbar.dart';

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Gestión de Menú'),
    );
  }
}
