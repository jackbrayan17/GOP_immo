import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class ContractFormScreen extends StatefulWidget {
  const ContractFormScreen({super.key});

  @override
  State<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends State<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantController = TextEditingController();
  final _rentController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  String _status = 'Brouillon';
  String? _propertyId;
  bool _saving = false;

  @override
  void dispose() {
    _tenantController.dispose();
    _rentController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _save(AppState state) async {
    if (!_formKey.currentState!.validate()) return;
    final rent = double.tryParse(_rentController.text.trim());
    if (rent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loyer invalide.')),
      );
      return;
    }
    if (_propertyId == null) return;
    setState(() => _saving = true);
    final contract = Contract(
      id: 'contract_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: _propertyId!,
      tenantName: _tenantController.text.trim(),
      status: _status == 'Actif'
          ? ContractStatus.active
          : _status == 'Termine'
              ? ContractStatus.closed
              : ContractStatus.draft,
      rent: rent,
      startDate: DateTime.tryParse(_startController.text.trim()) ?? DateTime.now(),
      endDate: _endController.text.trim().isEmpty ? null : DateTime.tryParse(_endController.text.trim()),
    );
    await state.addContract(contract);
    setState(() => _saving = false);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contrat enregistre.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final properties = state.properties;
    _propertyId ??= properties.isNotEmpty ? properties.first.id : null;

    return PageScaffold(
      title: 'Nouveau contrat',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          if (properties.isEmpty)
            const EmptyStateCard(
              title: 'Aucun bien',
              message: 'Ajoutez un bien avant de creer un contrat.',
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
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
                      TextFormField(
                        controller: _tenantController,
                        decoration: const InputDecoration(labelText: 'Nom du locataire'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Nom requis.' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _startController,
                        decoration: const InputDecoration(labelText: 'Date de debut (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _endController,
                        decoration: const InputDecoration(labelText: 'Date de fin (YYYY-MM-DD)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _rentController,
                        decoration: const InputDecoration(labelText: 'Loyer'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Loyer requis.' : null,
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
                          onPressed: _saving ? null : () => _save(state),
                          child: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
