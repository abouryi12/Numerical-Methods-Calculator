import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Background Layers (cool blue undertone to match logo) ───
const Color kBgBase = Color(0xFF0A0B10);
const Color kBgSurface = Color(0xFF12131A);
const Color kBgElevated = Color(0xFF1A1B24);
const Color kBgBorder = Color(0xFF252633);

// ─── Text Colors ───
const Color kTextPrimary = Color(0xFFF0F0F5);
const Color kTextSecondary = Color(0xFF7A7A92);
const Color kTextMuted = Color(0xFF3A3A4D);

// ─── Accent (matching logo blue highlight) ───
const Color kAccentBlue = Color(0xFF4A9EFF);
const Color kAccentPurple = Color(0xFF7B6FF0);
const Color kAccentPink = Color(0xFFFCA5A5);

// ─── Semantic ───
const Color kSuccess = Color(0xFF2D6A4F);
const Color kSuccessText = Color(0xFF86EFAC);
const Color kError = Color(0xFF7F1D1D);
const Color kErrorText = Color(0xFFFCA5A5);
const Color kWarning = Color(0xFF78350F);
const Color kWarningText = Color(0xFFFCD34D);

// ─── Typography Scale ───
const double kTextXS = 11.0;
const double kTextSM = 13.0;
const double kTextBase = 15.0;
const double kTextLG = 18.0;
const double kTextXL = 24.0;
const double kText2XL = 32.0;
const double kText3XL = 48.0;

// ─── Spacing (4px base) ───
const double kSpace1 = 4.0;
const double kSpace2 = 8.0;
const double kSpace3 = 12.0;
const double kSpace4 = 16.0;
const double kSpace5 = 20.0;
const double kSpace6 = 24.0;
const double kSpace8 = 32.0;
const double kSpace10 = 40.0;
const double kSpace12 = 48.0;
const double kSpace16 = 64.0;

// ─── Border Radius ───
const double kRadiusXS = 4.0;
const double kRadiusSM = 6.0;
const double kRadiusMD = 10.0;
const double kRadiusLG = 16.0;

// ─── Category Accent Colors ───
const Color kCategoryRootFinding = kAccentBlue;
const Color kCategoryLinearSystems = Color(0xFF3DDC84);
const Color kCategoryIterative = Color(0xFFFFB74D);
const Color kCategoryInterpolation = kAccentPurple;

/// Builds the app [ThemeData] — dark theme only.
ThemeData buildAppTheme() {
  final inter = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBgBase,
    colorScheme: const ColorScheme.dark(
      surface: kBgSurface,
      primary: kAccentBlue,
      error: kErrorText,
      onSurface: kTextPrimary,
      onPrimary: Colors.white,
    ),
    textTheme: inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        fontSize: kText3XL,
        fontWeight: FontWeight.w600,
        color: kTextPrimary,
        letterSpacing: -0.02 * kText3XL,
        height: 1.2,
      ),
      displayMedium: inter.displayMedium?.copyWith(
        fontSize: kText2XL,
        fontWeight: FontWeight.w600,
        color: kTextPrimary,
        letterSpacing: -0.02 * kText2XL,
        height: 1.2,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        fontSize: kTextXL,
        fontWeight: FontWeight.w600,
        color: kTextPrimary,
        height: 1.2,
      ),
      headlineMedium: inter.headlineMedium?.copyWith(
        fontSize: kTextLG,
        fontWeight: FontWeight.w500,
        color: kTextPrimary,
        height: 1.2,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: kTextBase,
        fontWeight: FontWeight.w400,
        color: kTextPrimary,
        height: 1.5,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: kTextSM,
        fontWeight: FontWeight.w400,
        color: kTextSecondary,
        height: 1.5,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B6B80),
        letterSpacing: 11.0 * 0.08,
        height: 1.5,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBgBase,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontSize: kTextBase,
        fontWeight: FontWeight.w500,
        color: kTextPrimary,
      ),
      iconTheme: const IconThemeData(color: kTextSecondary, size: 20),
    ),
    cardTheme: CardThemeData(
      color: kBgSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: const BorderSide(color: kBgBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF111116),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF232329), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF232329), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Color(0xFF4A8FE8), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: kError, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: kSpace3,
        horizontal: kSpace4,
      ),
      hintStyle: GoogleFonts.robotoMono(
        fontSize: kTextBase,
        color: kTextMuted,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: kTextSM,
        color: kErrorText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4A8FE8),
        foregroundColor: Colors.white,
        disabledBackgroundColor: kBgElevated,
        disabledForegroundColor: kTextMuted,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: kBgBorder,
      thickness: 1,
      space: 0,
    ),
    splashColor: Colors.transparent,
    highlightColor: kBgBorder.withValues(alpha: 0.3),
  );
}

/// Roboto Mono text style helper for math / code contexts.
TextStyle monoStyle({
  double fontSize = kTextBase,
  Color color = kTextPrimary,
  FontWeight fontWeight = FontWeight.w400,
}) {
  return GoogleFonts.robotoMono(
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}
