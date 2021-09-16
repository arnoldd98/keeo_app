import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepJournalEntryPage.dart';
import 'package:keeo_app/SleepJournal/SleepMetricsPage.dart';
import 'package:keeo_app/ToDoList.dart';
import 'package:keeo_app/Alarm/UpcomingAlarmsCard.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'Alarm/WeeklyAlarmSchedule.dart';
import 'AlarmPage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
String? selectedNotificationPayload;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUpAlarmNotifications();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    print('Launched from alarm notification');
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    initialRoute = AlarmPage.routeName;
  }
  runApp(MaterialApp(
    title: 'Keeo',
    theme: ThemeData(
        primarySwatch: Colors.brown, primaryColorLight: Colors.brown[120]),
    // home: HomePage(),
    initialRoute: initialRoute,
    routes: <String, WidgetBuilder>{
      HomePage.routeName: (_) => HomePage(),
      AlarmPage.routeName: (_) => AlarmPage(selectedNotificationPayload)
    },
  ));
}

void setUpAlarmNotifications() async {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('keeo_test_logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });
}

void scheduleTestAlarm() async {
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_notif', 'alarm_notif', 'Channel for Alarm notificaitons',
      icon: 'keeo_test_logo',
      sound: RawResourceAndroidNotificationSound('a_long_cold_sting'),
      largeIcon: DrawableResourceAndroidBitmap('keeo_test_logo'));

  var iOSPlatformChannelSpecifics = IOSNotificationDetails(
      sound: 'a_long_cold_sting.wav',
      presentAlert: true,
      presentBadge: true,
      presentSound: true);

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  tz.initializeTimeZones();
  var singapore = tz.getLocation('Asia/Singapore');
  tz.TZDateTime zonedNotificationDateTime =
      tz.TZDateTime.now(singapore).add(Duration(seconds: 10));

  await flutterLocalNotificationsPlugin.zonedSchedule(0, 'Alarm', 'Wakey Wakey',
      zonedNotificationDateTime, platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true);
  print('TestAlarm is scheduled 10 seconds from now');
}

class HomePage extends StatefulWidget {
  static const String routeName = '/';
  late SleepJournalEntry _todaysEntry;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime nextUpcomingAlarm = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KeeoTheme.keeoAppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
          child: Column(
        children: [
          Flexible(
            flex: 1,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 16, bottom: 4, right: 8, left: 8),
              child: UpcomingAlarmsCard(alarmDateTime: this.nextUpcomingAlarm),
            ),
          ),
          Flexible(
            flex: 3,
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 8, right: 8, bottom: 12, top: 16),
                child: KeeoPages(titles: [
                  'To-Dos',
                  'Sleep Journal',
                  'Sleep Metrics',
                  ''
                ], children: [
                  SleepJournalEntryPage(),
                  SleepMetricsPage.withSampleData(),
                  Center(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: scheduleTestAlarm,
                        child: Text('Schedule alarm'),
                      ),
                      ElevatedButton(
                          onPressed: _showFullScreenNotification,
                          child: Text('Full-screen alarm')),
                      ElevatedButton(
                          onPressed: () => SleepDBHelper.clearDatabase(),
                          child: Text('Clear database')),
                      ElevatedButton(
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.clear();
                        },
                        child: Text('Clear alarms'),
                      )
                    ],
                  ))
                ])),
          ),
        ],
      )),
    );
  }

  Future<void> _showFullScreenNotification() async {
    tz.initializeTimeZones();
    var time = tz.TZDateTime.now(tz.getLocation('Asia/Singapore'))
        .add(const Duration(seconds: 10));
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Turn off your screen'),
        content: const Text(
            'to see the full-screen intent in 10 seconds, press OK and TURN '
            'OFF your screen'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await flutterLocalNotificationsPlugin.zonedSchedule(
                  0,
                  'Full-screen alarm',
                  'Full-screen alarm which shows',
                  time,
                  const NotificationDetails(
                      android: AndroidNotificationDetails(
                          'full screen channel id',
                          'full screen channel name',
                          'full screen channel description',
                          priority: Priority.high,
                          importance: Importance.high,
                          fullScreenIntent: true)),
                  androidAllowWhileIdle: true,
                  uiLocalNotificationDateInterpretation:
                      UILocalNotificationDateInterpretation.absoluteTime);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    setState(() {
      SleepDBHelper.getTodaysData().then((SleepJournalEntry entry) {
        widget._todaysEntry = entry;
      });
      WeeklyAlarms.getNextUpcomingAlarm()
          .then((DateTime? datetime) => this.nextUpcomingAlarm = datetime!);
    });
    SleepDBHelper.getTodaysData().then((SleepJournalEntry entry) {
      setState(() {
        widget._todaysEntry = entry;
      });
    });
    WeeklyAlarms.getNextUpcomingAlarm().then((DateTime? datetime) {
      setState(() {
        this.nextUpcomingAlarm = datetime!;
      });
    });
  }
}
