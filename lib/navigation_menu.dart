import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Import your home screen

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int _selectedIndex = 0;

  // List of different screen widgets
  final List<Widget> _screens = [
    const HomeScreen(), // The content we separated
    const Center(child: Text("Scan Screen")),
    const Center(child: Text("Schedule Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Schedule'),
        ],
      ),
    );
  }
}