import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';
import 'package:keeo_app/SleepJournal/SleepDataManager.dart';
import 'package:keeo_app/SleepJournal/SleepJournalList.dart';

class SleepJournalEntryEditor extends StatefulWidget {
  SleepJournalEntry journalEntry;
  String _editedJournalTitle = '';
  String _editedJournalEntry = '';
  int _wordCount = 0;
  bool _showKeyboardAttachable = false;

  SleepJournalEntryEditor(this.journalEntry) {
    _wordCount = journalEntry.entry.split(RegExp('[\n\r ]+')).length;
    _editedJournalTitle = journalEntry.title;
    _editedJournalEntry = journalEntry.entry;
  }

  @override
  _SleepJournalEntryEditorState createState() =>
      _SleepJournalEntryEditorState();
}

class _SleepJournalEntryEditorState extends State<SleepJournalEntryEditor> {
  late FocusNode _node;
  late TextEditingController _titleController;
  late TextEditingController _editingController;

  @override
  Widget build(BuildContext context) {
    void _listener() {
      setState(() {
        widget._showKeyboardAttachable = _node.hasFocus;
      });
    }

    _node.addListener(_listener);

    return Stack(children: [
      Hero(
        tag: KeeoTheme.SLEEP_JOURNAL_HERO_TAG,
        child: Card(
          child: Container(
            padding:
                const EdgeInsets.only(top: 12, right: 16, left: 16, bottom: 16),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: KeeoTheme.borderDecoration,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                TextField(
                    controller: this._titleController,
                    style: Theme.of(context).textTheme.headline4,
                    maxLength: 80,
                    decoration: InputDecoration(
                        hintText: 'Title...',
                        helperText: widget._editedJournalTitle.length < 50
                            ? 'Make your title short and sweet'
                            : 'Hey chill out',
                        border: null),
                    onChanged: (text) {
                      widget._editedJournalTitle = text;
                    }),
                _journalEntryEditTextField()
              ],
            ),
          ),
        ),
      ),
      _keyboardAttachable()
    ]);
  }

  Widget _journalEntryEditTextField() {
    return TextField(
      controller: this._editingController,
      onSubmitted: (updatedEntry) {
        Navigator.pop(context, updatedEntry);
      },
      onTap: () {
        setState(() => widget._showKeyboardAttachable = true);
      },
      onChanged: (text) {
        widget._editedJournalEntry = text;
        if (text.endsWith(' ') || text.endsWith('\n')) {
          setState(() =>
              widget._wordCount = text.split(RegExp('[\n\r ]+')).length - 1);
        }
      },
      style: Theme.of(context).textTheme.bodyText1,
      decoration: new InputDecoration(
          border: InputBorder.none,
          hintText: 'Craft a story of your dreams...'),
      focusNode: _node,
      textInputAction: TextInputAction.newline,
      maxLines: null,
    );
  }

  Widget _keyboardAttachable() {
    return Visibility(
        visible: widget._showKeyboardAttachable,
        child: Positioned(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 0,
          right: 0,
          child: Container(
              height: 45,
              decoration:
                  BoxDecoration(color: Theme.of(context).primaryColorLight),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  RichText(
                      text: new TextSpan(
                    children: <TextSpan>[
                      new TextSpan(
                          text: 'Word Count: ',
                          style: new TextStyle(fontWeight: FontWeight.bold)),
                      new TextSpan(text: widget._wordCount.toString())
                    ],
                  )),
                  IconButton(
                    icon: Icon(Icons.done),
                    onPressed: () {
                      setState(() {
                        widget._showKeyboardAttachable = false;
                      });
                      if (widget.journalEntry.title == '' && widget.journalEntry.entry == '') {
                        SleepJournalEntry newEntry = SleepJournalEntry(
                          createdTimestamp: DateTime.now(),
                          lastEditedTimestamp: DateTime.now(),
                          title: widget._editedJournalTitle,
                          entry: widget._editedJournalEntry,
                          sleepMetric: widget.journalEntry.sleepMetric
                        );
                        SleepDBHelper.insert(newEntry);
                        print('new entry: ${newEntry.toString()}');
                        Navigator.pop(context, newEntry);
                      } else {
                        SleepJournalEntry updatedEntry = widget.journalEntry
                            .createUpdatedJournalEntry(
                            newTitle: widget._editedJournalTitle,
                            newEntry: widget._editedJournalEntry);
                        updatedEntry.lastEditedTimestamp = DateTime.now();
                        SleepDBHelper.update(updatedEntry);
                        print('updated entry: ${updatedEntry.toString()}');
                        Navigator.pop(context, updatedEntry);
                      }
                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              )),
        ));
  }

  @override
  void initState() {
    super.initState();
    this._titleController =
        TextEditingController(text: widget._editedJournalTitle);
    this._editingController =
        TextEditingController(text: widget._editedJournalEntry);
    this._node = new FocusNode();
  }

  @override
  void dispose() {
    this._titleController.dispose();
    this._editingController.dispose();
    this._node.dispose();
    super.dispose();
  }
}
