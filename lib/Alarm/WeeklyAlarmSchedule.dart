import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> months = [
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

const List<String> days = [
  'day0',
  'Mon',
  'Tues',
  'Wed',
  'Thurs',
  'Fri',
  'Sat',
  'Sun'
];

// wrapper class for Shared Pref containing the saved alarms for the week
class WeeklyAlarms {
  static SharedPreferences? prefs;
  static const String _PREF_ALARM_LIST_KEY = 'Alarms';

  static Future<Map<int, List<DateTime>>> fetchCurrentWeekAlarms() async {
    prefs ??= await SharedPreferences.getInstance();
    String weekAlarmsJSON = (prefs!.getString(_PREF_ALARM_LIST_KEY) ?? '');

    Map<int, List<DateTime>> currentWeekAlarms = {};
    weekAlarmsJSON.isEmpty
        ? currentWeekAlarms = await startNewWeek()
        : currentWeekAlarms = _parseAlarmJSON(weekAlarmsJSON);

    return currentWeekAlarms;
  }

  static Future<Map<int, List<DateTime>>> startNewWeek() async {
    prefs ??= await SharedPreferences.getInstance();
    Map<int, List<DateTime>> emptyAlarms = {
      0: [],
      1: [],
      2: [],
      3: [],
      4: [],
      5: [],
      6: []
    };
    await prefs!
        .setString(_PREF_ALARM_LIST_KEY, _convertAlarmsToJSON(emptyAlarms));
    return emptyAlarms;
  }

  static Future<Map<int, List<DateTime>>> startNewWeekWithExistingSchedule(
      Map<int, List<DateTime>> alarms) async {
    prefs ??= await SharedPreferences.getInstance();

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime startOfWeek =
    DateTime.now().subtract(Duration(days: today.weekday - 1));

    Map<int, List<DateTime>> newWeekAlarms = {};
    alarms.forEach((int day, List<DateTime> dayAlarms) {
      DateTime currentDay = startOfWeek.add(Duration(days: day));
      newWeekAlarms.putIfAbsent(day, () {
        List<DateTime> newDayAlarms = [];
        dayAlarms.forEach((DateTime alarm) =>
            newDayAlarms.add(DateTime(
                currentDay.year,
                currentDay.month,
                currentDay.day,
                alarm.hour,
                alarm.minute)));
        newDayAlarms.sort();
        return newDayAlarms;
      });
    });

    await prefs!
        .setString(_PREF_ALARM_LIST_KEY, _convertAlarmsToJSON(newWeekAlarms));
    return newWeekAlarms;
  }

  static addSingleAlarm(int day, TimeOfDay alarmTime) async {
    prefs ??= await SharedPreferences.getInstance();

    Map<int, List<DateTime>> currentAlarms = await fetchCurrentWeekAlarms();
    List<DateTime> dayAlarms = currentAlarms[day] ?? [];
    DateTime date = getDateForCurrentWeek(day);
    DateTime alarm = DateTime(
        date.year, date.month, date.day, alarmTime.hour, alarmTime.minute);
    if (dayAlarms.isEmpty) {
      dayAlarms.add(alarm);
      currentAlarms.putIfAbsent(day, () => dayAlarms);
    } else {
      dayAlarms.add(alarm);
      dayAlarms.sort();
      currentAlarms[day] = dayAlarms;
    }
    await prefs!
        .setString(_PREF_ALARM_LIST_KEY, _convertAlarmsToJSON(currentAlarms));
  }

  static editSingleAlarm(int day, DateTime oldAlarm,
      TimeOfDay newAlarmTime) async {
    Map<int, List<DateTime>> currentAlarms = await fetchCurrentWeekAlarms();

    List<DateTime> dayAlarms = currentAlarms[day] ?? [];
    if (dayAlarms.isEmpty || !dayAlarms.contains(oldAlarm)) {
      throw new Exception("Specified day does not contain any alarms");
    } else {
      dayAlarms.remove(oldAlarm);
      DateTime date = getDateForCurrentWeek(day);
      DateTime newAlarm = DateTime(
          date.year, date.month, date.day, newAlarmTime.hour, newAlarmTime.minute);
      dayAlarms.add(newAlarm);
      currentAlarms[day] = dayAlarms;
    }

    await prefs!
        .setString(_PREF_ALARM_LIST_KEY, _convertAlarmsToJSON(currentAlarms));
  }

  static Future<DateTime> getNextUpcomingAlarm() async {
    Map<int, List<DateTime>> currentAlarms = await fetchCurrentWeekAlarms();

    DateTime currentDate = DateTime.now();
    DateTime startOfWeek = getDateForCurrentWeek(0);
    int today = currentDate.day - startOfWeek.day;

    List<DateTime?> nextAlarms = [];
    currentAlarms.forEach((int day, List<DateTime> dayAlarms) {
      if (day >= today) {
        dayAlarms.forEach((alarm) => nextAlarms.add(alarm));
      } else {
        dayAlarms.forEach((alarm) =>
            nextAlarms.add(alarm.add(Duration(days: 7))));
      }
    });
    if (nextAlarms.length == 0) {
      startNewWeek();
      return DateTime(DateTime
          .now()
          .year);
    } else {
      nextAlarms.sort();
      return nextAlarms[0]!;
    }
  }

  static _convertAlarmsToJSON(Map<int, List<DateTime>> alarms) {
    Map<String, List<String>> parseableAlarms = {};
    alarms.forEach((day, datetimes) {
      List<String> strList =
      datetimes.map((DateTime e) => e.toString()).toList();
      parseableAlarms.putIfAbsent(day.toString(), () => strList);
    });
    return jsonEncode(parseableAlarms);
  }

  static Map<int, List<DateTime>> _parseAlarmJSON(String jsonString) {
    Map<String, dynamic> parsed = jsonDecode(jsonString);
    Map<int, List<DateTime>> alarms = {};
    parsed.forEach((dayStr, value) {
      List<dynamic> datetimeStrList = value;
      List<DateTime> datetimeList =
      datetimeStrList.map((str) => DateTime.parse(str.toString())).toList();
      alarms.putIfAbsent(int.parse(dayStr), () => datetimeList);
    });
    return alarms;
  }

  static DateTime getDateForCurrentWeek(int day) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime startOfWeek =
    DateTime.now().subtract(Duration(days: today.weekday - 1));
    return startOfWeek.add(Duration(days: day));
  }

  static Map<int, List<DateTime>> getEmptyWeek() {
    return {0: [], 1: [], 2: [], 3: [], 4: [], 5: [], 6: []};
  }
}
