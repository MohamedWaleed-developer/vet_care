class AgeCalculator {
  AgeCalculator._();

  static String calculate(DateTime birthDate) {
    final now = DateTime.now();

    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;

    if (now.day < birthDate.day) {
      months--;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years > 0) {
      if (months > 0) {
        return '$years years, $months months';
      }

      return '$years years';
    }

    if (months > 0) {
      return '$months months';
    }

    final days = now.difference(birthDate).inDays;

    return '$days days';
  }
}