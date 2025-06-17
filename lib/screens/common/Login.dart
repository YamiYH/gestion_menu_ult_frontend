import 'package:flutter/material.dart';
import 'package:gestion_menu_ult_frontend/models/Login/UserLoginRequest.dart';
import 'package:gestion_menu_ult_frontend/routes/PageRouteBuilder.dart';
import 'package:gestion_menu_ult_frontend/screens/ticket/GestionarTicket.dart';
import 'package:provider/provider.dart';

import '../../controllers/security/LoginController.dart';
import '../../controllers/security/user/UserAuthContext.dart';
import '../../providers/ProfileProvider.dart';
import 'Options.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginController _loginController = LoginController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    // Valida el formulario antes de continuar
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = UserLoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      final bool loginSuccess = await _loginController.login(user);

      if (loginSuccess && mounted) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        await profileProvider.fetchUserProfile(user.username);

        UserAuthContext.saveUsername(user.username);

        final destinationScreen = _getDestinationScreen(profileProvider);

        if (mounted) {
          Navigator.pushReplacement(
              context, createFadeRoute(destinationScreen));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Credenciales inválidas.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _getDestinationScreen(ProfileProvider profileProvider) {
    final String userRole = profileProvider.userProfile?.role ?? '';

    if (userRole.toLowerCase() == 'usuario') {
      return GestionarTicket();
    } else {
      return Options();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleTextStyle: TextStyle(),
        title: Text(
          'Bienvenido al Menú Digital ULT',
          style: TextStyle(
              fontFamily: 'Roboto',
              color: Colors.white,
              fontSize: isMobile ? 20 : 25),
        ),
        backgroundColor: Colors.red[900],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: isMobile
                    ? AssetImage('assets/img/background2.png')
                    : AssetImage('assets/img/background0.png'),
                fit: isMobile ? BoxFit.cover : BoxFit.fill)),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: isMobile ? 300 : 500,
              alignment: Alignment.center,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset(
                      'assets/logos/logo5.png',
                      width: isMobile ? 100 : 140,
                      height: isMobile ? 100 : 140,
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15.0),
                        labelText: 'Usuario',
                        labelStyle: TextStyle(
                          color: Colors.red[900],
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red[900]!),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red[900]!),
                            borderRadius: BorderRadius.circular(5)),
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
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(15.0),
                        labelText: 'Contraseña',
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: Colors.grey,
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible; // Alterna la visibilidad
                            });
                          },
                        ),
                        labelStyle: TextStyle(color: Colors.red[900]),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red[900]!),
                            borderRadius: BorderRadius.circular(5)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red[900]!),
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu contraseña';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(isMobile ? 180 : 220, 50),
                        elevation: 3,
                        backgroundColor: Colors.red[900],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 30 : 50,
                          vertical: isMobile ? 11 : 18,
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Iniciar Sesión',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 15 : 18)),
                    ),
                    Image.asset(
                      'assets/logos/logo1.png',
                      width: isMobile ? 80 : 100,
                      height: isMobile ? 130 : 100,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
