import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gestion_menu_ult_frontend/providers/ProfileProvider.dart';
import 'package:gestion_menu_ult_frontend/routes/Routes.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Menú de Alimentos en Comedores ULT',
          theme: ThemeData(
            fontFamily: 'Roboto',
            textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
            primarySwatch: Colors.red,
            scaffoldBackgroundColor: Colors.white,
          ),
          initialRoute: AppRoutes.login,
          routes: AppRoutes.getRoutes(),
          //routerConfig: AppRouter.router,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
            Locale('en', 'US'),
          ],
          locale: const Locale('es', 'ES')),
    );
  }
}
