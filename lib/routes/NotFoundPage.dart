import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.red[900]),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Center(
            child: Column(
          children: [
            SizedBox(height: 70),
            Text(
              'Página no encontrada',
              style: TextStyle(
                  fontSize: isMobile ? 20 : 40, fontWeight: FontWeight.bold),
            ),
            Image(image: AssetImage('assets/img/404.png')),
          ],
        )),
      ),
    );
  }
}
