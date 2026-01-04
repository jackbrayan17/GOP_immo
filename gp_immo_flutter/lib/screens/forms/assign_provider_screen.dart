import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class AssignProviderScreen extends StatefulWidget {
  const AssignProviderScreen({super.key});

  @override
  State<AssignProviderScreen> createState() => _AssignProviderScreenState();
}

class _AssignProviderScreenState extends State<AssignProviderScreen> {
  String _propertyId = MockData.properties.first.id;
  String _providerId = MockData.providerLead.id;

  @override
  Widget build(BuildContext context) {
    final providers = MockData.providers();
    return PageScaffold(
      title: 'Associer un prestataire',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _propertyId,
                    decoration: const InputDecoration(labelText: 'Bien'),
                    items: [
                      for (final property in MockData.properties)
                        DropdownMenuItem(
                          value: property.id,
                          child: Text(property.title),
                        ),
                    ],
                    onChanged: (value) => setState(() => _propertyId = value ?? _propertyId),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _providerId,
                    decoration: const InputDecoration(labelText: 'Prestataire'),
                    items: [
                      for (final provider in providers)
                        DropdownMenuItem(
                          value: provider.id,
                          child: Text('${provider.name} - ${provider.specialization}'),
                        ),
                    ],
                    onChanged: (value) => setState(() => _providerId = value ?? _providerId),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Associer'),
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
