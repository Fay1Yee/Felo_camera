import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Felo Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD84D)),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const MainApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}
