import 'package:flutter/material.dart';

import '../home_colors.dart';

class HomeBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem('الرئيسية', Icons.home_rounded),
    _NavItem('المتجر', Icons.storefront_outlined),
    _NavItem('أليفي', Icons.pets_outlined),
    _NavItem('طلباتي', Icons.receipt_long_outlined),
    _NavItem('حسابي', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: HomeColors.background,
        border: Border(top: BorderSide(color: Color(0xFFF0E2DF))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _items[i].icon,
                          size: 28,
                          color: i == currentIndex
                              ? HomeColors.green
                              : const Color(0xFF6B6B6B),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _items[i].label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == currentIndex
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: i == currentIndex
                                ? HomeColors.green
                                : const Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem(this.label, this.icon);
}
