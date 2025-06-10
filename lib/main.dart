import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestion_menu_ult_frontend/routes/routes.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Menú de Alimentos en Comedores ULT',
        theme: ThemeData(
          fontFamily: 'Roboto',
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
        ),
        initialRoute: AppRoutes.options,
        routes: AppRoutes.getRoutes(),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          // Para los widgets de Material Design
          GlobalWidgetsLocalizations.delegate,
          // Para la dirección del texto (izq-a-der, etc.)
          GlobalCupertinoLocalizations.delegate,
          // Para los widgets estilo iOS (Cupertino)
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español de España
          Locale('en', 'US'), // Inglés de USA (como opción de respaldo)
          // Puedes añadir más idiomas aquí si lo necesitas
        ],
        locale: const Locale('es', 'ES'));
  }
}
