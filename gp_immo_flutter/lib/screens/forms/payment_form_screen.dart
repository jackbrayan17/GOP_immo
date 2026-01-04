import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/empty_state_card.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();

  String? _propertyId;
  String _type = 'Loyer';
  String _status = 'En attente';
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _save(AppState state) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant invalide.')),
      );
      return;
    }
    if (_propertyId == null) return;
    setState(() => _saving = true);
    final payment = Payment(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      propertyId: _propertyId!,
      amount: amount,
      paymentType: _type == 'Reservation'
          ? PaymentType.booking
          : _type == 'Prestataire'
              ? PaymentType.provider
              : PaymentType.rent,
      status: _status == 'Paye'
          ? PaymentStatus.paid
          : _status == 'Retard'
              ? PaymentStatus.late
              : PaymentStatus.pending,
      dueDate: DateTime.tryParse(_dateController.text.trim()) ?? DateTime.now(),
    );
    await state.addPayment(payment);
    setState(() => _saving = false);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement enregistre.')),
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
      title: 'Enregistrer un paiement',
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
              message: 'Ajoutez un bien avant de creer un paiement.',
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
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.trim().isEmpty ? 'Montant requis.' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Date d\'echeance (YYYY-MM-DD)'),
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
                          onPressed: _saving ? null : () => _save(state),
                          child: Text(_saving ? 'Enregistrement...' : 'Valider'),
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
