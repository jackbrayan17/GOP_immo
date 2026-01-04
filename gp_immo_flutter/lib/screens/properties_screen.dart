import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatting.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/page_scaffold.dart';
import 'forms/property_form_screen.dart';
import 'property_detail_screen.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final properties = state.properties;

    return PageScaffold(
      title: 'Mes biens',
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PropertyFormScreen()),
          ),
          child: const Text('Nouveau bien'),
        ),
      ],
      body: Column(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
              onRetry: () => context.read<AppState>().reload(),
            ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 760) {
                  return _PropertyTable(properties: properties);
                }
                if (properties.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: EmptyStateCard(
                      title: 'Aucun bien',
                      message: 'Cliquez sur "Nouveau bien" pour commencer.',
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: properties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final property = properties[index];
                    return Card(
                      child: ListTile(
                        leading: Hero(
                          tag: 'property_${property.id}',
                          child: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            child: Text(_initial(property.title)),
                          ),
                        ),
                        title: Text(property.title),
                        subtitle: Text('${property.propertyType} - ${property.address}'),
                        trailing: Text(formatCurrency(property.price)),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PropertyDetailScreen(propertyId: property.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String _initial(String value) {
  if (value.isEmpty) return '?';
  return value.substring(0, 1).toUpperCase();
}

class _PropertyTable extends StatelessWidget {
  const _PropertyTable({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: EmptyStateCard(
          title: 'Aucun bien',
          message: 'Ajoutez vos biens pour demarrer.',
        ),
      );
    }
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Bien')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Statut')),
          DataColumn(label: Text('Adresse')),
          DataColumn(label: Text('Actions')),
        ],
        rows: [
          for (final property in properties)
            DataRow(
              cells: [
                DataCell(Text(property.title)),
                DataCell(Text(property.propertyType)),
                DataCell(Text(property.listingStatus)),
                DataCell(Text(property.address)),
                DataCell(
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(propertyId: property.id),
                      ),
                    ),
                    child: const Text('Details'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
