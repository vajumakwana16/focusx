import 'package:flutter/material.dart';
import 'package:focusx/utils/webservice.dart';

class HapticProvider extends ChangeNotifier {
  static HapticProvider? instance;

  bool _enabled = true;

  bool get enabled => _enabled;

  HapticProvider() {
    instance = this; // 👈 GLOBAL ACCESS
    _load();
  }

  Future<void> _load() async {
    _enabled = Webservice.pref.getBool('haptic_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;

    await Webservice.pref.setBool('haptic_enabled', value);
    notifyListeners();
  }
}