import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../utils/formatting.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/status_pill.dart';
import 'forms/assign_provider_screen.dart';
import 'forms/contract_form_screen.dart';
import 'forms/media_upload_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final owner = MockData.owner;

    return PageScaffold(
      title: property.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {},
        ),
      ],
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.address, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(property.description),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: property.listingStatus,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      StatusPill(
                        label: property.furnished ? 'Meuble' : 'Non meuble',
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      StatusPill(
                        label: formatCurrency(property.price),
                        color: const Color(0xFF027A48),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Proprietaire', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(owner.name),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AssignProviderScreen()),
                  ),
                  icon: const Icon(Icons.people_outline),
                  label: const Text('Associer prestataire'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ContractFormScreen()),
                  ),
                  icon: const Icon(Icons.assignment_outlined),
                  label: const Text('Nouveau contrat'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MediaUploadScreen()),
            ),
            icon: const Icon(Icons.perm_media_outlined),
            label: const Text('Gerer les medias'),
          ),
          const SizedBox(height: 24),
          Text('Medias', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final media in property.media)
                _MediaTile(
                  label: media.label,
                  kind: media.kind,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.label, required this.kind});

  final String label;
  final MediaKind kind;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (kind) {
      case MediaKind.image:
        icon = Icons.image_outlined;
        break;
      case MediaKind.video:
        icon = Icons.videocam_outlined;
        break;
      case MediaKind.file:
        icon = Icons.insert_drive_file_outlined;
        break;
    }
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
