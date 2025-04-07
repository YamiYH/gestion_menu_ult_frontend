import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/CustomAppbar.dart';

class Recetas extends StatefulWidget {
  const Recetas({super.key});

  @override
  State<Recetas> createState() => _RecetasState();
}

class _RecetasState extends State<Recetas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Libro de Recetas'),
    );
  }
}

Widget SearchTextField(bool isMobile) {
  return SizedBox(
    width: isMobile ? 180 : 220, // Mismo ancho que el botón
    height: 50, // Mismo alto que el botón
    child: TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.restaurant_menu),
          prefixIconColor: Colors.red.shade900,
          labelText: 'Buscar Plato',
          labelStyle: TextStyle(color: Colors.red.shade900),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(10), // Mismos bordes redondeados
          ),
          contentPadding: EdgeInsets.all(15)),
      onChanged: (value) {},
    ),
  );
}
