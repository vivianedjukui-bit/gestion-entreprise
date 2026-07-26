import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const ink = Color(0xFF1C2B24);
  static const paper = Color(0xFFFBF6E8);
  static const paperCard = Color(0xFFEFE8D2);
  static const cover = Color(0xFF16241F);
  static const gold = Color(0xFFC9962C);
  static const green = Color(0xFF3E8C5D);
  static const red = Color(0xFFB23A2E);
  static const muted = Color(0xFF6B7A70);
  static const dottedLine = Color(0xFFB9AF8E);
}

class AppText {
  static TextStyle ledgerTitle({double size = 18, Color color = AppColors.ink}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: FontWeight.w700, color: color);

  static TextStyle amount({double size = 14, Color color = AppColors.ink, FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.ibmPlexMono(fontSize: size, fontWeight: weight, color: color);

  static TextStyle body({double size = 14, Color color = AppColors.ink}) =>
      GoogleFonts.inter(fontSize: size, color: color);

  static TextStyle label({double size = 12, Color color = AppColors.muted}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: FontWeight.w500);
}

String formatFcfa(int amount) {
  final s = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(s[i]);
  }
  return '${buffer.toString()} FCFA';
}
