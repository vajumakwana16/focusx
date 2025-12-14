import 'package:flutter/material.dart';

/// CONTEXT EXTENSIONS

extension ContextExt on BuildContext {

  double get h =>
      MediaQuery
          .of(this)
          .size
          .height;

  double get w =>
      MediaQuery
          .of(this)
          .size
          .width;

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme =>
      Theme
          .of(this)
          .textTheme;

  void next(Widget page) =>
      Navigator.push(this, MaterialPageRoute(builder: (_) => page));

  void back() => Navigator.pop(this);

}

/// STRING VALIDATORS
extension StringValidators on String {
  bool get isEmail => RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(this);

  bool get isNum => double.tryParse(this) != null;

  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}


/// DATE/TIME FORMATTER
extension DateExt on DateTime {
  String get ymd => "$year-$month-$day";

  String get hms => "$hour: $minute: $second";
}


/// WIDGET PADDING EXTENSIONS
extension PaddingExt on Widget {
  Widget padAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget padSym({double h = 0, double v = 0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
          child: this);
}


/// QUICK SIZED BOX EXTENSIONS
extension IntSizedBox on int {
  SizedBox get h => SizedBox(height: toDouble());

  SizedBox get w => SizedBox(width: toDouble());
}

/// NULLABLE / BLANK STRING EXTENSIONS
extension NullableStringExt on String? {

  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String get orEmpty => this ?? "";

  String get capitalizeSafe =>
      (this != null && this !.isNotEmpty)
          ? '${this![0].toUpperCase()}${this!.substring(1)}'
          : "";

}