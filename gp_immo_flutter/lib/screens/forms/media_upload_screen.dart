import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/app_models.dart';
import '../../widgets/page_scaffold.dart';

class MediaUploadScreen extends StatelessWidget {
  const MediaUploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final property = MockData.properties.first;
    return PageScaffold(
      title: 'Medias du bien',
      body: ListView(
        children: [
          Text(
            property.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('${property.media.length}/10 fichiers utilises'),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Uploader des fichiers'),
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
