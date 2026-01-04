import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class AssignProviderScreen extends StatefulWidget {
  const AssignProviderScreen({super.key});

  @override
  State<AssignProviderScreen> createState() => _AssignProviderScreenState();
}

class _AssignProviderScreenState extends State<AssignProviderScreen> {
  String? _propertyId;
  String? _providerId;
  bool _saving = false;

  Future<void> _save(AppState state) async {
    if (_propertyId == null || _providerId == null) return;
    setState(() => _saving = true);
    final mission = Mission(
      id: 'mission_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: _propertyId!,
      ownerId: state.owner.id,
      status: 'Mission assignee',
    );
    await state.addMission(mission);
    setState(() => _saving = false);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prestataire associe.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final properties = state.properties;
    final providers = state.allProviders;
    _propertyId ??= properties.isNotEmpty ? properties.first.id : null;
    _providerId ??= providers.isNotEmpty ? providers.first.id : null;

    return PageScaffold(
      title: 'Associer un prestataire',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          if (properties.isEmpty || providers.isEmpty)
            const EmptyStateCard(
              title: 'Donnees manquantes',
              message: 'Ajoutez un bien et un prestataire visible.',
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _propertyId,
                      decoration: const InputDecoration(labelText: 'Bien'),
                      items: [
                        for (final property in properties)
                          DropdownMenuItem(
                            value: property.id,
                            child: Text(property.title),
                          ),
                      ],
                      onChanged: (value) => setState(() => _propertyId = value),
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
                      onChanged: (value) => setState(() => _providerId = value),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saving ? null : () => _save(state),
                        child: Text(_saving ? 'Association...' : 'Associer'),
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
