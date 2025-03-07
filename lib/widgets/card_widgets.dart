import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/widgets/big_button.dart';

class ReservarTicketCard extends StatelessWidget {
  final double screenWidth;

  //final double screenHeight;

  const ReservarTicketCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth > 600 ? 400 : 250,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 150 : 30),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Image.asset(
                'assets/img/logo7.png',
                width: screenWidth > 600 ? 150 : 100,
                height: screenWidth > 600 ? 200 : 100,
              ),
              BigButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/gestionar_ticket');
                  },
                  text: 'Reservar ticket'),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class GestionarMenuCard extends StatelessWidget {
  final double screenWidth;

  const GestionarMenuCard({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth > 600 ? 400 : 250,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 150 : 30),
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Image.asset(
                'assets/img/logo3.png',
                width: screenWidth > 600 ? 300 : 150,
                height: screenWidth > 600 ? 200 : 100,
              ),
              BigButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/modulos');
                  },
                  text: 'Gestionar Menú'),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
