import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  String _propertyId = MockData.properties.first.id;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Rapport d\'intervention',
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
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Resume de l\'intervention'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Ajouter une piece jointe'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Envoyer'),
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
