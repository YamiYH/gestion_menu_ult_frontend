import 'package:flutter/material.dart';

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
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/reservar_ticket');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red[900],
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 80 : 20,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reservar ticket',
                  style: TextStyle(fontSize: screenWidth > 600 ? 20 : 15),
                ),
              ),
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gestionar_menu');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red[900],
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 80 : 20,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Gestionar Menú',
                  style: TextStyle(fontSize: screenWidth > 600 ? 20 : 15),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
