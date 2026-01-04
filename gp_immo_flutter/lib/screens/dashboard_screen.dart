import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../utils/formatting.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/section_header.dart';
import '../widgets/status_pill.dart';
import 'properties_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showOwner = true;

  @override
  Widget build(BuildContext context) {
    final owner = MockData.owner;
    final provider = MockData.providerLead;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Tableau de bord',
            eyebrow: _showOwner ? 'Bonjour ${owner.name}' : 'Bonjour ${provider.name}',
            action: _RoleToggle(
              showOwner: _showOwner,
              onToggle: (value) => setState(() => _showOwner = value),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _showOwner ? _ownerStats() : _providerStats(),
          ),
          const SizedBox(height: 28),
          if (_showOwner) _OwnerOverview() else _ProviderOverview(),
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
                  for (final message in MockData.messages.take(3))
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _ownerStats() {
    return [
      _StatCard(
        label: 'Biens',
        value: MockData.properties.length.toString(),
        icon: Icons.home_work_outlined,
      ),
      _StatCard(
        label: 'Contrats actifs',
        value: MockData.contracts.where((c) => c.status == ContractStatus.active).length.toString(),
        icon: Icons.assignment_outlined,
      ),
      _StatCard(
        label: 'Paiements en retard',
        value: MockData.payments.where((p) => p.status == PaymentStatus.late).length.toString(),
        icon: Icons.warning_amber_outlined,
      ),
    ];
  }

  List<Widget> _providerStats() {
    return [
      _StatCard(
        label: 'Missions en cours',
        value: MockData.missions.length.toString(),
        icon: Icons.handyman_outlined,
      ),
      _StatCard(
        label: 'Rapports envoyes',
        value: MockData.reports.length.toString(),
        icon: Icons.fact_check_outlined,
      ),
      _StatCard(
        label: 'Note moyenne',
        value: MockData.providerLead.rating.toStringAsFixed(1),
        icon: Icons.star_border,
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
  @override
  Widget build(BuildContext context) {
    final properties = MockData.properties;
    final contracts = MockData.contracts;
    final payments = MockData.payments;

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
                    subtitle: Text('Bien: ${MockData.propertyById(contract.propertyId).title}'),
                    trailing: StatusPill(
                      label: _contractStatusLabel(contract.status),
                      color: _contractStatusColor(contract.status),
                    ),
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
                      '${_paymentTypeLabel(payment.paymentType)} - ${MockData.propertyById(payment.propertyId).title}',
                    ),
                    trailing: StatusPill(
                      label: _paymentStatusLabel(payment.status),
                      color: _paymentStatusColor(payment.status),
                    ),
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
  @override
  Widget build(BuildContext context) {
    final missions = MockData.missions;
    final reports = MockData.reports;

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
                    subtitle: Text(MockData.propertyById(mission.propertyId).title),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
                    title: Text(MockData.propertyById(report.propertyId).title),
                    subtitle: Text(report.summary),
                    trailing: Text(formatDateTime(report.createdAt)),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

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
