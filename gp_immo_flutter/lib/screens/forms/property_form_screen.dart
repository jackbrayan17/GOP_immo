import 'package:flutter/material.dart';

import '../../widgets/page_scaffold.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  bool _furnished = false;
  String _propertyType = 'Appartement en location';
  String _listingStatus = 'Location';

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Nouveau bien',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Titre du bien'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _propertyType,
                    decoration: const InputDecoration(labelText: 'Type de bien'),
                    items: const [
                      DropdownMenuItem(value: 'Appartement en location', child: Text('Appartement en location')),
                      DropdownMenuItem(value: 'Appartement meuble', child: Text('Appartement meuble')),
                      DropdownMenuItem(value: 'Studio en location', child: Text('Studio en location')),
                      DropdownMenuItem(value: 'Studio meuble', child: Text('Studio meuble')),
                      DropdownMenuItem(value: 'Chambre en location', child: Text('Chambre en location')),
                      DropdownMenuItem(value: 'Chambre meublee', child: Text('Chambre meublee')),
                      DropdownMenuItem(value: 'Magasin', child: Text('Magasin')),
                      DropdownMenuItem(value: 'Immeuble', child: Text('Immeuble')),
                      DropdownMenuItem(value: 'Maison', child: Text('Maison')),
                    ],
                    onChanged: (value) => setState(() => _propertyType = value ?? _propertyType),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _listingStatus,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: 'Location', child: Text('Location')),
                      DropdownMenuItem(value: 'Vente', child: Text('Vente')),
                    ],
                    onChanged: (value) => setState(() => _listingStatus = value ?? _listingStatus),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Adresse'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Prix mensuel'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _furnished,
                    onChanged: (value) => setState(() => _furnished = value),
                    title: const Text('Meuble'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description'),
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
