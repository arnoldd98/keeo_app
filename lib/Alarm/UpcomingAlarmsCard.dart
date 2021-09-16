import 'package:flutter/material.dart';
import 'package:keeo_app/Alarm/AlarmEditor.dart';
import 'package:keeo_app/Alarm/WeeklyAlarmSchedule.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:keeo_app/main.dart';

import '../KeeoPages.dart';

class UpcomingAlarmsCard extends StatefulWidget {
  DateTime alarmDateTime;
  Function? onTapFunction;
  UpcomingAlarmsCard({required this.alarmDateTime, this.onTapFunction});

  @override
  _UpcomingAlarmsCardState createState() => _UpcomingAlarmsCardState();
}

class _UpcomingAlarmsCardState extends State<UpcomingAlarmsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: KeeoTheme.borderDecorationWithShadow,
        child: Hero(
          tag: KeeoTheme.ALARM_CLOCK_ICON_HERO_TAG,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 4, right: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text('Upcoming Alarm',
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headline6),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Material(
                    child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                widget.alarmDateTime.hour.toString() +
                                    ':' +
                                    (widget.alarmDateTime.minute < 10
                                        ? '0' +
                                        widget.alarmDateTime.minute.toString()
                                        : widget.alarmDateTime.minute.toString()),
                                style: TextStyle(fontSize: 80),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Icon(
                                Icons.access_alarm_rounded,
                                size: 100,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (widget.onTapFunction == null) {
                            await Navigator.push(context, OpenPageRoute(builder: (context) {
                              return Scaffold(
                                  appBar: KeeoTheme.keeoAppBar(),
                                  body: AlarmEditor()
                              );
                            }, fullScreenDialog: true));
                          } else widget.onTapFunction!();
                          // Future<TimeOfDay?> selectedTimeFuture = showTimePicker(
                          //     context: context, initialTime: TimeOfDay.now());
                          // selectedTimeFuture.then((newTimeValue) {
                          //   if (newTimeValue == null)
                          //     return;
                          //   DateTime newAlarmTime =
                          //   _handleSelectAlarmTime(newTimeValue);
                          //   setState(() {
                          //     widget.alarmDateTime = newAlarmTime;
                          //   });
                          //   _scheduleNextAlarm(newAlarmTime);
                          // });
                        }),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        days[widget.alarmDateTime.weekday] +
                            ', ' +
                            (widget.alarmDateTime.day < 10
                                ? '0' + widget.alarmDateTime.day.toString()
                                : widget.alarmDateTime.day.toString()) +
                            ' ' +
                            months[widget.alarmDateTime.month],
                        style: Theme
                            .of(context)
                            .textTheme
                            .headline5,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _scheduleNextAlarm(DateTime alarmDateTime) async {
    // get local timezone of new alarm date time
    tz.initializeTimeZones();
    var singapore = tz.getLocation('Asia/Singapore');
    tz.TZDateTime alarmNotificationDateTime = tz.TZDateTime(
        singapore, alarmDateTime.year, alarmDateTime.month, alarmDateTime.day,
        alarmDateTime.hour, alarmDateTime.minute);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'alarm_notif', 'alarm_notif', 'Channel for Alarm notifications',
        icon: 'keeo_test_logo',
        sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
        largeIcon: DrawableResourceAndroidBitmap('keeo_test_logo'),
        priority: Priority.high,
        importance: Importance.high,
        fullScreenIntent: true);

    var iOSPlatformChannelSpecifics = IOSNotificationDetails(
        sound: 'a_long_cold_sting.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0, 'Alarm', 'Wakey wakey', alarmNotificationDateTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation
            .absoluteTime, androidAllowWhileIdle: true);

    final snackBar = SnackBar(
        content: Text('Alarm scheduled on $alarmNotificationDateTime'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  DateTime _handleSelectAlarmTime(TimeOfDay newTimeValue) {
    double doubleNewTime =
        newTimeValue.hour.toDouble() + (newTimeValue.minute.toDouble() / 60);
    double doubleNowTime = TimeOfDay
        .now()
        .hour
        .toDouble() +
        (TimeOfDay
            .now()
            .minute
            .toDouble() / 60);
    bool isAfterNow = doubleNewTime - doubleNowTime > 0;
    DateTime currentDateTime = DateTime.now();

    if (isAfterNow) {
      return new DateTime(currentDateTime.year, currentDateTime.month,
          currentDateTime.day, newTimeValue.hour, newTimeValue.minute);
    } else {
      DateTime nextDayDateTime = currentDateTime.add(new Duration(days: 1));
      return new DateTime(nextDayDateTime.year, nextDayDateTime.month,
          nextDayDateTime.day, newTimeValue.hour, newTimeValue.minute);
    }
  }
}
