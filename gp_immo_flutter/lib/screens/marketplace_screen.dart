import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../widgets/animated_reveal.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/property_market_card.dart';
import '../widgets/provider_picker.dart';
import '../widgets/section_header.dart';
import 'conversation_screen.dart';

enum MarketplaceSection { properties, providers }

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({
    super.key,
    this.initialSection = MarketplaceSection.providers,
    this.embedded = false,
  });

  final MarketplaceSection initialSection;
  final bool embedded;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final TextEditingController _searchController;
  late MarketplaceSection _section;
  String _selected = 'Tous';
  String _propertyFilter = 'Tous';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _section = widget.initialSection;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isProperties = _section == MarketplaceSection.properties;
    final providerFilters = ['Tous', ...state.specializations];
    const propertyFilters = ['Tous', 'Location', 'Vente'];
    final query = _searchController.text.toLowerCase();
    final properties = state.properties.where((property) {
      final matchesQuery = query.isEmpty ||
          property.title.toLowerCase().contains(query) ||
          property.address.toLowerCase().contains(query) ||
          property.propertyType.toLowerCase().contains(query);
      final matchesFilter = _propertyFilter == 'Tous' || property.listingStatus == _propertyFilter;
      return matchesQuery && matchesFilter;
    }).toList();
    final providers = state.providers.where((provider) {
      final matchesQuery = query.isEmpty ||
          provider.name.toLowerCase().contains(query) ||
          provider.specialization.toLowerCase().contains(query);
      final matchesFilter = _selected == 'Tous' || provider.specialization == _selected;
      return matchesQuery && matchesFilter;
    }).toList();

    final content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
              onRetry: () => context.read<AppState>().reload(),
            ),
          SectionHeader(
            title: isProperties ? 'Biens disponibles' : 'Marketplace prestataires',
            eyebrow: isProperties ? 'Acheter ou louer' : 'Marketplace',
          ),
          const SizedBox(height: 12),
          ToggleButtons(
            isSelected: [
              _section == MarketplaceSection.properties,
              _section == MarketplaceSection.providers,
            ],
            onPressed: (index) => setState(() {
              _section =
                  index == 0 ? MarketplaceSection.properties : MarketplaceSection.providers;
            }),
            borderRadius: BorderRadius.circular(14),
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Biens'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Prestataires'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: isProperties
                  ? 'Quartier, type de bien, adresse...'
                  : 'Plomberie, menuiserie, carrelage...',
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
              for (final filter in isProperties ? propertyFilters : providerFilters)
                ChoiceChip(
                  label: Text(filter),
                  selected: isProperties ? _propertyFilter == filter : _selected == filter,
                  onSelected: (_) => setState(() {
                    if (isProperties) {
                      _propertyFilter = filter;
                    } else {
                      _selected = filter;
                    }
                  }),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              if (isProperties)
                for (var i = 0; i < properties.length; i++)
                  AnimatedReveal(
                    delay: Duration(milliseconds: 80 * i),
                    child: PropertyMarketCard(
                      property: properties[i],
                      owner: state.userById(properties[i].ownerId),
                      onPrimaryAction: () => _handlePropertyAction(context, properties[i]),
                      onContactOwner: () => _contactOwner(context, state, properties[i]),
                      onContactProvider: () => _contactProvider(context, state),
                    ),
                  )
              else
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
          if (isProperties && properties.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyStateCard(
                title: 'Aucun bien disponible',
                message: 'Revenez plus tard ou changez vos filtres.',
              ),
            ),
          if (!isProperties && providers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyStateCard(
                title: 'Aucun prestataire',
                message: 'Ajustez vos filtres ou revenez plus tard.',
              ),
            ),
        ],
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return PageScaffold(
      title: isProperties ? 'Biens disponibles' : 'Marketplace',
      body: content,
    );
  }

  void _handlePropertyAction(BuildContext context, Property property) {
    final isForSale = property.listingStatus.toLowerCase().contains('vente');
    final prefix = isForSale ? 'd\'achat' : 'de location';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demande $prefix envoyee pour ${property.title}.'),
      ),
    );
  }

  void _contactOwner(BuildContext context, AppState state, Property property) {
    final owner = state.userById(property.ownerId);
    final client =
        state.currentUser.role == UserRole.client ? state.currentUser : state.client;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          contact: owner,
          currentUserOverride: client,
        ),
      ),
    );
  }

  Future<void> _contactProvider(BuildContext context, AppState state) async {
    final client =
        state.currentUser.role == UserRole.client ? state.currentUser : state.client;
    final provider = await showProviderPicker(context, state.providers);
    if (!mounted || provider == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConversationScreen(
          contact: provider,
          currentUserOverride: client,
        ),
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
