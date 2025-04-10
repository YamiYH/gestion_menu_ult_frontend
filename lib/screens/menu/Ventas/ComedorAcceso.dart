import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../widgets/Button.dart';

class ComedorAcceso extends StatefulWidget {
  const ComedorAcceso({Key? key}) : super(key: key);

  @override
  State<ComedorAcceso> createState() => _ComedorAccesoState();
}
//Esta página solo es visible para el modo Mobile

class _ComedorAccesoState extends State<ComedorAcceso> {
  String? scannedData; // Almacena los datos escaneados
  bool isScanning = true; // Controla si el escáner está activo
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(); // Inicializa el controlador aquí
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera los recursos cuando se elimina el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red[900],
        title: Text('Escáner de Tickets',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.8,
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                if (isScanning) {
                  final code = capture.barcodes.first;
                  setState(() {
                    scannedData = code.rawValue; // Guarda el contenido del QR
                    isScanning = false; // Detiene el escaneo
                  });
                }
              },
            ),
          ),
          if (scannedData != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos escaneados:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: Text(scannedData!)),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button(
                          size: Size(250, 50),
                          onPressed: () {
                            setState(() {
                              isScanning = true;
                              scannedData = null; // Reactiva el escaneo
                            });
                          },
                          text: 'Escanear otro código'),
                    ],
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
