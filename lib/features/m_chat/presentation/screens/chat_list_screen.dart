import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/l10n/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
import '../../../../shared/models/chat_model.dart';
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
          userId: user.uid,
          chatDetailBasePath: chatDetailBasePath,
        );
      },
    );
  }
}

class _ChatListContent extends ConsumerWidget {
  final String userId;
  final String chatDetailBasePath;

  const _ChatListContent({
    required this.userId,
    required this.chatDetailBasePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatRoomsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.messagesTitle)),
      body: chatsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (rooms) {
          if (rooms.isEmpty) {
            return AppEmpty(
              message: context.l10n.noMessagesYet,
              subMessage: context.l10n.startMessaging,
              icon: Icons.chat_bubble_outline,
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final room = rooms[i];
              return _ChatRoomTile(
                room: room,
                userId: userId,
                chatDetailBasePath: chatDetailBasePath,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;
  final String userId;
  final String chatDetailBasePath;

  const _ChatRoomTile({
    required this.room,
    required this.userId,
    required this.chatDetailBasePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
    // Show deleted placeholder if needed
    if (subtitle != null && subtitle.isEmpty) {
      subtitle = '🚫 Bu mesaj silindi';
    }

    return ListTile(
      onTap: () => context.push('$chatDetailBasePath/${room.id}'),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
