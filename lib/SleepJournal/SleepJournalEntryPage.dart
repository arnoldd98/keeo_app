import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';
import 'package:keeo_app/SleepJournal/SleepJournalList.dart';
import 'package:keeo_app/SleepJournal/SleepJournalEntryEditor.dart';

class SleepJournalEntryPage extends StatefulWidget {
  SleepJournalEntry journalEntry;

  SleepJournalEntryPage({required this.journalEntry});

  @override
  _SleepJournalEntryPageState createState() => _SleepJournalEntryPageState();
}

class _SleepJournalEntryPageState extends State<SleepJournalEntryPage> {
  @override
  Widget build(BuildContext context) {
    if (SleepJournalEntry.checkIsNullEntry(widget.journalEntry)) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('You have not yet created an entry for today!'),
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
                if (details.primaryVelocity! < 0) {
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
              },
              behavior: HitTestBehavior.translucent,
              onTap: _openJournalEditor,
              child: Column(
                children: [
                  Text(widget.journalEntry.title,
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
              body: SleepJournalEntryEditor(widget.journalEntry),
            );
          },
          fullScreenDialog: true,
        ));
    print('edited journal entry: $editedJournalEntry');
    setState(() {
      widget.journalEntry = editedJournalEntry;
    });
  }

  Widget _journalEntryText() {
    return Text(
      widget.journalEntry.entry,
      style: Theme.of(context).textTheme.bodyText1,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
