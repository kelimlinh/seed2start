import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // Visual language của “Hướng dẫn khởi nghiệp cùng Mầm”:
  // giấy kem + xanh lá + nâu đất + pastel ấm.
  static const paper = Color(0xFFFBF7EE);
  static const surface = Color(0xFFFFFDF8);
  static const leaf = Color(0xFF5F8D67);
  static const leafDark = Color(0xFF355C3E);
  static const sage = Color(0xFFDDE9DA);
  static const sageSoft = Color(0xFFEEF4EB);
  static const earth = Color(0xFF8A6A52);
  static const sand = Color(0xFFF1E5D5);
  static const sunshine = Color(0xFFF4E7B6);
  static const blush = Color(0xFFF3D9D5);
  static const ink = Color(0xFF26322A);
  static const inkMuted = Color(0xFF667068);
  static const outline = Color(0xFFE1DACD);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: leaf,
    brightness: Brightness.light,
    surface: surface,
  ).copyWith(
    primary: leaf,
    onPrimary: Colors.white,
    primaryContainer: sage,
    onPrimaryContainer: leafDark,
    secondary: earth,
    onSecondary: Colors.white,
    secondaryContainer: sand,
    onSecondaryContainer: const Color(0xFF4E392A),
    tertiary: const Color(0xFFB28755),
    tertiaryContainer: sunshine,
    onTertiaryContainer: const Color(0xFF4A381F),
    surface: surface,
    onSurface: ink,
    onSurfaceVariant: inkMuted,
    outline: const Color(0xFFBDB6AA),
    outlineVariant: outline,
    error: const Color(0xFFBA5A55),
    onError: Colors.white,
  );

  static TextStyle _heading(
    TextStyle? base, {
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.baloo2(
      textStyle: base,
      fontWeight: weight,
    );
  }

  static final TextTheme _textTheme = (() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
    ).textTheme;

    final body = GoogleFonts.beVietnamProTextTheme(base);

    return body.copyWith(
      displayLarge: _heading(body.displayLarge),
      displayMedium: _heading(body.displayMedium),
      displaySmall: _heading(body.displaySmall),
      headlineLarge: _heading(body.headlineLarge),
      headlineMedium: _heading(body.headlineMedium),
      headlineSmall: _heading(body.headlineSmall),
      titleLarge: _heading(body.titleLarge),
      titleMedium: _heading(body.titleMedium),
      titleSmall: _heading(
        body.titleSmall,
        weight: FontWeight.w600,
      ),
    );
  })();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: paper,
    colorScheme: _lightScheme,
    textTheme: _textTheme,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: surface.withValues(alpha: 0.98),
      indicatorColor: sage,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? leafDark : inkMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 23,
          color: selected ? leafDark : inkMuted,
        );
      }),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: surface,
      indicatorColor: sage,
      selectedIconTheme: IconThemeData(color: leafDark),
      unselectedIconTheme: IconThemeData(color: inkMuted),
      selectedLabelTextStyle: TextStyle(
        color: leafDark,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: inkMuted,
        fontWeight: FontWeight.w500,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 46),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        foregroundColor: leafDark,
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: leafDark,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: inkMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: leaf, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBA5A55)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: sageSoft,
      selectedColor: sage,
      side: const BorderSide(color: outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      labelStyle: const TextStyle(
        color: leafDark,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),
    dividerTheme: const DividerThemeData(
      color: outline,
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: leaf,
      linearTrackColor: sageSoft,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: leafDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
