import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String label; // Must be 'label'
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const AuthTextField({
    super.key, 
    required this.label, 
    required this.icon, 
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green[800]),
        labelText: label, // Matches the variable name
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}