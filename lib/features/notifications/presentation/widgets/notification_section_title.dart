import 'package:flutter/material.dart';

class NotificationSectionTitle extends StatelessWidget {
  final String title;

  const NotificationSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF263238),
        ),
      ),
    );
  }
}