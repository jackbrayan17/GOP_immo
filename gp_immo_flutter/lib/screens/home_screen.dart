import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatting.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/property_market_card.dart';
import '../widgets/provider_picker.dart';
import '../widgets/section_header.dart';
import 'marketplace_screen.dart';
import 'signup_choice_screen.dart';
import 'conversation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final providers = state.providers.take(3).toList();
    final properties = state.properties;
    final propertyPreviews = properties.take(3).toList();
    final paymentsDue = state.payments.where((payment) => payment.status != PaymentStatus.paid).length;
    final messagesCount = state.messages.length;
    final client =
        state.currentUser.role == UserRole.client ? state.currentUser : state.client;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
              onRetry: () => context.read<AppState>().reload(),
            ),
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
          _LocationCard(
            locationLabel: state.locationLabel,
            updatedAt: state.locationUpdatedAt,
            loading: state.locationLoading,
            onRefresh: () => context.read<AppState>().refreshLocation(),
          ),
          const SizedBox(height: 32),
          SectionHeader(
            title: 'Biens disponibles',
            eyebrow: 'Espace client',
            action: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MarketplaceScreen(
                    initialSection: MarketplaceSection.properties,
                  ),
                ),
              ),
              child: const Text('Voir tous'),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < propertyPreviews.length; i++)
                AnimatedReveal(
                  delay: Duration(milliseconds: 120 * i),
                  child: PropertyMarketCard(
                    property: propertyPreviews[i],
                    owner: state.userById(propertyPreviews[i].ownerId),
                    onPrimaryAction: () =>
                        _handlePropertyAction(context, propertyPreviews[i]),
                    onContactOwner: () =>
                        _contactOwner(context, state, propertyPreviews[i], client),
                    onContactProvider: () =>
                        _contactProvider(context, state, client),
                  ),
                ),
            ],
          ),
          if (propertyPreviews.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: EmptyStateCard(
                title: 'Aucun bien disponible',
                message: 'Revenez plus tard pour les nouvelles offres.',
              ),
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
            title: 'Prestataires recommandes',
            eyebrow: 'Espace client',
            action: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MarketplaceScreen(
                    initialSection: MarketplaceSection.providers,
                  ),
                ),
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
                  child: _ProviderPreviewCard(
                    provider: providers[i],
                    onContact: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(
                          contact: providers[i],
                          currentUserOverride: client,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (providers.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: EmptyStateCard(
                title: 'Aucun prestataire',
                message: 'Les prestataires seront visibles apres activation du profil.',
              ),
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
                    properties.isEmpty || state.payments.isEmpty
                        ? 'Dernier loyer: -'
                        : 'Dernier loyer: ${formatCurrency(state.payments.first.amount)}',
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
          'Plateforme proprietaires, prestataires & clients',
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
  const _ProviderPreviewCard({required this.provider, required this.onContact});

  final AppUser provider;
  final VoidCallback onContact;

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
                onPressed: onContact,
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.locationLabel,
    required this.updatedAt,
    required this.loading,
    required this.onRefresh,
  });

  final String? locationLabel;
  final DateTime? updatedAt;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              child: Icon(
                Icons.place_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Localisation', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    locationLabel ?? 'Cliquez pour activer la geolocalisation.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (updatedAt != null)
                    Text(
                      'Mis a jour: ${formatDateTime(updatedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: loading ? null : onRefresh,
              child: Text(loading ? '...' : 'Actualiser'),
            ),
          ],
        ),
      ),
    );
  }
}

void _handlePropertyAction(BuildContext context, Property property) {
  final isForSale = property.listingStatus.toLowerCase().contains('vente');
  final prefix = isForSale ? 'd\'achat' : 'de location';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Demande $prefix envoyee pour ${property.title}.'),
    ),
  );
}

void _contactOwner(BuildContext context, AppState state, Property property, AppUser client) {
  final owner = state.userById(property.ownerId);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        contact: owner,
        currentUserOverride: client,
      ),
    ),
  );
}

Future<void> _contactProvider(BuildContext context, AppState state, AppUser client) async {
  final provider = await showProviderPicker(context, state.providers);
  if (!context.mounted || provider == null) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ConversationScreen(
        contact: provider,
        currentUserOverride: client,
      ),
    ),
  );
}
