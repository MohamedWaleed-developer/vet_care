import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool showDivider;

  const ProfileMenuItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFFECEF)
                    : const Color(0xFFE6F3EF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1E6554),
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDestructive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1E293B),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isDestructive
                    ? const Color(0xFFF87171)
                    : const Color(0xFF94A3B8),
              ),
            ),
            trailing: Icon(
              Icons.arrow_back_ios_new,
              size: 14,
              color: isDestructive
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFFCBD5E1),
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 1,
              indent: 64,
              endIndent: 16,
              color: Color(0xFFF1F5F9),
            ),
        ],
      );
}
