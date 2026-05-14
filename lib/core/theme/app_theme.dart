import 'package:flutter/material.dart';

/// Central Material 3 / legacy theme configuration.
abstract final class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}
