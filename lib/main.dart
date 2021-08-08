import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepJournalEntryPage.dart';
import 'package:keeo_app/SleepJournal/SleepMetricsPage.dart';
import 'package:keeo_app/ToDoList.dart';
import 'package:keeo_app/Alarm/UpcomingAlarmsCard.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.brown, primaryColorLight: Colors.brown[120]),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  SleepJournalEntry _todaysEntry = new SleepJournalEntry();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              child: UpcomingAlarmsCard(alarmDateTime: DateTime.now()),
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
                  ToDoList(toDoMap: {
                    'Cook the rice': true,
                    'Do pull-ups': true,
                    'Start deployment': false,
                  }),
                  SleepJournalEntryPage(journalEntry: widget._todaysEntry),
                  SleepMetricsPage.withSampleData(),
                  Center(
                      child: ElevatedButton(
                          onPressed: () => SleepDBHelper.clearDatabase(),
                          child: Text('Clear database')))
                ])),
          ),
        ],
      )),
    );
  }

  @override
  void initState() {
    SleepDBHelper.getTodaysData().then((SleepJournalEntry entry) {
      setState(() => widget._todaysEntry = entry);
      print('todays entry; ' + entry.toString());
    });
  }
}
