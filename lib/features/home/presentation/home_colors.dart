import 'package:flutter/material.dart';

/// ألوان شاشة الهوم (من التصميم)
class HomeColors {
  HomeColors._();

  static const Color background = Color(0xFFFFF5F3);
  static const Color green = Color(0xFF1F6F5C);
  static const Color cardFill = Color(0xFFF4F5EE);
  static const Color cardBorder = Color(0xFF4E8F7E);
  static const Color subtitle = Color(0xFF7A8A84);

  // كارت موعد التطعيم
  static const Color warnFill = Color(0xFFFCE8D6);
  static const Color warnBorder = Color(0xFFC9A27E);
  static const Color warnIcon = Color(0xFFE8A04C);

  // الألوان المستخدمة في HomeScreen
  static const Color primary = green; // اللون الأساسي للتطبيق
  static const Color textPrimary = Color(0xFF1F1F1F); // لون النصوص الرئيسية
  static const Color textSecondary = subtitle; // لون النصوص الفرعية
}