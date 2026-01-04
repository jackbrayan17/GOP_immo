import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/section_header.dart';
import 'conversation_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final conversations = MockData.conversations;
    final suggestions = MockData.suggestions;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  label: Text(MockData.userById(preview.contactId).name),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        contact: MockData.userById(preview.contactId),
                      ),
                    ),
                  ),
                ),
            ],
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
                      title: Text(MockData.userById(preview.contactId).name),
                      subtitle: Text(preview.lastMessage),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(
                            contact: MockData.userById(preview.contactId),
                          ),
                        ),
                      ),
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
