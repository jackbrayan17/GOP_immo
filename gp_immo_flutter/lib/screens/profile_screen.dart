import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../widgets/page_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showOwner = true;
  bool _marketplaceVisible = true;

  @override
  Widget build(BuildContext context) {
    final user = _showOwner ? MockData.owner : MockData.providerLead;

    return PageScaffold(
      title: 'Mon profil',
      body: ListView(
        children: [
          ToggleButtons(
            isSelected: [_showOwner, !_showOwner],
            onPressed: (index) => setState(() => _showOwner = index == 0),
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
          const SizedBox(height: 16),
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
                value: _marketplaceVisible,
                onChanged: (value) => setState(() => _marketplaceVisible = value),
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
