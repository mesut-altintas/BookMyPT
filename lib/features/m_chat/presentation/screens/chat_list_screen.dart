import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/l10n/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../../../../shared/models/chat_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../../shared/widgets/user_avatar.dart';

class ChatListScreen extends ConsumerWidget {
  final String chatDetailBasePath;

  const ChatListScreen({
    super.key,
    this.chatDetailBasePath = '/member/chat',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _ChatListContent(
          user: user,
          chatDetailBasePath: chatDetailBasePath,
        );
      },
    );
  }
}

class _ChatListContent extends ConsumerStatefulWidget {
  final UserModel user;
  final String chatDetailBasePath;

  const _ChatListContent({
    required this.user,
    required this.chatDetailBasePath,
  });

  @override
  ConsumerState<_ChatListContent> createState() => _ChatListContentState();
}

class _ChatListContentState extends ConsumerState<_ChatListContent> {
  bool _startingChat = false;

  bool get _isMemberWithPt =>
      widget.user.role == 'member' &&
      (widget.user.ptId?.isNotEmpty ?? false);

  Future<void> _startPtChat() async {
    if (_startingChat) return;
    setState(() => _startingChat = true);
    try {
      final ptId = widget.user.ptId!;
      // Fetch PT info from Firestore
      final ptDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ptId)
          .get();
      final ptData = ptDoc.data() ?? {};
      final ptName = ptData['name'] as String? ?? 'PT';
      final ptPhoto = ptData['photoUrl'] as String?;

      final chatId =
          await ref.read(chatRepositoryProvider).createOrGetChatRoom(
                ptId: ptId,
                memberId: widget.user.uid,
                ptName: ptName,
                memberName: widget.user.name,
                ptPhotoUrl: ptPhoto,
                memberPhotoUrl: widget.user.photoUrl,
              );

      if (mounted) {
        context.push('${widget.chatDetailBasePath}/$chatId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _startingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatRoomsProvider(widget.user.uid));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.messagesTitle)),
      floatingActionButton: _isMemberWithPt
          ? FloatingActionButton.extended(
              onPressed: _startingChat ? null : _startPtChat,
              icon: _startingChat
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.edit_outlined),
              label: Text(context.l10n.messageMyPt),
            )
          : null,
      body: chatsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (rooms) {
          if (rooms.isEmpty) {
            return AppEmpty(
              message: context.l10n.noMessagesYet,
              subMessage: context.l10n.startMessaging,
              icon: Icons.chat_bubble_outline,
              action: _isMemberWithPt
                  ? TextButton.icon(
                      onPressed: _startingChat ? null : _startPtChat,
                      icon: const Icon(Icons.chat_outlined),
                      label: Text(context.l10n.messageMyPt),
                    )
                  : null,
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final room = rooms[i];
              return _ChatRoomTile(
                room: room,
                userId: widget.user.uid,
                chatDetailBasePath: widget.chatDetailBasePath,
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ChatRoomTile extends ConsumerWidget {
  final ChatRoom room;
  final String userId;
  final String chatDetailBasePath;

  const _ChatRoomTile({
    required this.room,
    required this.userId,
    required this.chatDetailBasePath,
  });

  // Can this user delete this chat room?
  bool get _canDelete {
    if (room.isGroup) {
      // Only the PT who owns the group may delete the group chat
      return room.ptId == userId;
    }
    // For 1:1 chats both parties may delete
    return room.ptId == userId || room.memberId == userId;
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    final l10n  = context.l10n;
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(
                l10n.deleteChatTitle,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDelete(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(l10n.cancel),
              onTap: () => Navigator.pop(sheetCtx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteChatTitle),
        content: Text(l10n.deleteChatBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(chatRepositoryProvider).deleteChatRoom(room.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.chatDeleted),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error(e.toString())}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme     = Theme.of(context);
    final otherName = room.getOtherName(userId);
    final otherPhoto = room.getOtherPhoto(userId);

    Widget leading;
    if (room.isGroup) {
      leading = CircleAvatar(
        radius: 26,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(Icons.group,
            color: theme.colorScheme.onPrimaryContainer, size: 26),
      );
    } else {
      leading = UserAvatar(photoUrl: otherPhoto, name: otherName, radius: 26);
    }

    String? subtitle = room.lastMessage;
    if (subtitle != null && subtitle.isEmpty) {
      subtitle = '🚫 Bu mesaj silindi';
    }

    return ListTile(
      onTap: () => context.push('$chatDetailBasePath/${room.id}'),
      onLongPress: _canDelete ? () => _showOptions(context, ref) : null,
      leading: leading,
      title: Row(
        children: [
          Expanded(
            child: Text(
              otherName,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (room.isGroup)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'GRUP',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: subtitle == '🚫 Bu mesaj silindi'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            )
          : null,
      trailing: room.lastMessageAt != null
          ? Text(
              timeago.format(room.lastMessageAt!, locale: 'tr'),
              style: theme.textTheme.bodySmall,
            )
          : null,
    );
  }
}
