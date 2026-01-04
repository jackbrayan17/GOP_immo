import 'package:flutter/material.dart';

import 'app_shell.dart';
import 'theme/app_theme.dart';

class GpImmoApp extends StatelessWidget {
  const GpImmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GP Immo',
      theme: AppTheme.lightTheme(),
      home: const AppShell(),
    );
  }
}
