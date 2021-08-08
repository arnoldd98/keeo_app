import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoTheme.dart';

class UpcomingAlarmsCard extends StatefulWidget {
  DateTime alarmDateTime;

  UpcomingAlarmsCard({required this.alarmDateTime});

  @override
  _UpcomingAlarmsCardState createState() => _UpcomingAlarmsCardState();
}

class _UpcomingAlarmsCardState extends State<UpcomingAlarmsCard> {
  @override
  Widget build(BuildContext context) {
    const List<String> _months = [
      'month0',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    const List<String> _days = [
      'day0',
      'Mon',
      'Tues',
      'Wed',
      'Thurs',
      'Fri',
      'Sat',
      'Sun'
    ];

    BoxDecoration borderDecoration = BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Theme.of(context).accentColor, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(3, 3))
        ]);

    return Container(
        width: double.infinity,
        decoration: borderDecoration,
        child: LimitedBox(
          maxHeight: MediaQuery.of(context).size.height * 0.225,
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
                              style: Theme.of(context).textTheme.headline6),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
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
                          Hero(
                            tag: KeeoTheme.ALARM_CLOCK_ICON_HERO_TAG,
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Icon(
                                Icons.access_alarm_rounded,
                                size: 100,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Future<TimeOfDay?> selectedTimeFuture = showTimePicker(
                            context: context, initialTime: TimeOfDay.now());
                        selectedTimeFuture.then((newTimeValue) {
                          if (newTimeValue == null)
                            return;
                          else
                            newTimeValue = newTimeValue;
                          DateTime newAlarmTime =
                              _handleSelectAlarmTime(newTimeValue);
                          setState(() {
                            widget.alarmDateTime = newAlarmTime;
                          });
                        });
                      }),
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        _days[widget.alarmDateTime.weekday] +
                            ', ' +
                            (widget.alarmDateTime.day < 10
                                ? '0' + widget.alarmDateTime.day.toString()
                                : widget.alarmDateTime.day.toString()) +
                            ' ' +
                            _months[widget.alarmDateTime.month],
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  DateTime _handleSelectAlarmTime(TimeOfDay newTimeValue) {
    double doubleNewTime =
        newTimeValue.hour.toDouble() + (newTimeValue.minute.toDouble() / 60);
    double doubleNowTime = TimeOfDay.now().hour.toDouble() +
        (TimeOfDay.now().minute.toDouble() / 60);
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
