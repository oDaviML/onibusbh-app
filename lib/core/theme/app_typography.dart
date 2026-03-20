import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get display => GoogleFonts.manrope();
  static TextStyle get quicksand => GoogleFonts.quicksand();
  static TextStyle get nunito => GoogleFonts.nunito();

  static TextStyle get headlineLarge => display.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle get headlineMedium => display.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
  );

  static TextStyle get titleLarge =>
      quicksand.copyWith(fontSize: 18, fontWeight: FontWeight.w700);

  static TextStyle get titleMedium =>
      quicksand.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  static TextStyle get bodyLarge =>
      nunito.copyWith(fontSize: 16, fontWeight: FontWeight.w600);

  static TextStyle get bodyMedium =>
      nunito.copyWith(fontSize: 14, fontWeight: FontWeight.w600);

  static TextStyle get labelMedium =>
      nunito.copyWith(fontSize: 13, fontWeight: FontWeight.w700);

  static TextStyle get labelSmall => nunito.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
  );

  static TextStyle get caption =>
      nunito.copyWith(fontSize: 11, fontWeight: FontWeight.w700);

  static TextStyle get busNumber =>
      quicksand.copyWith(fontSize: 16, fontWeight: FontWeight.w700);

  static TextStyle get etaLarge =>
      quicksand.copyWith(fontSize: 28, fontWeight: FontWeight.w800);
}
