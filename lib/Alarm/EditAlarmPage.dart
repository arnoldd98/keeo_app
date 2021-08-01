import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoTheme.dart';

class EditAlarmPage extends StatefulWidget {
  const EditAlarmPage({Key? key}) : super(key: key);

  @override
  _EditAlarmPageState createState() => _EditAlarmPageState();
}

class _EditAlarmPageState extends State<EditAlarmPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: KeeoTheme.keeoAppBar(),
    body: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Hero(
              tag: KeeoTheme.ALARM_CLOCK_ICON_HERO_TAG,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Icon(
                  Icons.access_alarm_rounded,
                  size: 150,
                ),
              ),
            ),

          ],
        ),
      ),
    ),);
  }
}
