import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../widgets/error_banner.dart';
import '../widgets/page_scaffold.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser;
    final isAuthenticated = state.isAuthenticated;

    return PageScaffold(
      title: 'Mon profil',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          if (isAuthenticated)
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: Text('Connecte en tant que ${user.name}'),
                subtitle: Text(user.roleLabel),
                trailing: TextButton(
                  onPressed: () {
                    context.read<AppState>().logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Se deconnecter'),
                ),
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const Icon(Icons.login_outlined),
                title: const Text('Connexion'),
                subtitle: const Text('Accedez a votre espace personnel.'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (!isAuthenticated)
            ToggleButtons(
              isSelected: [state.showOwner, !state.showOwner],
              onPressed: (index) => context.read<AppState>().setShowOwner(index == 0),
              borderRadius: BorderRadius.circular(14),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Proprietaire'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Prestataire'),
                ),
              ],
            ),
          if (!isAuthenticated) const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(user.roleLabel),
                  const SizedBox(height: 16),
                  if (user.email.isNotEmpty) _ProfileRow(label: 'Email', value: user.email),
                  _ProfileRow(label: 'Telephone', value: user.phone),
                  if (user.role == UserRole.provider)
                    _ProfileRow(label: 'Specialisation', value: user.specialization),
                  if (user.role == UserRole.provider)
                    _ProfileRow(label: 'Note moyenne', value: user.rating.toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (user.role == UserRole.provider)
            Card(
              child: SwitchListTile(
                value: user.marketplaceVisible,
                onChanged: (value) =>
                    context.read<AppState>().updateMarketplaceVisibility(user.id, value),
                title: const Text('Visible sur la marketplace'),
                subtitle: const Text('Activez pour recevoir plus de missions.'),
              ),
            ),
          if (user.role == UserRole.owner)
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Changer le mot de passe'),
                subtitle: const Text('Derniere mise a jour: il y a 2 mois'),
                onTap: () {},
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
