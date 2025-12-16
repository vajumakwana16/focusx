import 'package:flutter/material.dart';
import 'package:focusx/utils/webservice.dart';

import '../services/haptic_service.dart';
import '../utils/update_manager.dart';

class DashboardProvider extends ChangeNotifier {
  static DashboardProvider? instance;

  late final PageController pageController;
  int _index = 0;

  int get index => _index;

  DashboardProvider() {
    pageController = PageController(initialPage: 0);
    instance = this;
    Future.delayed(Duration(seconds: 3)).then((v){
      UpdateManager.checkForUpdate();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> setIndex(int i) async {
    _index = i;
    HapticService.tap();
    pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic, // 🔥 smooth slide
    );
    notifyListeners();
  }

}