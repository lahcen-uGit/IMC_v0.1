import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BMICalculator {
  static double calculateBMI(double weight, double height) {
    return weight / (height * height);
  }

  static String getBMIResult(BuildContext context, double bmi) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return 'Error: Localization not available'; // Or a localized error message
    }
    switch (getBMIResultKey(bmi)) {
      case 'underweight': return l10n.bmiUnderweight;
      case 'normal': return l10n.bmiNormal;
      case 'overweight': return l10n.bmiOverweight;
      case 'obese': return l10n.bmiObesity;
      default: return ""; // Or a localized "Unknown" message
    }
  }
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
  static String getBMIResultKey(double bmi) {
    if (bmi < 18.5) return 'underweight';
    if (bmi < 25) return 'normal';
    if (bmi < 30) return 'overweight';
    return 'obese';
  }

}