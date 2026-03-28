import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/controllers/clearbg_controller.dart';
import 'presentation/screens/home_screen.dart';

class ClearBgApp extends StatelessWidget {
  const ClearBgApp({required this.controller, super.key});

  final ClearBgController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClearBG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: HomeScreen(controller: controller),
    );
  }
}
