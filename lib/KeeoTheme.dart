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

  static PreferredSizeWidget keeoAppBar() {
    return AppBar(
      title: const Text(KeeoTheme.keeoTitle),
      actions: <Widget>[
        PopupMenuButton(itemBuilder: (BuildContext context) {
          return {'Settings', 'About Keeo'}.map((String choice) {
            return PopupMenuItem<String>(
              child: Text(choice),
              value: choice,
            );
          }).toList();
        })
      ],
    );
  }
  static const String keeoTitle = 'Keeo';
  static const String ALARM_CLOCK_ICON_HERO_TAG = 'Upcoming Alarms Card';
}
