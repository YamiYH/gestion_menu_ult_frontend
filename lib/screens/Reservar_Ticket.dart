import 'package:flutter/material.dart';

class ReservarTicket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Reservar Ticket', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: Text(
          'Pantalla de Reservar Ticket',
          style: TextStyle(fontSize: 24, color: Colors.red[900]),
        ),
      ),
    );
  }
}
