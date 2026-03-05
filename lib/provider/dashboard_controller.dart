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

  void setIndex(int i) {
    if (_index == i) return;
    _index = i;
    HapticService.tap();
    notifyListeners();

    // Tiny delay to ensure UI rebuilds before PageView animation begins
    Future.delayed(const Duration(milliseconds: 10), () {
      if (pageController.hasClients) {
        pageController.animateToPage(
          i,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

}