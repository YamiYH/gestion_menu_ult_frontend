// lib/screens/confirmar_reserva.dart
import 'package:flutter/material.dart';

class ConfirmarReserva extends StatelessWidget {
  final String tipoMenu;
  final List<String> productosSeleccionados;

  ConfirmarReserva(
      {required this.tipoMenu, required this.productosSeleccionados});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reserva Confirmada'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menú: $tipoMenu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Productos seleccionados:',
              style: TextStyle(fontSize: 18),
            ),
            ...productosSeleccionados.map((producto) {
              return ListTile(
                title: Text(producto),
              );
            }).toList(),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes agregar la lógica para guardar la reserva
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reserva confirmada con éxito.'),
                    ),
                  );
                  Navigator.popUntil(context,
                      ModalRoute.withName('/home')); // Regresar al inicio
                },
                child: Text('Confirmar Reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
