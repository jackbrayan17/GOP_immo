import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/section_header.dart';
import 'conversation_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final TextEditingController _searchController;
  String _selected = 'Tous';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['Tous', ...MockData.specializations];
    final query = _searchController.text.toLowerCase();
    final providers = MockData.providers().where((provider) {
      final matchesQuery = query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.specialization.toLowerCase().contains(query);
      final matchesFilter = _selected == 'Tous' || provider.specialization == _selected;
      return matchesQuery && matchesFilter;
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Marketplace prestataires',
            eyebrow: 'Marketplace',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Plomberie, menuiserie, carrelage...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final filter in filters)
                ChoiceChip(
                  label: Text(filter),
                  selected: _selected == filter,
                  onSelected: (_) => setState(() => _selected = filter),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (var i = 0; i < providers.length; i++)
                AnimatedReveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: _ProviderCard(
                    provider: providers[i],
                    onContact: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(contact: providers[i]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (providers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Aucun prestataire trouve.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, required this.onContact});

  final AppUser provider;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(provider.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(provider.specialization, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(provider.rating.toStringAsFixed(1)),
                  const Spacer(),
                  Text('Tel: ${provider.phone}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onContact,
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Contacter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
