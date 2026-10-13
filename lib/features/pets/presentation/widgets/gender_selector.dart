import 'package:flutter/material.dart';

import '../../data/models/animal_model.dart';

class GenderSelector extends StatelessWidget {
  final AnimalGender selectedGender;
  final ValueChanged<AnimalGender> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GenderCard(
            label: 'ذكر ♂',
            selected: selectedGender == AnimalGender.male,
            onTap: () {
              onChanged(AnimalGender.male);
            },
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: _GenderCard(
            label: 'أنثى ♀',
            selected: selectedGender == AnimalGender.female,
            onTap: () {
              onChanged(AnimalGender.female);
            },
          ),
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFD6E4DC);
    const green = Color(0xFF168052);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE8F5EE)
              : const Color(0xFFF9FBFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? green : borderColor,
            width: 1.2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
              selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? green
                  : const Color(0xFF4A5568),
            ),
          ),
        ),
      ),
    );
  }
}