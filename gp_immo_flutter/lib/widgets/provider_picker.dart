import 'package:flutter/material.dart';

import '../models/app_models.dart';

Future<AppUser?> showProviderPicker(BuildContext context, List<AppUser> providers) async {
  if (providers.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aucun prestataire disponible.')),
    );
    return null;
  }

  return showModalBottomSheet<AppUser>(
    context: context,
    useSafeArea: true,
    builder: (context) {
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: providers.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final provider = providers[index];
          return ListTile(
            leading: const Icon(Icons.handyman_outlined),
            title: Text(provider.name),
            subtitle: Text(provider.specialization),
            trailing: Text(provider.rating.toStringAsFixed(1)),
            onTap: () => Navigator.of(context).pop(provider),
          );
        },
      );
    },
  );
}
