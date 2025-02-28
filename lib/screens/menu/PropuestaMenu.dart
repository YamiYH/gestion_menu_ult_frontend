// lib/screens/menu_propuesta.dart
import 'package:flutter/material.dart';

class MenuPropuesta extends StatefulWidget {
  final String tipo;
  final Map<String, List<String>> comidas;

  MenuPropuesta({required this.tipo, required this.comidas});

  @override
  _MenuPropuestaState createState() => _MenuPropuestaState();
}

class _MenuPropuestaState extends State<MenuPropuesta> {
  // Lista para guardar los productos seleccionados
  List<String> _productosSeleccionados = [];

  // Método para manejar la selección de productos
  void _seleccionarProducto(String producto, bool seleccionado) {
    setState(() {
      if (seleccionado) {
        _productosSeleccionados.add(producto);
      } else {
        _productosSeleccionados.remove(producto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona tus productos - ${widget.tipo}'),
      ),
      body: ListView(
        children: [
          ...widget.comidas.entries.map((entry) {
            final tipoComida = entry.key;
            final platos = entry.value;
            return Card(
              margin: EdgeInsets.all(8.0),
              child: ExpansionTile(
                title: Text(tipoComida),
                children: platos.map((plato) {
                  return CheckboxListTile(
                    title: Text(plato),
                    value: _productosSeleccionados.contains(plato),
                    onChanged: (seleccionado) {
                      _seleccionarProducto(plato, seleccionado ?? false);
                    },
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_productosSeleccionados.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Por favor, selecciona al menos un producto.'),
              ),
            );
          } else {
            // Navegar a la pantalla de confirmación de reserva
            Navigator.pushNamed(
              context,
              '/confirmarReserva',
              arguments: {
                'tipoMenu': widget.tipo,
                'productosSeleccionados': _productosSeleccionados,
              },
            );
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
