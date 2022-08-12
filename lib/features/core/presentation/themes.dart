import 'package:flutter/material.dart';

abstract class Themes {
  const Themes._();

  static ThemeData get defaultTheme => ThemeData(
        primarySwatch: Colors.green,
      );
}
