// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'screens/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) {
      print("Firebase initialized successfully");
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error initializing Firebase: $e");
    }
  }

  runApp(const RayaApp());
}

class RayaApp extends StatelessWidget {
  const RayaApp({super.key});

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
