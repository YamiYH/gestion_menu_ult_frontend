import 'package:flutter/material.dart';

import '../../widgets/button.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Aquí puedes agregar la lógica para autenticar al usuario
      String user = _userController.text;
      String password = _passwordController.text;
      // Simulación de autenticación exitosa
      print('User: $user');
      print('Password: $password');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleTextStyle: TextStyle(),
        title: Text('Bienvenido al Menú Digital ULT',
            style: TextStyle(
                fontFamily: 'Roboto',
                color: Colors.white,
                fontSize: screenWidth > 600 ? 25 : 20)),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: screenWidth > 600 ? 500 : 300,
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/logos/logo5.png',
                    // Ruta de la imagen en tu proyecto
                    width: screenWidth > 600
                        ? 150
                        : 100, // Ajustar el tamaño de la imagen
                    height: screenWidth > 600 ? 150 : 100,
                  ),
                  Text(
                    '"Tu comedor universitario en la palma de tu mano"',
                    style: TextStyle(
                        fontSize: screenWidth > 600 ? 16 : 11,
                        fontWeight: FontWeight.w400),
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    controller: _userController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      labelText: 'Usuario',
                      labelStyle: TextStyle(color: Colors.red[900]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red[900]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red[900]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu usuario';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0),
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.red[900]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red[900]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red[900]!),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 50),
                  Button(
                      onPressed: () {
                        Navigator.pushNamed(context, '/options');
                      },
                      text: 'Iniciar sesión'),
                  //SizedBox(height: 20),
                  Image.asset(
                    'assets/logos/logo1.png',
                    // Ruta de la imagen en tu proyecto
                    width: screenWidth > 600
                        ? 100
                        : 80, // Ajustar el tamaño de la imagen
                    height: screenWidth > 600 ? 170 : 130,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
