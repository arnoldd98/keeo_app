import 'package:flutter/material.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';

class SleepJournalEntriesList extends StatefulWidget {
  const SleepJournalEntriesList({Key? key}) : super(key: key);

  @override
  _SleepJournalEntriesListState createState() =>
      _SleepJournalEntriesListState();
}

class _SleepJournalEntriesListState extends State<SleepJournalEntriesList> {
  List<SleepJournalEntry> _entryList = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8),
        itemCount: _entryList.length,
        itemBuilder: (context, index) {
          SleepJournalEntry currentEntry = _entryList[index];

          if (currentEntry.checkCreatedToday()) {
            return Hero(
              tag: KeeoTheme.SLEEP_JOURNAL_HERO_TAG,
              child: sleepJournalListTile(currentEntry),
            );
          }
          return sleepJournalListTile(currentEntry);
        });
  }

  Widget sleepJournalListTile(SleepJournalEntry currentEntry) {
    return ListTile(
        enabled: true,
        title: Container(
          decoration: KeeoTheme.borderDecorationWithShadow,
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          margin: EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentEntry.title,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Spacer(),
                  Text(
                    currentEntry.createdTimestamp.toString().substring(0, 10),
                    style: Theme.of(context).textTheme.bodyText2,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  currentEntry.entry,
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ));
  }

  @override
  void initState() {
    SleepDBHelper.getData().then((List<SleepJournalEntry> entries) {
      setState(() => this._entryList = entries);
    });
  }
}
