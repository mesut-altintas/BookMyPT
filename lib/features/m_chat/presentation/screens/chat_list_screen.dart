import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_chat/providers/chat_provider.dart';
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
      appBar: AppBar(title: const Text('Mesajlar')),
      body: chatsAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (rooms) {
          if (rooms.isEmpty) {
            return const AppEmpty(
              message: 'Henüz mesajınız yok',
              subMessage: 'PT\'niz veya üyeniz ile mesajlaşmaya başlayın',
              icon: Icons.chat_bubble_outline,
            );
          }

          return ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final room = rooms[i];
              final otherName = room.getOtherName(userId);
              final otherPhoto = room.getOtherPhoto(userId);

              return ListTile(
                onTap: () => context.push('$chatDetailBasePath/${room.id}'),
                leading: UserAvatar(
                  photoUrl: otherPhoto,
                  name: otherName,
                  radius: 26,
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: room.lastMessage != null
                    ? Text(
                        room.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: room.lastMessageAt != null
                    ? Text(
                        timeago.format(room.lastMessageAt!, locale: 'tr'),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
