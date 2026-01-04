import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/section_header.dart';
import 'conversation_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final conversations = state.conversations;
    final suggestions = state.suggestions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
              onRetry: () => context.read<AppState>().reload(),
            ),
          const SectionHeader(title: 'Messagerie'),
          const SizedBox(height: 12),
          Text('Contacts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final preview in conversations)
                ActionChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(state.userById(preview.contactId).name),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        contact: state.userById(preview.contactId),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (conversations.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: EmptyStateCard(
                title: 'Aucune conversation',
                message: 'Commencez par contacter un prestataire.',
              ),
            ),
          const SizedBox(height: 24),
          if (suggestions.isNotEmpty) ...[
            Text('Suggestions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final contact in suggestions)
                  ActionChip(
                    label: Text(contact.name),
                    avatar: const Icon(Icons.star_border, size: 18),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConversationScreen(contact: contact),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          const SectionHeader(title: 'Derniers messages'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final preview in conversations)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(state.userById(preview.contactId).name),
                      subtitle: Text(preview.lastMessage),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(
                            contact: state.userById(preview.contactId),
                          ),
                        ),
                      ),
                    ),
                  if (conversations.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Aucun message recent.'),
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
