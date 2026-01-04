import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../widgets/error_banner.dart';
import '../widgets/page_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.roleLabel});

  final String roleLabel;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _specializationController = TextEditingController();

  UserRole get _role {
    switch (widget.roleLabel.toLowerCase()) {
      case 'prestataire':
        return UserRole.provider;
      case 'client':
        return UserRole.client;
      default:
        return UserRole.owner;
    }
  }

  bool get _isProvider => _role == UserRole.provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().clearError();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppState state) async {
    if (!_formKey.currentState!.validate()) return;
    final success = await state.signup(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
      role: _role,
      specialization: _specializationController.text,
    );
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compte cree avec succes.')),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PageScaffold(
      title: 'Inscription ${widget.roleLabel}',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          Text(
            'Renseignez les informations pour continuer.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nom complet'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Nom requis.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email requis.';
                        }
                        if (!value.contains('@')) {
                          return 'Email invalide.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Telephone'),
                      keyboardType: TextInputType.phone,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Telephone requis.' : null,
                    ),
                    if (_isProvider) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _specializationController,
                        decoration: const InputDecoration(labelText: 'Specialisation'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Specialisation requise.' : null,
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Mot de passe requis.';
                        }
                        if (value.trim().length < 6) {
                          return '6 caracteres minimum.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmController,
                      decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Confirmation requise.';
                        }
                        if (value.trim() != _passwordController.text.trim()) {
                          return 'Les mots de passe ne correspondent pas.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.authLoading ? null : () => _submit(state),
                        child: Text(state.authLoading ? 'Creation...' : 'Creer le compte'),
                      ),
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
