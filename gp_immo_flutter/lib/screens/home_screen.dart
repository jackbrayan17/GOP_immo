import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../utils/formatting.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/section_header.dart';
import 'marketplace_screen.dart';
import 'signup_choice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final providers = MockData.providers().take(3).toList();
    final properties = MockData.properties;
    final paymentsDue = MockData.payments.where((payment) => payment.status != PaymentStatus.paid).length;
    final messagesCount = MockData.messages.length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroSection(
            onPrimary: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SignupChoiceScreen()),
            ),
            onSecondary: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                label: 'Biens suivis',
                value: properties.length.toString(),
                icon: Icons.home_work_outlined,
              ),
              _StatCard(
                label: 'Paiements en cours',
                value: paymentsDue.toString(),
                icon: Icons.payments_outlined,
              ),
              _StatCard(
                label: 'Messages',
                value: messagesCount.toString(),
                icon: Icons.chat_bubble_outline,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const SectionHeader(
            title: 'Votre cockpit immobilier',
            eyebrow: 'Fonctionnalites',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _FeatureCard(
                title: 'Gestion des biens',
                description: 'Ajoutez appartements, studios, magasins ou immeubles.',
                icon: Icons.domain_outlined,
              ),
              _FeatureCard(
                title: 'Contrats et paiements',
                description: 'Suivez loyers, contrats et paiements prestataires.',
                icon: Icons.assignment_outlined,
              ),
              _FeatureCard(
                title: 'Prestataires verifies',
                description: 'Choisissez par specialisation et note de confiance.',
                icon: Icons.verified_outlined,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SectionHeader(
            title: 'Prestataires en vitrine',
            eyebrow: 'Marketplace',
            action: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
              ),
              child: const Text('Tout voir'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < providers.length; i++)
                AnimatedReveal(
                  delay: Duration(milliseconds: 120 * i),
                  child: _ProviderPreviewCard(provider: providers[i]),
                ),
            ],
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vue rapide', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  _BulletRow(
                    label: 'Contrats et loyers suivis',
                  ),
                  _BulletRow(
                    label: 'Chat et devis prestataires',
                  ),
                  _BulletRow(
                    label: 'Rapports archives et telechargement',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dernier loyer: ${formatCurrency(MockData.payments.first.amount)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.onPrimary,
    required this.onSecondary,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 840;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: _HeroCopy(onPrimary: onPrimary, onSecondary: onSecondary)),
                      const SizedBox(width: 24),
                      const Expanded(child: _HeroHighlight()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCopy(onPrimary: onPrimary, onSecondary: onSecondary),
                      const SizedBox(height: 20),
                      const _HeroHighlight(),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.onPrimary,
    required this.onSecondary,
  });

  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plateforme proprietaires & prestataires',
          style: textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
        ),
        const SizedBox(height: 12),
        Text(
          'GP Immo : pilotez vos biens, contrats et interventions.',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Suivi des loyers, gestion des contrats, messagerie type chat et marketplace pour trouver la bonne expertise.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: onPrimary,
              child: const Text('Creer un compte'),
            ),
            OutlinedButton(
              onPressed: onSecondary,
              child: const Text('Voir les prestataires'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroHighlight extends StatelessWidget {
  const _HeroHighlight();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vue rapide', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          const _BulletRow(label: 'Contrats et loyers suivis'),
          const _BulletRow(label: 'Chat et devis prestataires'),
          const _BulletRow(label: 'Rapports archives'),
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  const _BulletRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 300),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderPreviewCard extends StatelessWidget {
  const _ProviderPreviewCard({required this.provider});

  final AppUser provider;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 280),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(provider.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(provider.specialization, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Text('Note: ${provider.rating.toStringAsFixed(1)} / 5'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                child: const Text('Contacter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 260),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
