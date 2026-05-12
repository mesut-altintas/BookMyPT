import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/extensions.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../features/m_calendar/providers/invitation_provider.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/widgets/app_loading.dart';

class FindPtScreen extends ConsumerStatefulWidget {
  const FindPtScreen({super.key});

  @override
  ConsumerState<FindPtScreen> createState() => _FindPtScreenState();
}

class _FindPtScreenState extends ConsumerState<FindPtScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _allPts = [];
  List<UserModel> _results = [];
  bool _loadingAll = false;
  bool _sending = false;
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    _loadAllPts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAllPts() async {
    setState(() => _loadingAll = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.roleTrainer)
          .limit(200)
          .get();
      final pts = snap.docs.map(UserModel.fromFirestore).toList();
      if (mounted) setState(() => _allPts = pts);
    } catch (_) {}
    if (mounted) setState(() => _loadingAll = false);
  }

  void _search() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _searched = true;
      if (q.isEmpty) {
        _results = [];
        return;
      }
      _results = _allPts
          .where((pt) =>
              pt.name.toLowerCase().contains(q) ||
              pt.email.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> _sendRequest(UserModel pt) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.ptRequestTitle),
        content: Text(context.l10n.ptRequestContent(pt.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10n.sendRequest)),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _sending = true);
    try {
      await ref.read(invitationRepositoryProvider).createMemberRequest(
            ptId: pt.uid,
            ptName: pt.name,
            memberId: user.uid,
            memberName: user.name,
            memberEmail: user.email,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.requestSentTo(pt.name)),
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(context.l10n.error('$e')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.findPtTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: context.l10n.searchByNameOrEmail,
                prefixIcon: const Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              onChanged: (_) => _search(),
            ),
          ),
          if (_sending) const LinearProgressIndicator(),
          Expanded(
            child: _loadingAll
                ? const AppLoading()
                : !_searched || _searchCtrl.text.trim().isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search,
                                size: 64,
                                color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 12),
                            Text(
                              context.l10n.searchHintFull,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : _results.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.noResultFor(_searchCtrl.text.trim()),
                              style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final pt = _results[i];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    child: Text(pt.initials,
                                        style: TextStyle(
                                            color: theme.colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  title: Text(pt.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(pt.email,
                                      style: TextStyle(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                          fontSize: 12)),
                                  trailing: TextButton(
                                    onPressed: _sending
                                        ? null
                                        : () => _sendRequest(pt),
                                    child: Text(context.l10n.sendRequest),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
