import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/providers/auth_provider.dart';
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

    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: package.isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.inventory_2,
            color: package.isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        title: Text(
          package.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${package.sessionCount} seans • ${package.price.formattedCurrency}',
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Düzenle'),
            ),
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
                builder: (_) =>
                    _EditPackageSheet(ptId: ptId, package: package, ref: ref),
              );
            } else if (value == 'toggle') {
              await repo.updatePackage(
                  ptId, package.id, {'isActive': !package.isActive});
            } else if (value == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
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
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Sil'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                try {
                  await repo.deletePackage(ptId, package.id);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Paket silindi'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Silinemedi: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
          },
        ),
      ),
    );
  }
}

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
  late int _sessionCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.package.name);
    _priceCtrl =
        TextEditingController(text: widget.package.price.toStringAsFixed(0));
    _descCtrl = TextEditingController(text: widget.package.description ?? '');
    _sessionCount = widget.package.sessionCount;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(earningsRepositoryProvider).updatePackage(
        widget.ptId,
        widget.package.id,
        {
          'name': _nameCtrl.text.trim(),
          'sessionCount': _sessionCount,
          'price': double.parse(_priceCtrl.text.trim()),
          'description':
              _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
        },
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Paketi Düzenle',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, 'Paket adı'),
                decoration: const InputDecoration(labelText: 'Paket Adı'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Seans Sayısı:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  ...([5, 10, 15, 20, 25]).map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text('$c'),
                        selected: _sessionCount == c,
                        onSelected: (_) =>
                            setState(() => _sessionCount = c),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  int _sessionCount = 10;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final package = PackageModel(
      id: '',
      ptId: widget.ptId,
      name: _nameCtrl.text.trim(),
      sessionCount: _sessionCount,
      price: double.parse(_priceCtrl.text.trim()),
      description: _descCtrl.text.isEmpty ? null : _descCtrl.text.trim(),
    );

    try {
      await ref.read(earningsRepositoryProvider).createPackage(package);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Yeni Paket',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, 'Paket adı'),
                decoration: const InputDecoration(labelText: 'Paket Adı'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Seans Sayısı:',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  ...([5, 10, 15, 20, 25]).map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: ChoiceChip(
                        label: Text('$c'),
                        selected: _sessionCount == c,
                        onSelected: (_) =>
                            setState(() => _sessionCount = c),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Paketi Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
