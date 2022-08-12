import 'package:flutter/material.dart';

abstract class Themes {
  const Themes._();

  static ThemeData get defaultTheme {
    final theme = ThemeData(
      primarySwatch: Colors.green,
    );

    return theme;
  }
}
