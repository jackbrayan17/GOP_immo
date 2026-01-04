import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  String? _propertyId;
  bool _saving = false;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _save(AppState state) async {
    if (!_formKey.currentState!.validate()) return;
    if (_propertyId == null) return;
    setState(() => _saving = true);
    final report = Report(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: _propertyId!,
      summary: _summaryController.text.trim(),
      createdAt: DateTime.now(),
    );
    await state.addReport(report);
    setState(() => _saving = false);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rapport envoye.')),
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
      title: 'Rapport d\'intervention',
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
              message: 'Ajoutez un bien avant d\'envoyer un rapport.',
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
                        controller: _summaryController,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Resume de l\'intervention'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Resume requis.' : null,
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
                          onPressed: _saving ? null : () => _save(state),
                          child: Text(_saving ? 'Envoi...' : 'Envoyer'),
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
