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
    const HomeScreen(),
    const Center(child: Text("Scan Screen")),
    const Center(child: Text("Schedule Screen")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        // Decoration handles the shadow and the top rounding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, -2), // Shadow moves slightly upward
            ),
          ],
        ),
        child: ClipRRect(
          // ClipRRect ensures the NavigationBar itself follows the top rounding
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.green.withOpacity(0.1),
              labelTextStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.white,
              elevation: 0, // Elevation is handled by the parent Container
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.eco_outlined),
                  selectedIcon: Icon(Icons.eco, color: Colors.green),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(Icons.camera_alt, color: Colors.green),
                  label: 'Scan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month, color: Colors.green),
                  label: 'Schedule',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}