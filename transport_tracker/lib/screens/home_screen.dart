import 'package:flutter/material.dart';
import 'passengers_screen.dart';
import 'log_trip_screen.dart';
import 'report_screen.dart';

/// The main navigation screen with bottom navigation bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [
    PassengersScreen(),
    LogTripScreen(),
    ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.group), label: 'Passengers'),
          NavigationDestination(icon: Icon(Icons.directions_bus), label: 'Log Trip'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Reports'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}