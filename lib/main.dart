import 'package:flutter/material.dart';

import 'core/presentation/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Cart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const Scaffold(body: Center(child: Text('Shopping Cart App'))),
    );
  }
}
