import 'package:flutter/material.dart';
import 'package:keeo_app/Alarm/UpcomingAlarmsCard.dart';
import 'package:keeo_app/Alarm/WeeklyAlarmSchedule.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'package:keeo_app/main.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

class AlarmEditor extends StatefulWidget {
  DateTime _currentWeekMonday =
  DateTime.now().subtract(Duration(days: DateTime
      .now()
      .weekday - 1));

  AlarmEditor({Key? key}) : super(key: key);

  @override
  _AlarmEditorState createState() => _AlarmEditorState();
}

class _AlarmEditorState extends State<AlarmEditor> {
  List<bool> _daySettings = [false, false];
  int currentDay = DateTime
      .now()
      .weekday - 1;
  Future<DateTime> _nextUpcomingAlarm = WeeklyAlarms.getNextUpcomingAlarm();
  Map<int, List<DateTime>> _alarms = WeeklyAlarms.getEmptyWeek();
  ScrollController controller = new ScrollController();
  GlobalKey _dayTileKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: FutureBuilder(
                  future: _nextUpcomingAlarm,
                  builder:
                      (BuildContext context, AsyncSnapshot<DateTime> snapshot) {
                    if (snapshot.hasData) {
                      return UpcomingAlarmsCard(
                        alarmDateTime: snapshot.data!,
                        onTapFunction: setAlarmTime,
                      );
                    } else if (snapshot.hasError) {
                      return UpcomingAlarmsCard(
                        alarmDateTime: DateTime.now(),
                        onTapFunction: setAlarmTime,
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [buildAlarmSettings(context)],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _alarms.length,
                  controller: this.controller,

                  itemBuilder: (context, index) {
                    if (index != 0)
                      return _buildCalendarDayTile(index, _alarms[index]!);
                    return _buildCalendarDayTile(
                        index, _alarms[index]!, key: _dayTileKey);
                  }),
            ),
          ],
        ));
  }

  ToggleButtons buildAlarmSettings(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.all(Radius.circular(5)),
      borderColor: Theme
          .of(context)
          .primaryColor,
      borderWidth: 1.25,
      selectedBorderColor: Theme
          .of(context)
          .primaryColor,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Daily',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Weekdays Only',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
      isSelected: _daySettings,
      onPressed: (int index) {
        setState(() {
          for (int i = 0; i < _daySettings.length; i++) {
            _daySettings[i] = i == index;
          }
        });
      },
    );
  }

  Widget _buildCalendarDayTile(int day, List<DateTime> dayAlarms, {Key? key}) {
    DateTime currentDate = widget._currentWeekMonday.add(
      Duration(
        days: day,
      ),
    );
    BoxDecoration boxDecoration = this.currentDay == day
        ? KeeoTheme.selectedBorderDecoration
        : KeeoTheme.borderDecoration;

    return AspectRatio(
      aspectRatio: 1,
      key: key ?? null,
      child: InkWell(
        onTap: () => setSelectedDay(day),
        child: Container(
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.all(4),
          decoration: boxDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    days[day + 1].toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 22),
                  ),
                  Spacer(),
                  Text('${currentDate.month}/${currentDate.day}'),
                ],
              ),
              for (DateTime alarm in dayAlarms) _buildCalendarDayRow(alarm)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarDayRow(DateTime alarm) {
    final DateFormat formatter = DateFormat('hh:mm a');
    final String formattedAlarmTime = formatter.format(alarm);
    return InkWell(
      onTap: () => setAlarmTime(oldAlarmTime: alarm),
      child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(6),
          margin: EdgeInsets.only(top: 8),
          decoration: KeeoTheme.borderDecorationShaded,
          child: Text(
            'Next alarm: $formattedAlarmTime',
            style: TextStyle(fontSize: 12),
          )),
    );
  }

  void setSelectedDay(int day) {
    setState(() {
      this.currentDay = day;
    });
  }

  void setAlarmTime({oldAlarmTime}) {
    Future<TimeOfDay?> selectedTimeFuture =
    showTimePicker(context: context, initialTime: TimeOfDay.now());
    selectedTimeFuture.then((newTimeValue) {
      if (newTimeValue == null) return;
      if (oldAlarmTime == null) {
        WeeklyAlarms.addSingleAlarm(this.currentDay, newTimeValue).then((_) {
          WeeklyAlarms.fetchCurrentWeekAlarms().then((alarms) {
            setState(() {
              this._alarms = alarms;
            });
          });
        });
      } else {
        WeeklyAlarms.editSingleAlarm(
            this.currentDay, oldAlarmTime, newTimeValue).then((_) {
          WeeklyAlarms.fetchCurrentWeekAlarms().then((alarms) {
            setState(() {
              this._alarms = alarms;
            });
          });
        });
      }
    });
  }

  void _scheduleNextAlarm(DateTime alarmDateTime) async {
    // get local timezone of new alarm date time
    tz.initializeTimeZones();
    var singapore = tz.getLocation('Asia/Singapore');
    tz.TZDateTime alarmNotificationDateTime = tz.TZDateTime(
        singapore,
        alarmDateTime.year,
        alarmDateTime.month,
        alarmDateTime.day,
        alarmDateTime.hour,
        alarmDateTime.minute);

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

    await flutterLocalNotificationsPlugin.zonedSchedule(0, 'Alarm',
        'Wakey wakey', alarmNotificationDateTime, platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);

    print('Alarm scheduled on $alarmNotificationDateTime');
  }

  @override
  initState() {
    WeeklyAlarms.fetchCurrentWeekAlarms().then((alarms) {
      setState(() {
        this._alarms = alarms;

        // gets width of Calendar Day tile on screen and scrolls to the current day tile
        final RenderBox renderBox = _dayTileKey.currentContext!
            .findRenderObject()! as RenderBox;
        this.controller.jumpTo((this.currentDay) * renderBox.size.width);
      });
    });
  }
}
