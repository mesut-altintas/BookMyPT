import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/app_loading.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      await FirebaseAuth.instance.currentUser?.getIdToken();
      final storageRef = FirebaseStorage.instance
          .ref('profile_photos/${user.uid}/profile.jpg');
      await storageRef.putFile(
        File(picked.path),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await storageRef.getDownloadURL();
      await ref.read(authRepositoryProvider).updatePhotoUrl(
            uid: user.uid,
            ptId: user.ptId,
            url: url,
          );
      ref.invalidate(currentUserProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellendi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenemedi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _editName(String currentName) async {
    String? result;
    await showDialog<void>(
      context: context,
      builder: (_) => _EditNameDialog(
        initialName: currentName,
        onSave: (name) => result = name,
      ),
    );

    if (!mounted || result == null || result!.isEmpty || result == currentName) return;
    final newName = result!;

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'name': newName});
      await FirebaseAuth.instance.currentUser?.updateDisplayName(newName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncellenemedi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Best-effort: sync to PT's member subcollection
    if (user.ptId != null && user.ptId!.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.ptsCollection)
            .doc(user.ptId)
            .collection(AppConstants.membersSubCollection)
            .doc(user.uid)
            .update({'name': newName});
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İsim güncellendi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showNotificationSettings() async {
    // Mevcut izin durumunu al
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 20),
                Text(
                  'Bildirim Ayarları',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isGranted
                        ? Colors.green.withValues(alpha: 0.08)
                        : theme.colorScheme.errorContainer
                            .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isGranted
                          ? Colors.green.withValues(alpha: 0.3)
                          : theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isGranted
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_off_outlined,
                        color: isGranted
                            ? Colors.green
                            : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGranted ? 'Bildirimler Açık' : 'Bildirimler Kapalı',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isGranted
                                    ? Colors.green
                                    : theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isGranted
                                  ? 'Randevu ve seans bildirimleri alıyorsunuz'
                                  : 'Randevu ve seans bildirimleri için izin gerekli',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Sistem Ayarlarını Aç'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      openAppSettings();
                    },
                  ),
                ),
                if (!isGranted) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.notifications_outlined),
                      label: const Text('İzin İste'),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await FirebaseMessaging.instance.requestPermission();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabınızdan çıkmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: userAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text('Hata: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _isUploadingPhoto
                        ? Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            child: const AppLoading(size: 32),
                          )
                        : UserAvatar(
                            photoUrl: user.photoUrl,
                            name: user.name,
                            radius: 50,
                          ),
                    InkWell(
                      onTap: _pickAndUploadPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'İsim yok',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: user.name.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _editName(user.name),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.edit_outlined,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isPt ? 'Personal Trainer' : 'Üye',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Bildirimler'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showNotificationSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Dil'),
                  trailing: const Text('Türkçe'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Görünüm'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    'Çıkış Yap',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: _signOut,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final void Function(String) onSave;

  const _EditNameDialog({required this.initialName, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('İsim Düzenle'),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Ad Soyad',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (v) {
          widget.onSave(v.trim());
          Navigator.of(context).pop();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_ctrl.text.trim());
            Navigator.of(context).pop();
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
