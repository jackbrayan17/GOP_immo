import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class MediaUploadScreen extends StatelessWidget {
  const MediaUploadScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    Property? property;
    if (propertyId != null) {
      for (final item in state.properties) {
        if (item.id == propertyId) {
          property = item;
          break;
        }
      }
    }
    property ??= state.properties.isNotEmpty ? state.properties.first : null;

    return PageScaffold(
      title: 'Medias du bien',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          if (property == null)
            const EmptyStateCard(
              title: 'Aucun bien',
              message: 'Ajoutez un bien pour gerer les medias.',
            )
          else ...[
            Builder(
              builder: (context) {
                final currentProperty = property!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            Text(
              currentProperty.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text('${currentProperty.media.length}/10 fichiers utilises'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _addDemoMedia(context, currentProperty),
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Uploader un media demo'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Formats acceptes: image, video ou document.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Fichiers existants', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final media in currentProperty.media)
                  _MediaTile(
                    label: media.label,
                    kind: media.kind,
                  ),
              ],
            ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

void _addDemoMedia(BuildContext context, Property property) {
  final id = 'media_${DateTime.now().millisecondsSinceEpoch}';
  final media = MediaItem(
    id: id,
    kind: MediaKind.image,
    label: 'Media_$id.jpg',
  );
  context.read<AppState>().addMedia(property.id, media);
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
