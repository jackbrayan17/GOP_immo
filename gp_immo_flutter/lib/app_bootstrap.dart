import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_state.dart';
import 'widgets/app_background.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    Future.microtask(() => context.read<AppState>().init());
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.initialized || state.loading) {
      return _LoadingScreen(
        errorMessage: state.errorMessage,
        onRetry: () => context.read<AppState>().init(),
      );
    }
    if (!state.isAuthenticated) {
      return const LoginScreen();
    }
    return const AppShell();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen({required this.errorMessage, required this.onRetry});

  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AppBackground(),
          Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PulseLogo(),
                    const SizedBox(height: 16),
                    Text(
                      errorMessage ?? 'Chargement de vos donnees...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (errorMessage != null)
                      ElevatedButton(
                        onPressed: onRetry,
                        child: const Text('Reessayer'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseLogo extends StatefulWidget {
  const _PulseLogo();

  @override
  State<_PulseLogo> createState() => _PulseLogoState();
}

class _PulseLogoState extends State<_PulseLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.home_work_outlined, color: Colors.white, size: 28),
      ),
    );
  }
}
