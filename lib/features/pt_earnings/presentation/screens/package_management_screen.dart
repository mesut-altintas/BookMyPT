import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/pt_members/providers/pt_members_provider.dart';
import '../../../../shared/models/member_model.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';

class PackageManagementScreen extends ConsumerWidget {
  const PackageManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _PackageContent(ptId: user.uid);
      },
    );
  }
}

class _PackageContent extends ConsumerWidget {
  final String ptId;

  const _PackageContent({required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(allPtPackagesProvider(ptId));

    return Scaffold(
      appBar: AppBar(title: const Text('Paket Yönetimi')),
      body: packagesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (packages) {
          if (packages.isEmpty) {
            return AppEmpty(
              message: 'Henüz paket oluşturmadınız',
              subMessage: 'Üyeleriniz için seans paketi oluşturun',
              icon: Icons.inventory_2_outlined,
              action: ElevatedButton.icon(
                onPressed: () => _showAddPackageSheet(context, ref, ptId),
                icon: const Icon(Icons.add),
                label: const Text('Paket Ekle'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: packages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _PackageTile(
              package: packages[i],
              ptId: ptId,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPackageSheet(context, ref, ptId),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPackageSheet(
      BuildContext context, WidgetRef ref, String ptId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddPackageSheet(ptId: ptId, ref: ref),
    );
  }
}

class _PackageTile extends ConsumerWidget {
  final PackageModel package;
  final String ptId;

  const _PackageTile({required this.package, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(earningsRepositoryProvider);
    final theme = Theme.of(context);

    String subtitle = '${package.sessionCount} seans';
    if (package.sessionDurationMinutes != null) {
      subtitle += ' • ${package.sessionDurationMinutes} dk';
    }
    subtitle += ' • ${package.price.formattedCurrency}';

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: package.isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.inventory_2,
            color: package.isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(package.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            if (package.isForSpecificMember)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Özel',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSecondaryContainer),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (package.isForSpecificMember && package.forMemberName != null)
              Text(
                package.forMemberName!,
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500),
              ),
          ],
        ),
        isThreeLine: package.isForSpecificMember && package.forMemberName != null,
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Düzenle')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(package.isActive ? 'Pasife Al' : 'Aktive Et'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
          onSelected: (value) async {
            final messenger = ScaffoldMessenger.of(context);
            if (value == 'edit') {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => _EditPackageSheet(
                    ptId: ptId, package: package, ref: ref),
              );
            } else if (value == 'toggle') {
              await repo.updatePackage(
                  ptId, package.id, {'isActive': !package.isActive});
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                useRootNavigator: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Paketi Sil'),
                  content: const Text('Bu paketi silmek istiyor musunuz?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('İptal'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await repo.deletePackage(ptId, package.id);
                  messenger.showSnackBar(const SnackBar(
                    content: Text('Paket silindi'),
                    behavior: SnackBarBehavior.floating,
                  ));
                } catch (e) {
                  messenger.showSnackBar(SnackBar(
                    content: Text('Silinemedi: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            }
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared form widgets
// ---------------------------------------------------------------------------

const _kDurations = [30, 45, 60, 90, 120];
const _kQuickCounts = [5, 10, 15, 20, 25];

/// Session count: text field + quick-select chips
class _SessionCountField extends StatelessWidget {
  final TextEditingController controller;
  final int? selectedQuick;
  final ValueChanged<int> onQuickTap;

  const _SessionCountField({
    required this.controller,
    required this.selectedQuick,
    required this.onQuickTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Seans Sayısı',
            prefixIcon: Icon(Icons.format_list_numbered),
          ),
          validator: (v) {
            final n = int.tryParse(v?.trim() ?? '');
            if (n == null || n < 1) return 'Geçerli bir sayı girin';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _kQuickCounts
              .map((c) => ChoiceChip(
                    label: Text('$c'),
                    selected: selectedQuick == c,
                    onSelected: (_) => onQuickTap(c),
                    visualDensity: VisualDensity.compact,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// Session duration chips (optional)
class _SessionDurationField extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;

  const _SessionDurationField(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seans Süresi',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: _kDurations
              .map((d) {
                final label = d < 60
                    ? '$d dk'
                    : '${d ~/ 60} sa${d % 60 != 0 ? ' ${d % 60} dk' : ''}';
                return ChoiceChip(
                  label: Text(label),
                  selected: selected == d,
                  onSelected: (_) =>
                      onChanged(selected == d ? null : d),
                  visualDensity: VisualDensity.compact,
                );
              })
              .toList(),
        ),
      ],
    );
  }
}

/// Member-specific selector
class _MemberSelector extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final List<MemberProfile> members;
  final String? selectedMemberId;
  final ValueChanged<String?> onMemberChanged;

  const _MemberSelector({
    required this.isEnabled,
    required this.onToggle,
    required this.members,
    required this.selectedMemberId,
    required this.onMemberChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_pin_outlined,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Üyeye özel paket',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Switch(
              value: isEnabled,
              onChanged: onToggle,
            ),
          ],
        ),
        if (isEnabled) ...[
          const SizedBox(height: 8),
          members.isEmpty
              ? Text('Henüz üye yok',
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13))
              : DropdownButtonFormField<String>(
                  value: selectedMemberId,
                  hint: const Text('Üye seç'),
                  isExpanded: true,
                  items: members
                      .map((m) => DropdownMenuItem<String>(
                            value: m.memberId,
                            child: Text(
                                m.name.isNotEmpty ? m.name : m.email),
                          ))
                      .toList(),
                  onChanged: onMemberChanged,
                  validator: isEnabled
                      ? (v) => v == null ? 'Üye seçin' : null
                      : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Edit Package Sheet
// ---------------------------------------------------------------------------

class _EditPackageSheet extends ConsumerStatefulWidget {
  final String ptId;
  final PackageModel package;
  final WidgetRef ref;

  const _EditPackageSheet(
      {required this.ptId, required this.package, required this.ref});

  @override
  ConsumerState<_EditPackageSheet> createState() => _EditPackageSheetState();
}

class _EditPackageSheetState extends ConsumerState<_EditPackageSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _sessionCountCtrl;
  late int? _sessionDurationMinutes;
  late int? _quickSessionCount;
  late bool _isForSpecificMember;
  late String? _forMemberId;
  late String? _forMemberName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.package.name);
    _priceCtrl =
        TextEditingController(text: widget.package.price.toStringAsFixed(0));
    _descCtrl = TextEditingController(text: widget.package.description ?? '');
    _sessionCountCtrl =
        TextEditingController(text: '${widget.package.sessionCount}');
    _quickSessionCount = _kQuickCounts.contains(widget.package.sessionCount)
        ? widget.package.sessionCount
        : null;
    _sessionDurationMinutes = widget.package.sessionDurationMinutes;
    _isForSpecificMember = widget.package.isForSpecificMember;
    _forMemberId = widget.package.forMemberId;
    _forMemberName = widget.package.forMemberName;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _sessionCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isForSpecificMember && (_forMemberId == null || _forMemberId!.isEmpty))
      return;
    setState(() => _isLoading = true);
    try {
      await ref.read(earningsRepositoryProvider).updatePackage(
        widget.ptId,
        widget.package.id,
        {
          'name': _nameCtrl.text.trim(),
          'sessionCount': int.parse(_sessionCountCtrl.text.trim()),
          if (_sessionDurationMinutes != null)
            'sessionDurationMinutes': _sessionDurationMinutes,
          'price': double.parse(_priceCtrl.text.trim()),
          'description':
              _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
          'forMemberId':
              _isForSpecificMember ? _forMemberId : null,
          'forMemberName':
              _isForSpecificMember ? _forMemberName : null,
        },
      );
      // If this is a member-specific package with a duration, sync it to the member profile
      if (_isForSpecificMember &&
          _forMemberId != null &&
          _sessionDurationMinutes != null) {
        await ref.read(memberRepositoryProvider).updateMember(
              ptId: widget.ptId,
              memberId: _forMemberId!,
              data: {'sessionDurationMinutes': _sessionDurationMinutes},
            );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members =
        ref.watch(ptMembersProvider(widget.ptId)).valueOrNull ?? [];

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Paketi Düzenle',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, 'Paket adı'),
                decoration: const InputDecoration(labelText: 'Paket Adı'),
              ),
              const SizedBox(height: 12),
              _SessionCountField(
                controller: _sessionCountCtrl,
                selectedQuick: _quickSessionCount,
                onQuickTap: (c) => setState(() {
                  _quickSessionCount = c;
                  _sessionCountCtrl.text = '$c';
                }),
              ),
              const SizedBox(height: 12),
              _SessionDurationField(
                selected: _sessionDurationMinutes,
                onChanged: (d) =>
                    setState(() => _sessionDurationMinutes = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                validator: Validators.positiveNumber,
                decoration: const InputDecoration(
                  labelText: 'Fiyat (TRY)',
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (İsteğe bağlı)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              _MemberSelector(
                isEnabled: _isForSpecificMember,
                onToggle: (v) => setState(() {
                  _isForSpecificMember = v;
                  if (!v) {
                    _forMemberId = null;
                    _forMemberName = null;
                  }
                }),
                members: members,
                selectedMemberId: _forMemberId,
                onMemberChanged: (id) {
                  final m = members.firstWhere((m) => m.memberId == id,
                      orElse: () => members.first);
                  setState(() {
                    _forMemberId = id;
                    _forMemberName =
                        m.name.isNotEmpty ? m.name : m.email;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Package Sheet
// ---------------------------------------------------------------------------

class _AddPackageSheet extends ConsumerStatefulWidget {
  final String ptId;
  final WidgetRef ref;

  const _AddPackageSheet({required this.ptId, required this.ref});

  @override
  ConsumerState<_AddPackageSheet> createState() => _AddPackageSheetState();
}

class _AddPackageSheetState extends ConsumerState<_AddPackageSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _sessionCountCtrl = TextEditingController(text: '10');
  int? _quickSessionCount = 10;
  int? _sessionDurationMinutes;
  bool _isForSpecificMember = false;
  String? _forMemberId;
  String? _forMemberName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _sessionCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isForSpecificMember && (_forMemberId == null || _forMemberId!.isEmpty))
      return;

    setState(() => _isLoading = true);

    final package = PackageModel(
      id: '',
      ptId: widget.ptId,
      name: _nameCtrl.text.trim(),
      sessionCount: int.parse(_sessionCountCtrl.text.trim()),
      sessionDurationMinutes: _sessionDurationMinutes,
      price: double.parse(_priceCtrl.text.trim()),
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
      forMemberId: _isForSpecificMember ? _forMemberId : null,
      forMemberName: _isForSpecificMember ? _forMemberName : null,
    );

    try {
      await ref.read(earningsRepositoryProvider).createPackage(package);
      // If this is a member-specific package with a duration, sync it to the member profile
      if (_isForSpecificMember &&
          _forMemberId != null &&
          _sessionDurationMinutes != null) {
        await ref.read(memberRepositoryProvider).updateMember(
              ptId: widget.ptId,
              memberId: _forMemberId!,
              data: {'sessionDurationMinutes': _sessionDurationMinutes},
            );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members =
        ref.watch(ptMembersProvider(widget.ptId)).valueOrNull ?? [];

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Yeni Paket',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, 'Paket adı'),
                decoration: const InputDecoration(labelText: 'Paket Adı'),
              ),
              const SizedBox(height: 12),
              _SessionCountField(
                controller: _sessionCountCtrl,
                selectedQuick: _quickSessionCount,
                onQuickTap: (c) => setState(() {
                  _quickSessionCount = c;
                  _sessionCountCtrl.text = '$c';
                }),
              ),
              const SizedBox(height: 12),
              _SessionDurationField(
                selected: _sessionDurationMinutes,
                onChanged: (d) =>
                    setState(() => _sessionDurationMinutes = d),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                validator: Validators.positiveNumber,
                decoration: const InputDecoration(
                  labelText: 'Fiyat (TRY)',
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (İsteğe bağlı)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              _MemberSelector(
                isEnabled: _isForSpecificMember,
                onToggle: (v) => setState(() {
                  _isForSpecificMember = v;
                  if (!v) {
                    _forMemberId = null;
                    _forMemberName = null;
                  }
                }),
                members: members,
                selectedMemberId: _forMemberId,
                onMemberChanged: (id) {
                  if (id == null) return;
                  final m = members.firstWhere((m) => m.memberId == id,
                      orElse: () => members.first);
                  setState(() {
                    _forMemberId = id;
                    _forMemberName =
                        m.name.isNotEmpty ? m.name : m.email;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Paketi Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
