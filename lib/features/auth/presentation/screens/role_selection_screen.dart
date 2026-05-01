import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  final String uid;
  final String name;

  const RoleSelectionScreen({super.key, required this.uid, required this.name});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _confirm() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    await ref.read(authNotifierProvider.notifier).createProfile(
          uid: user.uid,
          name: widget.name.isNotEmpty ? widget.name : (user.displayName ?? ''),
          email: user.email ?? '',
          role: _selectedRole!,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_selectedRole == AppConstants.roleTrainer) {
      context.go(AppRoutes.ptDashboard);
    } else {
      context.go(AppRoutes.memberDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Text(
                'Rolünüzü Seçin',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Uygulamayı nasıl kullanacaksınız?',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 48),
              _RoleCard(
                title: 'Personal Trainer',
                subtitle:
                    'Üyelerinizi yönetin, program oluşturun ve takvim tutun',
                icon: Icons.sports,
                color: AppColors.ptPrimary,
                isSelected: _selectedRole == AppConstants.roleTrainer,
                onTap: () =>
                    setState(() => _selectedRole = AppConstants.roleTrainer),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                title: 'Üye',
                subtitle:
                    'PT\'nizin programını görün, randevu alın ve ilerlemenizi takip edin',
                icon: Icons.person,
                color: AppColors.memberPrimary,
                isSelected: _selectedRole == AppConstants.roleMember,
                onTap: () =>
                    setState(() => _selectedRole = AppConstants.roleMember),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed:
                    (_selectedRole == null || _isLoading) ? null : _confirm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Devam Et'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2.5 : 1,
          ),
          color: isSelected ? color.withOpacity(0.08) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : null,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
