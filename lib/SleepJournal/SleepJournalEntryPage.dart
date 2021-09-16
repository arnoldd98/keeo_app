import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';
import 'package:keeo_app/SleepJournal/SleepJournalList.dart';
import 'package:keeo_app/SleepJournal/SleepJournalEntryEditor.dart';

class SleepJournalEntryPage extends StatefulWidget {
  SleepJournalEntry _todaysEntry = SleepJournalEntry();

  @override
  _SleepJournalEntryPageState createState() => _SleepJournalEntryPageState();
}

class _SleepJournalEntryPageState extends State<SleepJournalEntryPage> {
  @override
  Widget build(BuildContext context) {
    if (SleepJournalEntry.checkIsNullEntry(widget._todaysEntry)) {
      return GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) {
          // on drag up
          if (details.primaryVelocity! < 0) _openListOfJournals();
        },
        onTap: _openJournalEditor,
        child: Container(
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          child: Text('You have not yet created an entry for today!'),
        ),
      );
    }
    return Hero(
      tag: KeeoTheme.SLEEP_JOURNAL_HERO_TAG,
      child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                // on drag up
                if (details.primaryVelocity! < 0) _openListOfJournals();
              },
              behavior: HitTestBehavior.translucent,
              onTap: _openJournalEditor,
              child: Column(
                children: [
                  Text(widget._todaysEntry.title,
                      style: Theme.of(context).textTheme.headline5),
                  Container(
                      padding: EdgeInsets.only(top: 8),
                      alignment: Alignment.topLeft,
                      child: _journalEntryText()),
                ],
              ),
            ),
          )),
    );
  }

  void _openJournalEditor() async {
    final editedJournalEntry = await Navigator.push(
        context,
        OpenPageRoute(
          builder: (context) {
            return Scaffold(
              appBar: KeeoTheme.keeoAppBar(),
              body: SleepJournalEntryEditor(widget._todaysEntry),
            );
          },
          fullScreenDialog: true,
        ));
    if (editedJournalEntry != null) {
      setState(() {
        widget._todaysEntry = editedJournalEntry;
      });
    }
  }

  void _openListOfJournals() {
    Navigator.push(
        context,
        OpenPageRoute(
            builder: (context) {
              return Scaffold(
                  appBar: KeeoTheme.keeoAppBar(),
                  body: SleepJournalEntriesList());
            },
            fullScreenDialog: true));
  }

  Widget _journalEntryText() {
    return Text(
      widget._todaysEntry.entry,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  @override
  void initState() {
    SleepDBHelper.getTodaysData().then((SleepJournalEntry entry) {
      setState(() => widget._todaysEntry = entry);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
