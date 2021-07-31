import 'package:flutter/material.dart';

class UpcomingAlarmsCard extends StatelessWidget {
  final DateTime alarmDateTime;

  const UpcomingAlarmsCard({required this.alarmDateTime});

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
        border: Border.all(color: Theme
            .of(context)
            .accentColor, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(3, 3))
        ]);

    return Container(
        width: double.infinity,
        decoration: borderDecoration,
        child: LimitedBox(
          maxHeight: MediaQuery
              .of(context)
              .size
              .height * 0.225,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16, top: 8, right: 0),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.fitHeight,
                        child: Text(
                          alarmDateTime.hour.toString() +
                              ':' +
                              (alarmDateTime.hour < 10
                                  ? '0' + alarmDateTime.hour.toString()
                                  : alarmDateTime.hour.toString()),
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
                ),
                Flexible(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Text(
                        _days[alarmDateTime.weekday] +
                            ', ' +
                            (alarmDateTime.day < 10
                                ? '0' + alarmDateTime.day.toString()
                                : alarmDateTime.day.toString()) +
                            ' ' +
                            _months[alarmDateTime.month],
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
}
