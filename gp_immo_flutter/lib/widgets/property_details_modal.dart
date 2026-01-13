import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/app_models.dart';

class PropertyDetailsModal extends StatelessWidget {
  const PropertyDetailsModal({
    super.key,
    required this.property,
    required this.owner,
    required this.onContactOwner,
  });

  final Property property;
  final AppUser owner;
  final VoidCallback onContactOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Image Gallery
          SizedBox(
            height: 250,
            child: property.media.isEmpty
                ? Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.home, size: 80, color: Colors.grey[400]),
                    ),
                  )
                : PageView.builder(
                    itemCount: property.media.length,
                    itemBuilder: (context, index) {
                      final item = property.media[index];
                      ImageProvider? imageProvider;
                      if (item.path != null && item.path!.isNotEmpty) {
                        imageProvider = FileImage(File(item.path!));
                      } else {
                        imageProvider = const AssetImage("gop-logo.png");
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                             image: imageProvider, 
                             fit: BoxFit.cover,
                             opacity: item.path != null ? 1.0 : 0.1,
                          ),
                        ),
                        child: Center(
                          child: (item.path != null && item.kind == MediaKind.image)
                             ? null 
                             : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      item.kind == MediaKind.video
                                          ? Icons.play_circle_fill
                                          : Icons.image,
                                      size: 64,
                                      color: Colors.black54,
                                    ),
                                    if (item.path == null) ...[
                                      const SizedBox(height: 8),
                                      Text(item.label),
                                    ],
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Text(
                        '${property.price} FCFA',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(property.listingStatus),
                        backgroundColor: Colors.blue[50],
                        labelStyle: TextStyle(color: Colors.blue[800]),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(property.propertyType),
                        backgroundColor: Colors.orange[50],
                        labelStyle: TextStyle(color: Colors.orange[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description.isEmpty
                        ? 'Aucune description disponible.'
                        : property.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (property.furnished) ...[
                    Row(
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Ce bien est meublé'),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Propriétaire',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(owner.name[0].toUpperCase()),
                    ),
                    title: Text(owner.name),
                    subtitle: Text(owner.email),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: onContactOwner,
                      icon: const Icon(Icons.chat),
                      label: const Text('Contacter le propriétaire'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
