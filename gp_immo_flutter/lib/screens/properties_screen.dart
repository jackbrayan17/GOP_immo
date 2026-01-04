import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/app_models.dart';
import '../utils/formatting.dart';
import '../widgets/page_scaffold.dart';
import 'forms/property_form_screen.dart';
import 'property_detail_screen.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = MockData.properties;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 760) {
            return _PropertyTable(properties: properties);
          }
          return ListView.separated(
            itemCount: properties.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final property = properties[index];
              return Card(
                child: ListTile(
                  title: Text(property.title),
                  subtitle: Text('${property.propertyType} - ${property.address}'),
                  trailing: Text(formatCurrency(property.price)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PropertyDetailScreen(property: property),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PropertyTable extends StatelessWidget {
  const _PropertyTable({required this.properties});

  final List<Property> properties;

  @override
  Widget build(BuildContext context) {
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
                        builder: (_) => PropertyDetailScreen(property: property),
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
