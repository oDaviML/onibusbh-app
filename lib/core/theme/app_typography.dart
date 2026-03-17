import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  /// Defines Manrope as the display font (e.g. Navigation titles, main headings)
  static TextStyle get display => GoogleFonts.manrope();

  /// Defines Quicksand as the body/title font (e.g. Card headings, primary info)
  static TextStyle get quicksand => GoogleFonts.quicksand();

  /// Defines Nunito as the secondary/subtitle font (e.g. Subtitles, labels)
  static TextStyle get nunito => GoogleFonts.nunito();
}
