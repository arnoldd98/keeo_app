import 'package:flutter/material.dart';

class KeeoTheme {
  static BoxDecoration borderDecoration = BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.brown, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(10)),
      boxShadow: [
        BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(3, 3))
      ]);
  static const String keeoTitle = 'Keeo';
}
