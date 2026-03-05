import 'package:flutter/material.dart';

class AppTheme {
  // 🎯 BRAND COLORS — Premium palette
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF00D9A6);
  static const tertiary = Color(0xFFFF6B8A);
  static const accent = Color(0xFFFFA26B);

  static const backgroundLight = Color(0xFFF5F6FA);
  static const backgroundDark = Color(0xFF0D1117);
  static const surfaceDark = Color(0xFF161B22);
  static const cardDark = Color(0xFF1C2128);

  // Gradient presets
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B8A), Color(0xFFFFA26B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Category colors
  static const Map<String, Color> categoryColors = {
    'General': Color(0xFF6C63FF),
    'Work': Color(0xFF3B82F6),
    'Personal': Color(0xFFFF6B8A),
    'Health': Color(0xFF00D9A6),
    'Fitness': Color(0xFFFF8C42),
    'Education': Color(0xFF8B5CF6),
    'Finance': Color(0xFF10B981),
    'Shopping': Color(0xFFF59E0B),
    'Social': Color(0xFFEC4899),
    'Travel': Color(0xFF06B6D4),
    'Food': Color(0xFFEF4444),
    'Entertainment': Color(0xFFA855F7),
  };

  // Category icons
  static const Map<String, IconData> categoryIcons = {
    'General': Icons.category_rounded,
    'Work': Icons.work_rounded,
    'Personal': Icons.person_rounded,
    'Health': Icons.favorite_rounded,
    'Fitness': Icons.fitness_center_rounded,
    'Education': Icons.school_rounded,
    'Finance': Icons.account_balance_wallet_rounded,
    'Shopping': Icons.shopping_bag_rounded,
    'Social': Icons.people_rounded,
    'Travel': Icons.flight_rounded,
    'Food': Icons.restaurant_rounded,
    'Entertainment': Icons.movie_rounded,
  };

  static List<String> get categories => categoryColors.keys.toList();

  static Color getCategoryColor(String category) {
    return categoryColors[category] ?? primary;
  }

  static IconData getCategoryIcon(String category) {
    return categoryIcons[category] ?? Icons.category_rounded;
  }

  // 🌞 LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Roboto',

    scaffoldBackgroundColor: backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1D26),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1D26),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFF1A1D26)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      elevation: 12,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFFB0B7C3),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF0F1F5),
      selectedColor: primary.withOpacity(0.15),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return const Color(0xFFCCD0D8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return primary.withOpacity(0.3);
        return const Color(0xFFE5E7EB);
      }),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEFF3),
      thickness: 1,
    ),
  );

  // 🌙 DARK THEME
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',

    scaffoldBackgroundColor: backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: tertiary,
      surface: surfaceDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFFE6EDF3),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFE6EDF3),
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFFE6EDF3)),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      elevation: 12,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF6E7681),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF21262D),
      selectedColor: primary.withOpacity(0.2),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF21262D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF30363D), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return const Color(0xFF484F58);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return primary.withOpacity(0.3);
        return const Color(0xFF30363D);
      }),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF21262D),
      thickness: 1,
    ),
  );
}