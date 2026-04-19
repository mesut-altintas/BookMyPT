import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/member_model.dart';
import '../providers/members_provider.dart';
import '../widgets/member_card.dart';
import 'add_member_screen.dart';

class PtMembersScreen extends ConsumerWidget {
  const PtMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(membersStreamProvider);
    final filter = ref.watch(memberFilterProvider);
    final filtered = ref.watch(filteredMembersProvider);

    return Scaffold(
      body: Column(
        children: [
          // Filtre chip'leri
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tümü',
                  selected: filter == MemberFilter.all,
                  onTap: () => ref.read(memberFilterProvider.notifier).state =
                      MemberFilter.all,
                  count: membersAsync.valueOrNull?.length,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Aktif',
                  selected: filter == MemberFilter.active,
                  color: Colors.green,
                  onTap: () => ref.read(memberFilterProvider.notifier).state =
                      MemberFilter.active,
                  count: membersAsync.valueOrNull
                      ?.where((m) => m.status == MemberStatus.active)
                      .length,
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pasif',
                  selected: filter == MemberFilter.passive,
                  color: Colors.grey,
                  onTap: () => ref.read(memberFilterProvider.notifier).state =
                      MemberFilter.passive,
                  count: membersAsync.valueOrNull
                      ?.where((m) => m.status == MemberStatus.passive)
                      .length,
                ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: membersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Hata: $e')),
              data: (_) {
                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Üye bulunamadı.\nSağ alttaki + butonuyla ekleyin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => MemberCard(member: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMemberScreen()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Üye Ekle'),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final int? count;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = Colors.blue,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            count != null ? '$label ($count)' : label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? color : Colors.grey.shade700,
            ),
          ),
        ),
      );
}
