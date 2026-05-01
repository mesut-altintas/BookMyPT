import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../shared/models/progress_model.dart';
import '../../../../shared/widgets/app_loading.dart';
import '../../providers/progress_provider.dart';

class AddProgressScreen extends ConsumerStatefulWidget {
  const AddProgressScreen({super.key});

  @override
  ConsumerState<AddProgressScreen> createState() => _AddProgressScreenState();
}

class _AddProgressScreenState extends ConsumerState<AddProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipsCtrl = TextEditingController();
  final _bicepCtrl = TextEditingController();
  final _thighCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  File? _selectedPhoto;
  bool _isLoading = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _hipsCtrl.dispose();
    _bicepCtrl.dispose();
    _thighCtrl.dispose();
    _bodyFatCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedPhoto = File(picked.path));
    }
  }

  Future<String?> _uploadPhoto(String memberId) async {
    if (_selectedPhoto == null) return null;
    await FirebaseAuth.instance.currentUser?.getIdToken();
    final storageRef = FirebaseStorage.instance.ref(
        'progress_photos/$memberId/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putFile(
      _selectedPhoto!,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return storageRef.getDownloadURL();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.tryParse(_weightCtrl.text);
    if (weight == null && _selectedPhoto == null &&
        _waistCtrl.text.isEmpty && _chestCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir ölçüm girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    try {
      final photoUrl = await _uploadPhoto(user.uid);

      final measurements = BodyMeasurements(
        chest: double.tryParse(_chestCtrl.text),
        waist: double.tryParse(_waistCtrl.text),
        hips: double.tryParse(_hipsCtrl.text),
        bicep: double.tryParse(_bicepCtrl.text),
        thigh: double.tryParse(_thighCtrl.text),
        bodyFatPercent: double.tryParse(_bodyFatCtrl.text),
      );

      final progress = ProgressModel(
        id: '',
        memberId: user.uid,
        date: DateTime.now(),
        weight: weight,
        measurements: measurements,
        photoUrl: photoUrl,
        notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text.trim(),
      );

      await ref.read(progressRepositoryProvider).addProgress(progress);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('İlerleme kaydedildi')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: AppLoading(message: 'Kaydediliyor...'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlerleme Ekle'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Kaydet')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  image: _selectedPhoto != null
                      ? DecorationImage(
                          image: FileImage(_selectedPhoto!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedPhoto == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'İlerleme Fotoğrafı Ekle',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Weight
            TextFormField(
              controller: _weightCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilo (kg)',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Vücut Ölçüleri (cm)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _chestCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Göğüs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _waistCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bel'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hipsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kalça'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bicepCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Kol (bicep)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _thighCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Bacak'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bodyFatCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Yağ Oranı (%)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notlar (İsteğe bağlı)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
