import 'dart:math';
import '../constants/app_constants.dart';

class CodeGenerator {
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final _random = Random.secure();

  static String generateAccessCode() {
    return List.generate(
      AppConstants.accessCodeLength,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}
