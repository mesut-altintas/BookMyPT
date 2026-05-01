import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/payment_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../../../shared/widgets/app_empty.dart';
import '../../providers/payment_provider.dart';
import '../../../pt_earnings/providers/pt_earnings_provider.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return userAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text(e.toString()))),
      data: (user) {
        if (user == null) return const Scaffold(body: AppLoading());
        return _PaymentContent(memberId: user.uid, ptId: user.ptId);
      },
    );
  }
}

class _PaymentContent extends StatelessWidget {
  final String memberId;
  final String? ptId;

  const _PaymentContent({required this.memberId, this.ptId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paketlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppRoutes.paymentHistory),
          ),
        ],
      ),
      body: (ptId == null || ptId!.isEmpty)
          ? const AppEmpty(
              message: 'PT atanmamış',
              subMessage:
                  'PT\'niz sizi sisteme ekledikten sonra paketleri görebilirsiniz',
              icon: Icons.person_off_outlined,
            )
          : _PackageList(memberId: memberId, ptId: ptId!),
    );
  }
}

class _PackageList extends ConsumerWidget {
  final String memberId;
  final String ptId;

  const _PackageList({required this.memberId, required this.ptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packagesAsync = ref.watch(ptPackagesProvider(ptId));

    return packagesAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (packages) {
        if (packages.isEmpty) {
          return const AppEmpty(
            message: 'Henüz paket tanımlanmamış',
            subMessage: 'PT\'niz paket oluşturduğunda burada görünür',
            icon: Icons.inventory_2_outlined,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: packages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) =>
              _PackageCard(package: packages[i], memberId: memberId),
        );
      },
    );
  }
}

class _PackageCard extends ConsumerWidget {
  final PackageModel package;
  final String memberId;

  const _PackageCard({required this.package, required this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.fitness_center,
                      color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(package.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('${package.sessionCount} seans',
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text(
                  package.price.formattedCurrency,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (package.description != null &&
                package.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(package.description!,
                  style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _purchase(context, ref),
                child: const Text('Satın Al'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Paket Satın Al'),
        content: Text(
          '${package.name} paketini ${package.price.formattedCurrency} karşılığında satın almak istiyor musunuz?\n\n'
          '${package.sessionCount} seans hakkı PT onayından sonra hesabınıza yüklenecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(paymentRepositoryProvider).createPayment(
            PaymentModel(
              id: '',
              memberId: memberId,
              ptId: package.ptId,
              amount: package.price,
              currency: package.currency,
              status: PaymentStatus.pending,
              packageName: package.name,
              sessionCount: package.sessionCount,
              createdAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Ödeme talebiniz oluşturuldu. PT\'niz onayladığında seans hakkınız yüklenecektir.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
