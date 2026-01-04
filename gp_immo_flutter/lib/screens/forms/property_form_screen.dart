import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _furnished = false;
  String _propertyType = 'Appartement en location';
  String _listingStatus = 'Location';
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save(AppState state) async {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prix invalide.')),
      );
      return;
    }
    setState(() => _saving = true);
    final property = Property(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
      ownerId: state.currentUser.id,
      title: _titleController.text.trim(),
      propertyType: _propertyType,
      listingStatus: _listingStatus,
      address: _addressController.text.trim(),
      description: _descriptionController.text.trim(),
      price: price,
      furnished: _furnished,
      media: const [],
    );
    await state.addProperty(property);
    setState(() => _saving = false);
    if (!state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bien ajoute avec succes.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PageScaffold(
      title: 'Nouveau bien',
      body: ListView(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Titre du bien'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Titre requis.' : null,
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
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Adresse requise.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Prix mensuel'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Prix requis.' : null,
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
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'Description'),
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
