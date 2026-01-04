import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../utils/formatting.dart';
import 'status_pill.dart';

class PropertyMarketCard extends StatelessWidget {
  const PropertyMarketCard({
    super.key,
    required this.property,
    required this.owner,
    required this.onPrimaryAction,
    required this.onContactOwner,
    required this.onContactProvider,
  });

  final Property property;
  final AppUser owner;
  final VoidCallback onPrimaryAction;
  final VoidCallback onContactOwner;
  final VoidCallback onContactProvider;

  @override
  Widget build(BuildContext context) {
    final isForSale = property.listingStatus.toLowerCase().contains('vente');
    final actionLabel = isForSale ? 'Acheter' : 'Louer';

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 340),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(property.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(property.propertyType, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              Text(property.address, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatCurrency(property.price),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Proprietaire: ${owner.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: onPrimaryAction,
                    child: Text(actionLabel),
                  ),
                  OutlinedButton(
                    onPressed: onContactOwner,
                    child: const Text('Contacter proprietaire'),
                  ),
                  TextButton(
                    onPressed: onContactProvider,
                    child: const Text('Contacter prestataire'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
