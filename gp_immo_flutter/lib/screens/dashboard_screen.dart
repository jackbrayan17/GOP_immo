import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatting.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';
import 'properties_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final owner = state.owner;
    final provider = state.providerLead;
    final showOwner = state.showOwner;
    final canToggleRole = state.canToggleRole;

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
          SectionHeader(
            title: 'Tableau de bord',
            eyebrow: showOwner ? 'Bonjour ${owner.name}' : 'Bonjour ${provider.name}',
            action: canToggleRole
                ? _RoleToggle(
                    showOwner: showOwner,
                    onToggle: (value) => context.read<AppState>().setShowOwner(value),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: showOwner ? _ownerStats(state) : _providerStats(state),
          ),
          const SizedBox(height: 28),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: showOwner
                ? _OwnerOverview(key: const ValueKey('owner'), state: state)
                : _ProviderOverview(key: const ValueKey('provider'), state: state),
          ),
          const SizedBox(height: 28),
          const SectionHeader(
            title: 'Messagerie',
            eyebrow: 'Derniers echanges',
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final message in state.messages.take(3))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.chat, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(message.content),
                      subtitle: Text(formatDateTime(message.createdAt)),
                      trailing: Icon(message.hasAttachment ? Icons.attach_file : Icons.arrow_forward),
                    ),
                  if (state.messages.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Aucun message pour le moment.'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Actions rapides'),
                        Text(
                          'Notifications et localisation',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<AppState>().sendTestNotification(),
                    child: const Text('Notifier'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => context.read<AppState>().refreshLocation(),
                    child: const Text('Localiser'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _ownerStats(AppState state) {
    return [
      AnimatedStatCard(
        label: 'Biens',
        value: state.properties.length.toDouble(),
        icon: Icons.home_work_outlined,
        color: const Color(0xFF1E6F6D),
      ),
      AnimatedStatCard(
        label: 'Contrats actifs',
        value: state.contracts.where((c) => c.status == ContractStatus.active).length.toDouble(),
        icon: Icons.assignment_outlined,
        color: const Color(0xFFE37A5C),
      ),
      AnimatedStatCard(
        label: 'Paiements en retard',
        value: state.payments.where((p) => p.status == PaymentStatus.late).length.toDouble(),
        icon: Icons.warning_amber_outlined,
        color: const Color(0xFFB42318),
      ),
    ];
  }

  List<Widget> _providerStats(AppState state) {
    return [
      AnimatedStatCard(
        label: 'Missions en cours',
        value: state.missions.length.toDouble(),
        icon: Icons.handyman_outlined,
        color: const Color(0xFF1E6F6D),
      ),
      AnimatedStatCard(
        label: 'Rapports envoyes',
        value: state.reports.length.toDouble(),
        icon: Icons.fact_check_outlined,
        color: const Color(0xFFE37A5C),
      ),
      AnimatedStatCard(
        label: 'Note moyenne',
        value: state.providerLead.rating,
        valueLabel: state.providerLead.rating.toStringAsFixed(1),
        icon: Icons.star_border,
        color: const Color(0xFFF2C469),
      ),
    ];
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.showOwner, required this.onToggle});

  final bool showOwner;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [showOwner, !showOwner],
      onPressed: (index) => onToggle(index == 0),
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
    );
  }
}

class _OwnerOverview extends StatelessWidget {
  const _OwnerOverview({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final properties = state.properties;
    final contracts = state.contracts;
    final payments = state.payments;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Mes biens',
          action: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PropertiesScreen()),
            ),
            child: const Text('Voir tous'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (var i = 0; i < properties.length; i++)
              AnimatedReveal(
                delay: Duration(milliseconds: 80 * i),
                child: _PropertyCard(property: properties[i]),
              ),
          ],
        ),
        if (properties.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: EmptyStateCard(
              title: 'Aucun bien',
              message: 'Ajoutez votre premier bien pour voir le suivi ici.',
            ),
          ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Contrats recents'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final contract in contracts)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(contract.tenantName),
                    subtitle: Text('Bien: ${_propertyTitle(state, contract.propertyId)}'),
                    trailing: StatusPill(
                      label: _contractStatusLabel(contract.status),
                      color: _contractStatusColor(contract.status),
                    ),
                  ),
                if (contracts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Aucun contrat recent.'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Paiements recents'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final payment in payments)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(formatCurrency(payment.amount)),
                    subtitle: Text(
                      '${_paymentTypeLabel(payment.paymentType)} - ${_propertyTitle(state, payment.propertyId)}',
                    ),
                    trailing: StatusPill(
                      label: _paymentStatusLabel(payment.status),
                      color: _paymentStatusColor(payment.status),
                    ),
                  ),
                if (payments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Aucun paiement recent.'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProviderOverview extends StatelessWidget {
  const _ProviderOverview({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final missions = state.missions;
    final reports = state.reports;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Missions en cours'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final mission in missions)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(mission.status),
                    subtitle: Text(_propertyTitle(state, mission.propertyId)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                if (missions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Pas de mission active.'),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Mes rapports'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final report in reports)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(_propertyTitle(state, report.propertyId)),
                    subtitle: Text(report.summary),
                    trailing: Text(formatDateTime(report.createdAt)),
                  ),
                if (reports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Aucun rapport pour le moment.'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('${property.propertyType} - ${property.listingStatus}'),
              const SizedBox(height: 6),
              Text(property.address, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              StatusPill(
                label: property.listingStatus,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _contractStatusLabel(ContractStatus status) {
  switch (status) {
    case ContractStatus.draft:
      return 'Brouillon';
    case ContractStatus.active:
      return 'Actif';
    case ContractStatus.closed:
      return 'Termine';
  }
}

Color _contractStatusColor(ContractStatus status) {
  switch (status) {
    case ContractStatus.draft:
      return const Color(0xFFB54708);
    case ContractStatus.active:
      return const Color(0xFF027A48);
    case ContractStatus.closed:
      return const Color(0xFF344054);
  }
}

String _paymentStatusLabel(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return 'En attente';
    case PaymentStatus.paid:
      return 'Paye';
    case PaymentStatus.late:
      return 'Retard';
  }
}

Color _paymentStatusColor(PaymentStatus status) {
  switch (status) {
    case PaymentStatus.pending:
      return const Color(0xFFB54708);
    case PaymentStatus.paid:
      return const Color(0xFF027A48);
    case PaymentStatus.late:
      return const Color(0xFFB42318);
  }
}

String _paymentTypeLabel(PaymentType type) {
  switch (type) {
    case PaymentType.rent:
      return 'Loyer';
    case PaymentType.booking:
      return 'Reservation';
    case PaymentType.provider:
      return 'Prestataire';
  }
}

String _propertyTitle(AppState state, String propertyId) {
  for (final property in state.properties) {
    if (property.id == propertyId) {
      return property.title;
    }
  }
  return 'Bien inconnu';
}
