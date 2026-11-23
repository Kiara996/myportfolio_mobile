import 'package:material_ui/material_ui.dart';

/// Palet warna diport dari static/css/style.css di proyek Django.
class AppColors {
  static const ink = Color(0xFF161C30);
  static const paper = Color(0xFFF8F3E9);
  static const surface = Color(0xFFFFFDF7);
  static const accent = Color(0xFFEC5B40);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.ink).copyWith(
    primary: AppColors.ink,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    surface: AppColors.surface,
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.paper,
    useMaterial3: true,
  );
}
