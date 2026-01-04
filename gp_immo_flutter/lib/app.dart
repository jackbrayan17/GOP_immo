import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_bootstrap.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class GpImmoApp extends StatelessWidget {
  const GpImmoApp({
    super.key,
    this.appStateBuilder,
    this.home,
  });

  final AppState Function()? appStateBuilder;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => (appStateBuilder ?? AppState.new)(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GOP Immo',
        theme: AppTheme.lightTheme(),
        home: home ?? const AppBootstrap(),
      ),
    );
  }
}
