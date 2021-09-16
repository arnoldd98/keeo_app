import 'package:flutter/material.dart';

import 'KeeoTheme.dart';

class AlarmPage extends StatefulWidget {
  static const String routeName = '/alarmPage';
  String? selectedAlarmPayload;

  AlarmPage(this.selectedAlarmPayload, {Key? key}) : super(key: key);

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KeeoTheme.keeoAppBar(),
      body: Container(
        child: Center(
          child: Text('Joey Stinks', style: TextStyle(fontSize: 22),),
        ),
      ),
    );
  }
}
