import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const BartenderApp());
}

class BartenderApp extends StatelessWidget {
  const BartenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip Splitter',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE8B86D),
          secondary: const Color(0xFFE8B86D),
          surface: const Color(0xFF1C1C1E),
          onSurface: Colors.white,
          background: const Color(0xFF111111),
          onBackground: Colors.white,
          error: const Color(0xFFFF6B6B),
        ),
        scaffoldBackgroundColor: const Color(0xFF111111),
        cardColor: const Color(0xFF1C1C1E),
        dividerColor: const Color(0xFF2C2C2E),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE8B86D), width: 1.5),
          ),
          labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8B86D),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE8B86D),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          iconTheme: IconThemeData(color: Color(0xFFE8B86D)),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}