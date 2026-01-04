import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_models.dart';
import '../state/app_state.dart';
import '../utils/formatting.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_banner.dart';
import '../widgets/page_scaffold.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    required this.contact,
    this.currentUserOverride,
  });

  final AppUser contact;
  final AppUser? currentUserOverride;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late final TextEditingController _controller;
  MessageKind _kind = MessageKind.text;
  bool _withAttachment = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(AppState state, AppUser currentUser) async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ecrivez un message avant d\'envoyer.')),
      );
      return;
    }
    final message = Message(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUser.id,
      receiverId: widget.contact.id,
      content: content,
      kind: _kind,
      createdAt: DateTime.now(),
      hasAttachment: _withAttachment,
    );
    await state.sendMessage(message);
    _controller.clear();
    setState(() {
      _kind = MessageKind.text;
      _withAttachment = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentUser = widget.currentUserOverride ?? state.currentUser;
    final messages = state.messagesForContact(
      widget.contact.id,
      currentUserId: currentUser.id,
    );

    return PageScaffold(
      title: widget.contact.name,
      body: Column(
        children: [
          if (state.hasError)
            ErrorBanner(
              message: state.errorMessage ?? 'Erreur inconnue.',
              onClose: () => context.read<AppState>().clearError(),
            ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: EmptyStateCard(
                      title: 'Aucun message',
                      message: 'Ecrivez le premier message pour demarrer.',
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == state.currentUser.id;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: MessageBubble(
                          message: message,
                          isMe: isMe,
                        ),
                      );
                    },
                  ),
          ),
          _Composer(
            controller: _controller,
            kind: _kind,
            withAttachment: _withAttachment,
            onKindChanged: (kind) => setState(() => _kind = kind),
            onAttachmentChanged: (value) => setState(() => _withAttachment = value),
            onSend: () => _send(state, currentUser),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.isMe});

  final Message message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final background = isMe
        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
        : Colors.white.withOpacity(0.9);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateTime(message.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Text(message.content),
          if (message.hasAttachment) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_file, size: 16),
                const SizedBox(width: 6),
                Text(
                  message.kind == MessageKind.quote ? 'Devis.pdf' : 'Rapport.pdf',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.kind,
    required this.withAttachment,
    required this.onKindChanged,
    required this.onAttachmentChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final MessageKind kind;
  final bool withAttachment;
  final ValueChanged<MessageKind> onKindChanged;
  final ValueChanged<bool> onAttachmentChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            PopupMenuButton<MessageKind>(
              icon: const Icon(Icons.attach_file),
              onSelected: onKindChanged,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: MessageKind.text,
                  child: Text('Message'),
                ),
                PopupMenuItem(
                  value: MessageKind.quote,
                  child: Text('Devis'),
                ),
                PopupMenuItem(
                  value: MessageKind.proof,
                  child: Text('Preuve'),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ecrire un message...',
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('PJ'),
              selected: withAttachment,
              onSelected: onAttachmentChanged,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
