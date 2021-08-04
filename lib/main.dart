import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournalEntry.dart';
import 'package:keeo_app/SleepMetricsPage.dart';
import 'package:keeo_app/ToDoList.dart';
import 'package:keeo_app/Alarm/UpcomingAlarmsCard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        primaryColorLight: Colors.brown[120]
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: KeeoTheme.keeoAppBar(),
        resizeToAvoidBottomInset: false,
        body: Center(
            child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16, bottom: 4, right: 8, left: 8),
                child: UpcomingAlarmsCard(alarmDateTime: DateTime.now()),
              ),
            ),
            Flexible(
              flex: 3,
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
                      'Wash the dishes': false,
                      'Cooke the rice': true,
                      'Doe pull-ups': true,
                      'Staert deployment': false,
                      'Waseh the dishes': false,
                      'Cooak the rice': true,
                      'Doa pull-ups': true,
                      'Staart deployment': false,
                      'Waash the dishes': false,
                      'Coxok the rice': true,
                      'Dxo pull-ups': true,
                      'Stxart deployment': false,
                      'Waxsh the dishes': false,
                      'Cocok the rice': true,
                      'Dov pull-ups': true,
                      'Stavrt deployment': false,
                      'Washv the dishes': false,
                      'Coomk the rice': true,
                      'Do pmull-ups': true,
                      'Startm deployment': false,
                      'Wash tmhe dishes': false,
                    }),
                    SleepJournalEntryCard(journalEntry: 'journalEntry'),
                    SleepMetricsPage.withSampleData(),
                    Center(child: Text('End of Page'))
                  ])),
            ),
          ],
        )),
    );
  }
}
