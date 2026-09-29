import 'package:flutter/material.dart';

class OnboardingModel {
  final String category;
  final Color categoryColor;
  final String title;
  final String description;
  final String imagePath; // تم تغيير اسم الحقل إلى imagePath
  final IconData badgeIcon;
  final Color badgeColor;

  const OnboardingModel({
    required this.category,
    required this.categoryColor,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.badgeIcon,
    required this.badgeColor,
  });

  static const List<OnboardingModel> pages = [
    OnboardingModel(
      category: 'MANAGE YOUR PETS',
      categoryColor: Color(0xFF1F604D),
      title: 'أدر ملفات حيواناتك',
      description: 'سجّل جميع حيواناتك في مكان واحد، تتبّع صحتهم وبياناتهم بسهولة.',
      imagePath: 'assets/images/onboarding1.png',
      badgeIcon: Icons.pets_rounded,
      badgeColor: Color(0xFFE65100),
    ),
    OnboardingModel(
      category: 'NEVER MISS A VACCINATION',
      categoryColor: Color(0xFF0277BD),
      title: 'لا تفوّت موعد تطعيم',
      description: 'تتبّع جميع مواعيد التطعيم واستلم تذكيرات آلية قبل موعد كل جرعة.',
      imagePath: 'assets/images/onboarding2.png',
      badgeIcon: Icons.vaccines_rounded,
      badgeColor: Color(0xFFD32F2F),
    ),
    OnboardingModel(
      category: 'YOUR VETERINARY PHARMACY',
      categoryColor: Color(0xFFE65100),
      title: 'صيدليتك البيطرية',
      description: 'أدوية ولقاحات ومنتجات بيطرية معتمدة، توصيل سريع لباب منزلك.',
      imagePath: 'assets/images/onboarding3.png',
      badgeIcon: Icons.local_pharmacy_rounded,
      badgeColor: Color(0xFF00897B),
    ),
  ];
}