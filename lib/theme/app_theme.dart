import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Alemia brand colors
  // ---------------------------------------------------------------------------

  static const Color black = Color(0xFF0B0D10);
  static const Color blackSoft = Color(0xFF14161A);
  static const Color blackElevated = Color(0xFF22252B);

  static const Color gold = Color(0xFFD6A51F);
  static const Color goldLight = Color(0xFFF4C542);
  static const Color goldSoft = Color(0xFFFFF3C4);
  static const Color goldPale = Color(0xFFFFF9E8);

  static const Color backgroundLight = Color(0xFFF7F6F2);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111318);
  static const Color textSecondary = Color(0xFF6C7178);

  static const Color textPrimaryDark = Color(0xFFF7F7F5);
  static const Color textSecondaryDark = Color(0xFFB7BBC2);

  static const Color borderLight = Color(0xFFE7E4DC);
  static const Color borderDark = Color(0xFF2B2E34);

  static const Color success = Color(0xFF25965A);
  static const Color warning = Color(0xFFE2A81A);
  static const Color danger = Color(0xFFD94A4A);
  static const Color info = Color(0xFF3977D5);

  // ---------------------------------------------------------------------------
  // Legacy aliases
  //
  // These names are already used throughout the developer's source code.
  // We preserve them to avoid a massive rewrite while applying Alemia branding.
  // ---------------------------------------------------------------------------

  static const Color primary = black;
  static const Color splashBackground = backgroundLight;

  static const Color mint100 = goldPale;
  static const Color mint200 = goldSoft;
  static const Color mint300 = Color(0xFFF0D77B);
  static const Color mint400 = gold;

  static const Color softOrange800 = gold;
  static const Color softOrange900 = Color(0xFFB88712);

  static const Color softBlue800 = Color(0xFF4D5968);
  static const Color softBlue900 = Color(0xFF657181);

  static const Color softGray150 = Color(0xFFF3F2EE);

  // Dark theme aliases
  static const Color primaryDark = blackElevated;
  static const Color backgroundDark = black;
  static const Color surfaceDark = blackSoft;

  static const Color mint100Dark = Color(0xFF2A2414);
  static const Color mint200Dark = Color(0xFF3A3015);
  static const Color mint300Dark = Color(0xFF7C6018);
  static const Color mint400Dark = goldLight;

  // ---------------------------------------------------------------------------
  // Typography
  // ---------------------------------------------------------------------------

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      color: textPrimary,
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      color: textPrimary,
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    displaySmall: TextStyle(
      color: textPrimary,
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    headlineLarge: TextStyle(
      color: textPrimary,
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: textPrimary,
      fontSize: 21,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      color: textPrimary,
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: textPrimary,
      fontSize: 18,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: textPrimary,
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: textPrimary,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: textPrimary,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: textPrimary,
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: textSecondary,
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: textPrimary,
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: textPrimary,
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      color: textSecondary,
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
  );

  static const TextTheme darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      color: textPrimaryDark,
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    displayMedium: TextStyle(
      color: textPrimaryDark,
      fontSize: 28,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    displaySmall: TextStyle(
      color: textPrimaryDark,
      fontSize: 24,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    headlineLarge: TextStyle(
      color: textPrimaryDark,
      fontSize: 24,
      height: 1.25,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: textPrimaryDark,
      fontSize: 21,
      height: 1.3,
      fontWeight: FontWeight.w700,
    ),
    headlineSmall: TextStyle(
      color: textPrimaryDark,
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: textPrimaryDark,
      fontSize: 18,
      height: 1.35,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: textPrimaryDark,
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: TextStyle(
      color: textPrimaryDark,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: TextStyle(
      color: textPrimaryDark,
      fontSize: 16,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      color: textPrimaryDark,
      fontSize: 14,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: TextStyle(
      color: textSecondaryDark,
      fontSize: 12,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: TextStyle(
      color: textPrimaryDark,
      fontSize: 14,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: TextStyle(
      color: textPrimaryDark,
      fontSize: 12,
      height: 1.2,
      fontWeight: FontWeight.w600,
    ),
    labelSmall: TextStyle(
      color: textSecondaryDark,
      fontSize: 11,
      height: 1.2,
      fontWeight: FontWeight.w500,
    ),
  );

  // ---------------------------------------------------------------------------
  // Color schemes
  // ---------------------------------------------------------------------------

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: gold,
    brightness: Brightness.light,
  ).copyWith(
    primary: black,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: black,
    surface: surfaceLight,
    onSurface: textPrimary,
    error: danger,
    onError: Colors.white,
    outline: borderLight,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: gold,
    brightness: Brightness.dark,
  ).copyWith(
    primary: blackElevated,
    onPrimary: Colors.white,
    secondary: goldLight,
    onSecondary: black,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    error: danger,
    onError: Colors.white,
    outline: borderDark,
  );

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      fontFamily: 'Montserrat',
      textTheme: textTheme,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: surfaceLight,
      dividerColor: borderLight,
      splashColor: gold.withValues(alpha: 0.10),
      highlightColor: gold.withValues(alpha: 0.06),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: backgroundLight,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderLight,
            width: 0.7,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: gold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: danger,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 52),
          backgroundColor: black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD5D5D2),
          disabledForegroundColor: const Color(0xFF8A8D91),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: black,
          side: const BorderSide(color: borderLight),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: black,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: goldPale,
        selectedColor: goldSoft,
        disabledColor: const Color(0xFFECEBE7),
        side: const BorderSide(color: borderLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: black,
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 0.8,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: blackSoft,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: goldPale,
        circularTrackColor: goldPale,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceLight,
        modalBarrierColor: Color(0x660B0D10),
        showDragHandle: true,
        dragHandleColor: borderLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      fontFamily: 'Montserrat',
      textTheme: darkTextTheme,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
      dividerColor: borderDark,
      splashColor: goldLight.withValues(alpha: 0.12),
      highlightColor: goldLight.withValues(alpha: 0.08),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontFamily: 'Montserrat',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: borderDark,
            width: 0.7,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: textSecondaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: goldLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: danger,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(48, 52),
          backgroundColor: goldLight,
          foregroundColor: black,
          disabledBackgroundColor: const Color(0xFF30333A),
          disabledForegroundColor: const Color(0xFF7D828A),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          foregroundColor: textPrimaryDark,
          side: const BorderSide(color: borderDark),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldLight,
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: mint100Dark,
        selectedColor: mint200Dark,
        disabledColor: blackElevated,
        side: const BorderSide(color: borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: const TextStyle(
          color: textPrimaryDark,
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: goldLight,
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 0.8,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: blackElevated,
        contentTextStyle: const TextStyle(
          color: textPrimaryDark,
          fontFamily: 'Montserrat',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: goldLight,
        linearTrackColor: mint100Dark,
        circularTrackColor: mint100Dark,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceDark,
        modalBarrierColor: Color(0x99000000),
        showDragHandle: true,
        dragHandleColor: borderDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Theme-aware helpers
  // ---------------------------------------------------------------------------

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color getBackgroundColor(BuildContext context) {
    return isDark(context) ? backgroundDark : backgroundLight;
  }

  static Color getCardColor(BuildContext context) {
    return isDark(context) ? surfaceDark : surfaceLight;
  }

  static Color getSurfaceColor(BuildContext context) {
    return isDark(context) ? surfaceDark : surfaceLight;
  }

  static Color getPrimaryColor(BuildContext context) {
    return isDark(context) ? blackElevated : black;
  }

  static Color getAccentColor(BuildContext context) {
    return isDark(context) ? goldLight : gold;
  }

  static Color getTextColor(BuildContext context) {
    return isDark(context) ? textPrimaryDark : textPrimary;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return isDark(context) ? textSecondaryDark : textSecondary;
  }

  static Color getBorderColor(BuildContext context) {
    return isDark(context) ? borderDark : borderLight;
  }

  static Color getMint100(BuildContext context) {
    return isDark(context) ? mint100Dark : mint100;
  }

  static Color getMint200(BuildContext context) {
    return isDark(context) ? mint200Dark : mint200;
  }

  static Color getMint300(BuildContext context) {
    return isDark(context) ? mint300Dark : mint300;
  }

  static Color getMint400(BuildContext context) {
    return isDark(context) ? mint400Dark : mint400;
  }

  static Color getSoftGray150(BuildContext context) {
    return isDark(context) ? surfaceDark : softGray150;
  }
}