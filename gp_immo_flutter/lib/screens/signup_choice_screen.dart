import 'package:flutter/material.dart';

import '../widgets/page_scaffold.dart';
import 'signup_screen.dart';

class SignupChoiceScreen extends StatelessWidget {
  const SignupChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Creer un compte',
      body: ListView(
        children: [
          Text(
            'Choisissez votre role.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _ChoiceCard(
                title: 'Proprietaire',
                description: 'Gerez vos biens, contrats, loyers et prestataires.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(roleLabel: 'Proprietaire'),
                  ),
                ),
              ),
              _ChoiceCard(
                title: 'Prestataire',
                description: 'Recevez des missions, devis et interventions.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(roleLabel: 'Prestataire'),
                  ),
                ),
              ),
              _ChoiceCard(
                title: 'Client',
                description: 'Achetez ou louez un bien, contactez les equipes.',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SignupScreen(roleLabel: 'Client'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
