import 'package:flutter/material.dart';

import '../../widgets/Button.dart';

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
                fontSize: isMobile ? 20 : 25)),
        backgroundColor: Colors.red[900],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: isMobile ? 300 : 500,
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Image.asset(
                    'assets/logos/logo5.png',
                    width: isMobile ? 100 : 150,
                    height: isMobile ? 100 : 150,
                  ),
                  Text(
                    '"El comedor universitario en la palma de tu mano"',
                    style: TextStyle(
                        fontSize: isMobile ? 11 : 16,
                        fontWeight:
                            isMobile ? FontWeight.bold : FontWeight.w400),
                  ),
                  SizedBox(height: 50),
                  TextFormField(
                    controller: _userController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15.0),
                      labelText: 'Usuario',
                      labelStyle: TextStyle(
                        color: Colors.red[900],
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900]!),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900]!),
                          borderRadius: BorderRadius.circular(10)),
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
                      contentPadding: EdgeInsets.all(15.0),
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(color: Colors.red[900]),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900]!),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red[900]!),
                          borderRadius: BorderRadius.circular(10)),
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
                  Image.asset(
                    'assets/logos/logo1.png',
                    width: isMobile ? 80 : 100,
                    height: isMobile ? 130 : 170,
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
