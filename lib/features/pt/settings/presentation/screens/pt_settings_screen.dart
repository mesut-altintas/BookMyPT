import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/platform/native_calendar_bridge.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../members/data/models/trainer_model.dart';
import '../../../calendar/presentation/providers/trainer_provider.dart';

class PtSettingsScreen extends ConsumerStatefulWidget {
  const PtSettingsScreen({super.key});

  @override
  ConsumerState<PtSettingsScreen> createState() => _PtSettingsScreenState();
}

class _PtSettingsScreenState extends ConsumerState<PtSettingsScreen> {
  bool _loadingCalendars = false;

  Future<void> _pickCalendar(TrainerModel trainer) async {
    setState(() => _loadingCalendars = true);
    final bridge = NativeCalendarBridge();
    final calendars = await bridge.getCalendars();
    setState(() => _loadingCalendars = false);

    if (!mounted) return;

    if (calendars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cihazda takvim bulunamadı veya izin verilmedi.')),
      );
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Takvim Seçin'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: calendars.length,
            itemBuilder: (_, i) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(calendars[i].color),
                radius: 8,
              ),
              title: Text(calendars[i].name),
              selected: calendars[i].id == trainer.selectedCalendarId,
              onTap: () => Navigator.pop(context, calendars[i].id),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );

    if (selected != null) {
      final user = ref.read(authNotifierProvider).valueOrNull;
      if (user == null) return;
      await ref
          .read(calendarDataSourceProvider)
          .updateTrainer(user.id, {'selectedCalendarId': selected});
    }
  }

  Future<void> _updateSetting(String field, dynamic value) async {
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;
    await ref
        .read(calendarDataSourceProvider)
        .updateTrainer(user.id, {field: value});
  }

  @override
  Widget build(BuildContext context) {
    final trainerAsync = ref.watch(trainerStreamProvider);

    return trainerAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
      data: (trainer) {
        if (trainer == null) {
          return const Center(child: Text('Trainer verisi bulunamadı.'));
        }
        return ListView(
          children: [
            _SectionHeader('Takvim'),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Cihaz Takvimi'),
              subtitle: Text(trainer.selectedCalendarId != null
                  ? 'Takvim seçildi'
                  : 'Takvim seçilmedi'),
              trailing: _loadingCalendars
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: () => _pickCalendar(trainer),
            ),
            const Divider(),
            _SectionHeader('Ders Ayarları'),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Ders Süresi'),
              subtitle: Text('${trainer.slotDuration} dakika'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showOptionPicker(
                title: 'Ders Süresi',
                options: AppConstants.slotDurationOptions,
                current: trainer.slotDuration,
                unit: 'dk',
                onSelected: (v) => _updateSetting('slotDuration', v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.free_breakfast),
              title: const Text('Mola Süresi'),
              subtitle: Text('${trainer.breakDuration} dakika'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showOptionPicker(
                title: 'Mola Süresi',
                options: AppConstants.breakDurationOptions,
                current: trainer.breakDuration,
                unit: 'dk',
                onSelected: (v) => _updateSetting('breakDuration', v),
              ),
            ),
            const Divider(),
            _SectionHeader('Çalışma Saatleri'),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Başlangıç Saati'),
              subtitle: Text('${trainer.workStartHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHourPicker(
                title: 'Başlangıç Saati',
                current: trainer.workStartHour,
                onSelected: (v) => _updateSetting('workStartHour', v),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.access_time_filled),
              title: const Text('Bitiş Saati'),
              subtitle: Text('${trainer.workEndHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showHourPicker(
                title: 'Bitiş Saati',
                current: trainer.workEndHour,
                onSelected: (v) {
                  if (v <= trainer.workStartHour) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Bitiş saati başlangıç saatinden sonra olmalıdır.')),
                    );
                    return;
                  }
                  _updateSetting('workEndHour', v);
                },
              ),
            ),
            const Divider(),
            _SectionHeader('Tatil Günleri'),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Çalışılmayan Günler'),
              subtitle: Text(
                trainer.blockedDays.isEmpty
                    ? 'Her gün çalışılıyor'
                    : _blockedDaysLabel(trainer.blockedDays),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showBlockedDaysPicker(trainer.blockedDays),
            ),
          ],
        );
      },
    );
  }

  void _showOptionPicker({
    required String title,
    required List<int> options,
    required int current,
    required String unit,
    required void Function(int) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options
              .map((v) => RadioListTile<int>(
                    value: v,
                    groupValue: current,
                    title: Text('$v $unit'),
                    onChanged: (val) {
                      if (val != null) {
                        onSelected(val);
                        Navigator.pop(context);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  static const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  String _blockedDaysLabel(List<int> days) {
    return days.map((d) => _dayNames[d - 1]).join(', ');
  }

  Future<void> _showBlockedDaysPicker(List<int> current) async {
    final selected = Set<int>.from(current);
    final result = await showDialog<List<int>>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Çalışılmayan Günler'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (i) {
              final day = i + 1;
              return CheckboxListTile(
                value: selected.contains(day),
                title: Text(_dayNames[i]),
                onChanged: (v) => setState(() {
                  if (v == true) {
                    selected.add(day);
                  } else {
                    selected.remove(day);
                  }
                }),
              );
            }),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('İptal')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, selected.toList()..sort()),
                child: const Text('Kaydet')),
          ],
        ),
      ),
    );

    if (result != null) {
      await _updateSetting('blockedDays', result);
    }
  }

  void _showHourPicker({
    required String title,
    required int current,
    required void Function(int) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 200,
          height: 300,
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (_, i) => ListTile(
              title: Text('$i:00'),
              selected: i == current,
              selectedColor: Colors.blue,
              onTap: () {
                onSelected(i);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      );
}
