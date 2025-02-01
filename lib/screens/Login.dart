import 'package:flutter/material.dart';

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
    return Scaffold(
        appBar: AppBar(centerTitle: true, titleTextStyle: TextStyle(),
        title: Text('Bienvenido', style: TextStyle(color: Colors.white, fontSize: 28)),
    backgroundColor: Colors.red[900],
    ),
    body: Center(
    child: Container(
      width: screenWidth > 600 ? 500 : 300,
      alignment: Alignment.center,
    child: Form(
    key: _formKey,
    child: Column(
    //mainAxisAlignment: MainAxisAlignment.center,
    //crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(height: 30),
      Image.asset(
        'assets/logo1.png', // Ruta de la imagen en tu proyecto
        width: screenWidth > 600 ? 150 : 100, // Ajustar el tamaño de la imagen
        height: screenWidth > 600 ? 150 : 100,
      ),
      SizedBox(height: 30),
    TextFormField(
    controller: _userController,
    decoration: InputDecoration(
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
    if (value == null || value.isEmpty) {return 'Por favor, ingresa tu usuario';
    }
    return null;
    },
    ),
    SizedBox(height: 30),
    TextFormField(
    controller: _passwordController,
    obscureText: true,
    decoration: InputDecoration(
    labelText: 'Contraseña',
    labelStyle: TextStyle(color: Colors.red[900]),
    border: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red[900]!),
    ),
    focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red[900]!),
    ),
    ),
    validator: (value) { if (value == null || value.isEmpty) {
    return 'Por favor, ingresa tu contraseña';
    }
    return null;
    },
    ),
    SizedBox(height: 50),
    ElevatedButton(

    onPressed: _login,
    style: ElevatedButton.styleFrom(elevation: 3,backgroundColor: Colors.red[900],
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(horizontal: screenWidth > 600 ? 100 : 50, // Ajustar el padding horizontal
      vertical: 20),
    ),
    child: Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 17) ),
    ),
    ],
    ),
    ),
    ),),
    );
  }
}