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
import '../../../../core/l10n/extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/services/theme_service.dart';
import '../../../../shared/services/locale_service.dart';
import 'help_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingPhoto = false;

  String _themeModeLabel(BuildContext context, ThemeMode mode) {
    final l10n = context.l10n;
    return switch (mode) {
      ThemeMode.light  => l10n.themeLabelLight,
      ThemeMode.dark   => l10n.themeLabelDark,
      ThemeMode.system => l10n.themeLabelSystem,
    };
  }

  Future<void> _pickAndUploadPhoto() async {
    final l10n = context.l10n;
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
          SnackBar(
            content: Text(l10n.photoUpdated),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.photoFailed}: $e'),
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
            content: Text('${context.l10n.updateFailed}: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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
        SnackBar(
          content: Text(context.l10n.nameUpdated),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showNotificationSettings() async {
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
        final l10n = ctx.l10n;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _sheetHandle(theme)),
                const SizedBox(height: 20),
                Text(l10n.notifSettings,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isGranted
                        ? Colors.green.withValues(alpha: 0.08)
                        : theme.colorScheme.errorContainer.withValues(alpha: 0.4),
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
                        color: isGranted ? Colors.green : theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGranted ? l10n.notifOn : l10n.notifOff,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isGranted ? Colors.green : theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isGranted ? l10n.notifOnSub : l10n.notifOffSub,
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
                    label: Text(l10n.openSystemSettings),
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
                      label: Text(l10n.requestPermission),
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

  void _showThemeSettings() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, r, _) {
          final current = r.watch(themeModeProvider);
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _sheetHandle(theme)),
                  const SizedBox(height: 20),
                  Text(l10n.appearanceTitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _ThemeOption(
                    icon: Icons.brightness_auto_outlined,
                    label: l10n.themeSystem,
                    subtitle: l10n.themeSystemSub,
                    value: ThemeMode.system,
                    groupValue: current,
                    onChanged: (v) =>
                        r.read(themeModeProvider.notifier).setThemeMode(v!),
                  ),
                  _ThemeOption(
                    icon: Icons.light_mode_outlined,
                    label: l10n.themeLight,
                    subtitle: l10n.themeLightSub,
                    value: ThemeMode.light,
                    groupValue: current,
                    onChanged: (v) =>
                        r.read(themeModeProvider.notifier).setThemeMode(v!),
                  ),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    label: l10n.themeDark,
                    subtitle: l10n.themeDarkSub,
                    value: ThemeMode.dark,
                    groupValue: current,
                    onChanged: (v) =>
                        r.read(themeModeProvider.notifier).setThemeMode(v!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLanguageSettings() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, r, _) {
          final current = r.watch(localeProvider);
          final theme = Theme.of(ctx);
          final l10n = ctx.l10n;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: _sheetHandle(theme)),
                  const SizedBox(height: 20),
                  Text(l10n.languageTitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _LocaleOption(
                    flag: '🇹🇷',
                    label: 'Türkçe',
                    value: const Locale('tr', 'TR'),
                    groupValue: current,
                    onChanged: (v) {
                      r.read(localeProvider.notifier).setLocale(v!);
                      Navigator.of(ctx).pop();
                    },
                  ),
                  _LocaleOption(
                    flag: '🇬🇧',
                    label: 'English',
                    value: const Locale('en', 'US'),
                    groupValue: current,
                    onChanged: (v) {
                      r.read(localeProvider.notifier).setLocale(v!);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _signOut() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.go(AppRoutes.login);
  }

  Widget _sheetHandle(ThemeData theme) => Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
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
                      user.name.isNotEmpty ? user.name : l10n.noName,
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
                    user.isPt ? l10n.rolePt : l10n.roleMember,
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
                  title: Text(l10n.notifications),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showNotificationSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  trailing: Consumer(builder: (_, r, __) {
                    final locale = r.watch(localeProvider);
                    return Text(
                      locale.languageCode == 'tr' ? '🇹🇷  Türkçe' : '🇬🇧  English',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }),
                  onTap: _showLanguageSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: Text(l10n.appearance),
                  trailing: Consumer(builder: (_, r, __) {
                    final mode = r.watch(themeModeProvider);
                    return Text(
                      _themeModeLabel(context, mode),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }),
                  onTap: _showThemeSettings,
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: Text(l10n.helpGuide),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HelpScreen(isPt: user.isPt),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text(
                    l10n.signOut,
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

// ── Theme option row ──────────────────────────────────────────────────────────
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final ThemeMode value;
  final ThemeMode groupValue;
  final ValueChanged<ThemeMode?> onChanged;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      )),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Locale option row ─────────────────────────────────────────────────────────
class _LocaleOption extends StatelessWidget {
  final String flag;
  final String label;
  final Locale value;
  final Locale groupValue;
  final ValueChanged<Locale?> onChanged;

  const _LocaleOption({
    required this.flag,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  )),
            ),
            Radio<Locale>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Edit name dialog ──────────────────────────────────────────────────────────
class _EditNameDialog extends StatefulWidget {
  final String initialName;
  final void Function(String) onSave;

  const _EditNameDialog({
    required this.initialName,
    required this.onSave,
  });

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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.editName),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: l10n.fullName,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (v) {
          widget.onSave(v.trim());
          Navigator.of(context).pop();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_ctrl.text.trim());
            Navigator.of(context).pop();
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
