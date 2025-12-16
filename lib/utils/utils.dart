import 'package:flutter/material.dart';

class Utils {
  static GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  static Size size = MediaQuery.sizeOf(navKey.currentContext!);

  static const String appVersion = "1.0.8";

  static showMSG({required String msg}) {
    SnackBar snackBar = SnackBar(
      content: Text(msg),
      showCloseIcon: true,
      margin: EdgeInsets.all(10).copyWith(bottom: 20),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Theme.of(navKey.currentContext!).primaryColorDark,
    );
    ScaffoldMessenger.of(navKey.currentContext!).showSnackBar(snackBar);
  }

  static showProgressDialog() {
    showDialog(
      context: navKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx) {
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  static closeProgressDialog() {
    Navigator.pop(navKey.currentContext!);
  }
}
