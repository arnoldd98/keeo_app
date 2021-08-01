import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoTheme.dart';

class AlarmClock extends StatefulWidget {
  const AlarmClock({Key? key}) : super(key: key);

  @override
  _AlarmClockState createState() => _AlarmClockState();
}

class _AlarmClockState extends State<AlarmClock> {

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Alarm Clock Editor',
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_alarm_rounded, size: 200,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              MaterialButton(minWidth: 100,
                  onPressed: _setAlarm, child: const Text('Set Alarm')),
              MaterialButton(minWidth: 100, onPressed: _eraseAlarm, child: const Text('Reset'))
            ],
            )
          ],
        ),
      ),
    );
  }

  void _setAlarm() {
    print('Set Alarm button pressed');
  }

  void _eraseAlarm() {
    print('Erase Alarm button pressed');
  }
}