import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppColorScheme { classic, sport }

final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, AppColorScheme>((ref) {
  return ColorSchemeNotifier();
});

class ColorSchemeNotifier extends StateNotifier<AppColorScheme> {
  ColorSchemeNotifier() : super(AppColorScheme.classic) {
    _load();
  }

  static const _key = 'color_scheme';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    state = value == 'sport' ? AppColorScheme.sport : AppColorScheme.classic;
  }

  Future<void> setColorScheme(AppColorScheme scheme) async {
    state = scheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, scheme.name);
  }
}
