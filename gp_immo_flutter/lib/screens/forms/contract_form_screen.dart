import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class ContractFormScreen extends StatefulWidget {
  const ContractFormScreen({super.key});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  String _status = 'Brouillon';
  String _propertyId = MockData.properties.first.id;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Nouveau contrat',
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
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom du locataire'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date de debut'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date de fin'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Loyer'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: 'Brouillon', child: Text('Brouillon')),
                      DropdownMenuItem(value: 'Actif', child: Text('Actif')),
                      DropdownMenuItem(value: 'Termine', child: Text('Termine')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? _status),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Enregistrer'),
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
