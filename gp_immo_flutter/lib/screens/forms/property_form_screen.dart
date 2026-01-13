import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_models.dart';
// ... previous imports ...
import '../../state/app_state.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/page_scaffold.dart';

class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _furnished = false;
  String _propertyType = 'Appartement en location';
  String _listingStatus = 'Location';
  bool _saving = false;
  
  // New state for media
  final List<MediaItem> _media = [];

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
      media: _media, // Save with media
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

  Future<void> _pickMedia(MediaKind kind) async {
    if (_media.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 10 medias atteinte.')),
      );
      return;
    }

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (file == null) return;

      final id = 'media_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _media.add(MediaItem(
          id: id,
          kind: MediaKind.image, // For now focusing on images as video picker is separate method usually
          label: file.name,
          path: file.path,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    if (_media.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Limite de 10 medias atteinte.')),
      );
      return;
    }

    try {
      final XFile? file = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      
      if (file == null) return;

      final id = 'media_${DateTime.now().millisecondsSinceEpoch}';
      setState(() {
        _media.add(MediaItem(
          id: id,
          kind: MediaKind.video,
          label: file.name,
          path: file.path,
        ));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _removeMedia(String id) {
    setState(() {
      _media.removeWhere((item) => item.id == id);
    });
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 20),
                    Text('Photos et Vidéos', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    if (_media.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Aucun média ajouté.', style: Theme.of(context).textTheme.bodySmall),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final item in _media)
                          Chip(
                            avatar: Icon(
                              item.kind == MediaKind.video ? Icons.videocam : Icons.image,
                              size: 16,
                            ),
                            label: Text(item.label),
                            onDeleted: () => _removeMedia(item.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickMedia(MediaKind.image),
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Ajouter Photo'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickVideo(),
                            icon: const Icon(Icons.video_call),
                            label: const Text('Ajouter Vidéo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
