import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème Mira - Source de vérité Design System Hackathon.
abstract final class MiraTheme {
  // ── Tokens Couleurs ──────────────────────────────────────────────────────
  static const Color miraRed = Color(0xFFE6332A);
  static const Color warmBeige = Color(0xFFEFEAE5);
  static const Color charcoal = Color(0xFF1D1D1B);
  static const Color muted = Color(0xFF888888);
  static const Color mutedSoft = Color(0xFFB6B0A6);
  static const Color beigeDeep = Color(0xFFE2DCD3);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color rule = Color(0xFFE5E7EB);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);
  static const Color gold = Color(0xFFD4A853);
  static const Color pastelSage = Color(0xFFA8C5A2);

  // ── ThemeData ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: warmBeige,
      colorScheme: const ColorScheme.light(
        primary: miraRed,
        onPrimary: Colors.white,
        surface: warmBeige,
        onSurface: charcoal,
        error: error,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.manropeTextTheme(baseTheme.textTheme).copyWith(
        // Titres éditoriaux en Playfair Display
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: charcoal,
          height: 1.1,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: charcoal,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: charcoal,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          color: charcoal,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          color: muted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: warmBeige,
        foregroundColor: charcoal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: charcoal,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: miraRed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(44), // Hauteur fixe 44px
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          minimumSize: const Size.fromHeight(44),
          side: const BorderSide(color: rule),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        backgroundColor: cardBg,
        selectedColor: miraRed,
        secondarySelectedColor: miraRed,
        disabledColor: beigeDeep,
        checkmarkColor: Colors.white,
        labelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: charcoal,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: const BorderSide(color: mutedSoft),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: rule),
        ),
      ),
    );
  }
}
