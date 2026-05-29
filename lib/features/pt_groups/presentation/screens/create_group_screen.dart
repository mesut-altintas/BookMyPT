import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_groups/providers/pt_groups_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/group_model.dart';
import '../../../../shared/models/member_model.dart';
import '../../../../shared/widgets/user_avatar.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  final GroupModel? initialGroup;

  const CreateGroupScreen({super.key, this.initialGroup});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  int _selectedColorValue = 0xFF2196F3;
  final Set<String> _selectedMemberIds = {};

  static const _colors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF607D8B), // Blue Grey
  ];

  bool get isEdit => widget.initialGroup != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final g = widget.initialGroup!;
      _nameCtrl.text = g.name;
      _descCtrl.text = g.description ?? '';
      _selectedColorValue = g.colorValue;
      _selectedMemberIds.addAll(g.memberIds);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(String ptId, List<MemberProfile> allMembers) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedMemberIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.groupNeedMembers),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final memberMap = {
        for (final m in allMembers)
          if (_selectedMemberIds.contains(m.memberId)) m.memberId: m.name,
      };

      final repo = ref.read(groupRepositoryProvider);

      if (isEdit) {
        final updated = widget.initialGroup!.copyWith(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          colorValue: _selectedColorValue,
          memberIds: _selectedMemberIds.toList(),
          memberNames: memberMap,
        );
        await repo.updateGroup(updated);
      } else {
        await repo.createGroup(
          ptId: ptId,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          colorValue: _selectedColorValue,
          memberIds: _selectedMemberIds.toList(),
          memberNames: memberMap,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error('$e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.valueOrNull;
    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final membersAsync = ref.watch(ptMembersProvider(user.uid));
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.editGroup : l10n.createGroup),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () => membersAsync.whenData(
                    (members) => _save(user.uid, members)),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(strokeWidth: 2))
                : Text(l10n.save,
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Group name ──────────────────────────────────────────────────
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: l10n.groupName,
                hintText: l10n.groupNameHint,
                prefixIcon: const Icon(Icons.group),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.groupDescription,
                hintText: l10n.groupDescriptionHint,
                prefixIcon: const Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),

            // ── Color picker ────────────────────────────────────────────────
            Text(l10n.groupColor,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: _colors.map((c) {
                final selected = c.toARGB32() == _selectedColorValue;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedColorValue = c.toARGB32()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(
                              color: theme.colorScheme.onSurface,
                              width: 3)
                          : null,
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                  color: c.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ]
                          : null,
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── Member selection ────────────────────────────────────────────
            Row(
              children: [
                Text(l10n.selectMembers,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_selectedMemberIds.isNotEmpty)
                  Text(
                    '${_selectedMemberIds.length} ${l10n.selected}',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
              data: (members) {
                final active =
                    members.where((m) => m.isActive).toList();
                if (active.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l10n.noActiveMembers,
                        style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant)),
                  );
                }
                return Column(
                  children: active
                      .map((m) => _MemberSelectTile(
                            member: m,
                            isSelected:
                                _selectedMemberIds.contains(m.memberId),
                            groupColor:
                                Color(_selectedColorValue),
                            onToggle: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedMemberIds.add(m.memberId);
                                } else {
                                  _selectedMemberIds.remove(m.memberId);
                                }
                              });
                            },
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberSelectTile extends StatelessWidget {
  final MemberProfile member;
  final bool isSelected;
  final Color groupColor;
  final ValueChanged<bool> onToggle;

  const _MemberSelectTile({
    required this.member,
    required this.isSelected,
    required this.groupColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? groupColor
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () => onToggle(!isSelected),
        leading: UserAvatar(
            photoUrl: member.photoUrl, name: member.name, radius: 20),
        title: Text(member.name,
            style: TextStyle(
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400)),
        subtitle: Text(member.email,
            style: const TextStyle(fontSize: 12)),
        trailing: Checkbox(
          value: isSelected,
          activeColor: groupColor,
          shape: const CircleBorder(),
          onChanged: (v) => onToggle(v ?? false),
        ),
      ),
    );
  }
}
