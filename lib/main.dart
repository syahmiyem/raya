import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_page.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseConfig.firebaseOptions,
  );

  // Initialize Firebase Analytics

  runApp(const RayaApp());
}

class RayaApp extends StatelessWidget {
  const RayaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belatuk Raya Invitation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF14654E),
          ),
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF14654E),
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF333333),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF14654E),
          primary: const Color(0xFF14654E),
          secondary: const Color(0xFFE4A532),
          background: Colors.white,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}
