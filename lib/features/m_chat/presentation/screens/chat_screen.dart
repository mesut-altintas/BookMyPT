import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/user_avatar.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSending = true);
    _msgCtrl.clear();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            chatId: widget.chatId,
            senderId: user.uid,
            text: text,
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        _msgCtrl.text = text;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.sendFailed('$e')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showDeleteOptions(
      BuildContext ctx, ChatMessage message, bool isMe) {
    final l10n = ctx.l10n;
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n.deleteForMe,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final user = ref.read(currentUserProvider).valueOrNull;
                if (user == null) return;
                await ref
                    .read(chatRepositoryProvider)
                    .deleteMessageForMe(widget.chatId, message.id, user.uid);
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(
                  l10n.deleteForEveryone,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(chatRepositoryProvider)
                      .deleteMessageForEveryone(widget.chatId, message.id);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());

        ref
            .read(chatRepositoryProvider)
            .markMessagesAsRead(widget.chatId, user.uid)
            .catchError((_) {});

        final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
        final rooms = ref.watch(chatRoomsProvider(user.uid)).valueOrNull;
        final room = rooms?.where((r) => r.id == widget.chatId).firstOrNull;
        final isGroup = room?.isGroup ?? false;

        return Scaffold(
          appBar: AppBar(
            title: _ChatAppBarTitle(
                chatId: widget.chatId, userId: user.uid, room: room),
          ),
          body: Column(
            children: [
              Expanded(
                child: messagesAsync.when(
                  loading: () => const AppLoading(),
                  error: (e, _) => Center(child: Text(e.toString())),
                  data: (allMessages) {
                    // Filter out messages deleted for current user
                    final messages = allMessages
                        .where((m) => !m.deletedFor.contains(user.uid))
                        .toList();

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          context.l10n.chatEmptyMessage,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (_, i) {
                        final msg = messages[i];
                        final isMe = msg.senderId == user.uid;
                        final showDate = i == 0 ||
                            !isSameDay(messages[i].createdAt,
                                messages[i - 1].createdAt);

                        // For group chats show sender name above bubble
                        final showSenderName = isGroup && !isMe &&
                            (i == 0 ||
                                messages[i].senderId !=
                                    messages[i - 1].senderId);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: Text(
                                    msg.createdAt.formattedDate,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ),
                            if (showSenderName)
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12, bottom: 2, top: 4),
                                child: Text(
                                  _senderName(room, msg.senderId),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            GestureDetector(
                              onLongPress: msg.deletedForEveryone
                                  ? null
                                  : () => _showDeleteOptions(
                                      context, msg, isMe),
                              child: _MessageBubble(
                                  message: msg, isMe: isMe),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              _ChatInputBar(
                controller: _msgCtrl,
                onSend: _send,
                isSending: _isSending,
              ),
            ],
          ),
        );
      },
    );
  }

  String _senderName(ChatRoom? room, String senderId) {
    if (room == null) return senderId.substring(0, 6);
    if (senderId == room.ptId) return room.ptName.isNotEmpty ? room.ptName : 'PT';
    return room.memberName.isNotEmpty ? room.memberName : senderId.substring(0, 6);
  }

  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── AppBar title ─────────────────────────────────────────────────────────────

class _ChatAppBarTitle extends StatelessWidget {
  final String chatId;
  final String userId;
  final ChatRoom? room;

  const _ChatAppBarTitle(
      {required this.chatId, required this.userId, this.room});

  @override
  Widget build(BuildContext context) {
    if (room == null) return Text(context.l10n.messaging);

    if (room!.isGroup) {
      return Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
            child: Icon(Icons.group,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room!.groupName ?? 'Grup',
                  style: const TextStyle(fontSize: 14)),
              Text(
                '${room!.participants.length} katılımcı',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      );
    }

    final otherName = room!.getOtherName(userId);
    final otherPhoto = room!.getOtherPhoto(userId);

    return Row(
      children: [
        UserAvatar(photoUrl: otherPhoto, name: otherName, radius: 18),
        const SizedBox(width: 10),
        Text(otherName),
      ],
    );
  }
}

// ─── Message bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (message.deletedForEveryone) {
      return _DeletedBubble(isMe: isMe);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isMe
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.createdAt.formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.read ? Icons.done_all : Icons.done,
                          size: 12,
                          color:
                              theme.colorScheme.onPrimary.withOpacity(0.7),
                        ),
                      ],
                    ],
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

class _DeletedBubble extends StatelessWidget {
  final bool isMe;
  const _DeletedBubble({required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  context.l10n.messageDeleted,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: context.l10n.typeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: isSending ? null : onSend,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
