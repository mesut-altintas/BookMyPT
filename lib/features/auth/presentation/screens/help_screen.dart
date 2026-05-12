import 'package:flutter/material.dart';

import '../../../../core/l10n/extensions.dart';

class HelpScreen extends StatelessWidget {
  final bool isPt;
  const HelpScreen({super.key, required this.isPt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.helpGuideTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: isPt ? _ptSections(context) : _memberSections(context),
      ),
    );
  }

  // ── MEMBER ──────────────────────────────────────────────────────────────────

  List<Widget> _memberSections(BuildContext context) => [
        _intro(
          context,
          icon: Icons.waving_hand_outlined,
          title: context.l10n.helpWelcomeTitle,
          body: context.l10n.helpMemberIntroBody,
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: context.l10n.helpHomeTitle,
          color: Colors.indigo,
          items: [
            _HelpItem(
              title: context.l10n.helpHomeItem1Title,
              body: context.l10n.helpHomeItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpHomeItem2Title,
              body: context.l10n.helpHomeItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpHomeItem3Title,
              body: context.l10n.helpHomeItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.calendar_today_outlined,
          title: context.l10n.helpCalendarTitle,
          color: Colors.teal,
          items: [
            _HelpItem(
              title: context.l10n.helpCalendarItem1Title,
              body: context.l10n.helpCalendarItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpCalendarItem2Title,
              body: context.l10n.helpCalendarItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpCalendarItem3Title,
              body: context.l10n.helpCalendarItem3Body,
            ),
            _HelpItem(
              title: context.l10n.helpCalendarItem4Title,
              body: context.l10n.helpCalendarItem4Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.event_note_outlined,
          title: context.l10n.helpMyCalendarTitle,
          color: Colors.purple,
          items: [
            _HelpItem(
              title: context.l10n.helpMyCalendarItem1Title,
              body: context.l10n.helpMyCalendarItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpMyCalendarItem2Title,
              body: context.l10n.helpMyCalendarItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpMyCalendarItem3Title,
              body: context.l10n.helpMyCalendarItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: context.l10n.helpPackagesTitle,
          color: Colors.orange,
          items: [
            _HelpItem(
              title: context.l10n.helpPackagesItem1Title,
              body: context.l10n.helpPackagesItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPackagesItem2Title,
              body: context.l10n.helpPackagesItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPackagesItem3Title,
              body: context.l10n.helpPackagesItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.show_chart_outlined,
          title: context.l10n.helpProgressTitle,
          color: Colors.green,
          items: [
            _HelpItem(
              title: context.l10n.helpProgressItem1Title,
              body: context.l10n.helpProgressItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpProgressItem2Title,
              body: context.l10n.helpProgressItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpProgressItem3Title,
              body: context.l10n.helpProgressItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.chat_bubble_outline,
          title: context.l10n.helpMessagesTitle,
          color: Colors.blue,
          items: [
            _HelpItem(
              title: context.l10n.helpMemberMessagesItem1Title,
              body: context.l10n.helpMemberMessagesItem1Body,
            ),
          ],
        ),
        _tipBox(context),
        const SizedBox(height: 24),
      ];

  // ── PT ──────────────────────────────────────────────────────────────────────

  List<Widget> _ptSections(BuildContext context) => [
        _intro(
          context,
          icon: Icons.waving_hand_outlined,
          title: context.l10n.helpWelcomeTitle,
          body: context.l10n.helpPtIntroBody,
        ),
        _section(
          context,
          icon: Icons.home_outlined,
          title: context.l10n.helpHomeTitle,
          color: Colors.indigo,
          items: [
            _HelpItem(
              title: context.l10n.helpPtHomeItem1Title,
              body: context.l10n.helpPtHomeItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtHomeItem2Title,
              body: context.l10n.helpPtHomeItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtHomeItem3Title,
              body: context.l10n.helpPtHomeItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.calendar_today_outlined,
          title: context.l10n.helpPtCalendarTitle,
          color: Colors.teal,
          items: [
            _HelpItem(
              title: context.l10n.helpPtCalendarItem1Title,
              body: context.l10n.helpPtCalendarItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtCalendarItem2Title,
              body: context.l10n.helpPtCalendarItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtCalendarItem3Title,
              body: context.l10n.helpPtCalendarItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.people_outline,
          title: context.l10n.helpPtMembersTitle,
          color: Colors.purple,
          items: [
            _HelpItem(
              title: context.l10n.helpPtMembersItem1Title,
              body: context.l10n.helpPtMembersItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtMembersItem2Title,
              body: context.l10n.helpPtMembersItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtMembersItem3Title,
              body: context.l10n.helpPtMembersItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.inventory_2_outlined,
          title: context.l10n.helpPtPackagesTitle,
          color: Colors.orange,
          items: [
            _HelpItem(
              title: context.l10n.helpPtPackagesItem1Title,
              body: context.l10n.helpPtPackagesItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtPackagesItem2Title,
              body: context.l10n.helpPtPackagesItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtPackagesItem3Title,
              body: context.l10n.helpPtPackagesItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.payments_outlined,
          title: context.l10n.helpPtEarningsTitle,
          color: Colors.green,
          items: [
            _HelpItem(
              title: context.l10n.helpPtEarningsItem1Title,
              body: context.l10n.helpPtEarningsItem1Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtEarningsItem2Title,
              body: context.l10n.helpPtEarningsItem2Body,
            ),
            _HelpItem(
              title: context.l10n.helpPtEarningsItem3Title,
              body: context.l10n.helpPtEarningsItem3Body,
            ),
          ],
        ),
        _section(
          context,
          icon: Icons.chat_bubble_outline,
          title: context.l10n.helpMessagesTitle,
          color: Colors.blue,
          items: [
            _HelpItem(
              title: context.l10n.helpPtMessagesItem1Title,
              body: context.l10n.helpPtMessagesItem1Body,
            ),
          ],
        ),
        _tipBox(context),
        const SizedBox(height: 24),
      ];

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _intro(BuildContext context,
      {required IconData icon,
      required String title,
      required String body}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Card(
        color: theme.colorScheme.primaryContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 28, color: theme.colorScheme.onPrimaryContainer),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        )),
                    const SizedBox(height: 6),
                    Text(body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.85),
                          height: 1.5,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required List<_HelpItem> items,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map((item) => _buildItem(context, item, color))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, _HelpItem item, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 3),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 3),
                Text(item.body,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipBox(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lightbulb_outline,
                color: Colors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.helpTipBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpItem {
  final String title;
  final String body;
  const _HelpItem({required this.title, required this.body});
}
