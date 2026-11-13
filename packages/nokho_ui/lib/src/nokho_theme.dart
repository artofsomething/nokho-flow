import 'package:flutter/material.dart';

/// Placeholder theme; real tokens come with the design-system work in Phase 0.
abstract final class NokhoTheme {
  static const Color seed = Color(0xFF3D5AFE);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
