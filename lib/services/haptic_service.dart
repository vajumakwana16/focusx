import 'package:flutter/services.dart';
import '../provider/haptic_provider.dart';

class HapticService {
  static bool get _enabled =>
      HapticProvider.instance?.enabled ?? true;

  static void tap() {
    if (!_enabled) return;
    HapticFeedback.selectionClick();
  }

  static void light() {
    if (!_enabled) return;
    HapticFeedback.lightImpact();
  }

  static void heavy() {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
  }
}