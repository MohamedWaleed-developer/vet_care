import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onIconPressed;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.onIconPressed,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: onIconPressed != null
            ? IconButton(
          onPressed: onIconPressed,
          icon: Icon(icon),
        )
            : Icon(icon),
      ),
    );
  }
}