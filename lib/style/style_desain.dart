import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color hondaRed = Color(0xFFE4051C);
  static const Color hondaRedDark = Color(0xFFB80414);
  static const Color ink = Color(0xFF15171C);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color steel = Color(0xFF6B7280);
  static const Color line = Color(0xFFEAEAEA);

  static const Color cardSurface = Color(0xFFFFFFFF);
}

class AppText {
  static TextStyle display({Color color = Colors.white}) =>
      GoogleFonts.barlow(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.1,
      );

  static TextStyle headline({Color color = AppColors.ink}) =>
      GoogleFonts.barlow(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.2,
      );

  static TextStyle cardTitle({Color color = AppColors.ink}) =>
      GoogleFonts.barlow(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle subtitle({Color color = AppColors.steel}) =>
      GoogleFonts.barlow(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.4,
      );

  static TextStyle body({Color color = AppColors.ink}) => GoogleFonts.barlow(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.5,
      );

  static TextStyle label({Color color = AppColors.steel}) =>
      GoogleFonts.barlow(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle price({Color color = AppColors.hondaRed}) =>
      GoogleFonts.barlow(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle logoMark({Color color = Colors.white}) =>
      GoogleFonts.barlow(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.3,
      );
}