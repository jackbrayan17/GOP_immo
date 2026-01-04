import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../widgets/page_scaffold.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  String _propertyId = MockData.properties.first.id;
  String _type = 'Loyer';
  String _status = 'En attente';

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Enregistrer un paiement',
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
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type de paiement'),
                    items: const [
                      DropdownMenuItem(value: 'Loyer', child: Text('Loyer')),
                      DropdownMenuItem(value: 'Reservation', child: Text('Reservation')),
                      DropdownMenuItem(value: 'Prestataire', child: Text('Prestataire')),
                    ],
                    onChanged: (value) => setState(() => _type = value ?? _type),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Montant'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date d'echeance'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Statut'),
                    items: const [
                      DropdownMenuItem(value: 'En attente', child: Text('En attente')),
                      DropdownMenuItem(value: 'Paye', child: Text('Paye')),
                      DropdownMenuItem(value: 'Retard', child: Text('Retard')),
                    ],
                    onChanged: (value) => setState(() => _status = value ?? _status),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Valider'),
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
