import 'package:flutter/material.dart';

sealed class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
  );
}
