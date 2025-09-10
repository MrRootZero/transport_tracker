import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

/// Root widget for the Transport Tracker app.
class TransportApp extends StatelessWidget {
  const TransportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0066CC)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}