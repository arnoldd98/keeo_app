import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeo_app/KeeoPages.dart';
import 'package:keeo_app/KeeoTheme.dart';

class SleepJournalEntryCard extends StatefulWidget {
  String journalEntry;

  SleepJournalEntryCard({required this.journalEntry});

  @override
  _SleepJournalEntryCardState createState() => _SleepJournalEntryCardState();
}

class _SleepJournalEntryCardState extends State<SleepJournalEntryCard> {
  bool _isEditingText = false;
  TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: KeeoTheme.SLEEP_JOURNAL_HERO_TAG,
      child: Card(
        // clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _editTextField(),
              ),
            )),
      ),
    );
  }

  Widget _editTextField() {
    TextField _journalEntryTextField = TextField(
      onSubmitted: (updatedEntry) {
        setState(() {
          widget.journalEntry = updatedEntry;
          _isEditingText = false;
        });
      },
      textInputAction: TextInputAction.done,
      controller: _editingController,
      maxLines: null,
    );
    if (_isEditingText)
      return Center(
        child: _journalEntryTextField,
      );
    else
      return InkWell(
        onTap: () async {
          final editedJournalEntry = await Navigator.push(
              context,
              OpenPageRoute(
                builder: (context) {
                  return Scaffold(
                    appBar: KeeoTheme.keeoAppBar(),
                    body: SleepJournalPage(widget.journalEntry),
                  );
                },
                fullScreenDialog: true,
              ));
          setState(() {
            widget.journalEntry = editedJournalEntry;
          });
        },
        child: Text(
          widget.journalEntry,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.journalEntry);
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }
}

class SleepJournalPage extends StatefulWidget {
  String journalEntry;
  String _editedJournalEntry = '';
  int _wordCount = 0;
  bool _showKeyboardAttachable = false;
  TextEditingController _editingController = TextEditingController();

  SleepJournalPage(this.journalEntry) {
    _wordCount = journalEntry.split(RegExp('[\n\s]+')).length;
    _editedJournalEntry = journalEntry;
  }

  @override
  _SleepJournalPageState createState() => _SleepJournalPageState();
}

class _SleepJournalPageState extends State<SleepJournalPage> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Hero(
        tag: KeeoTheme.SLEEP_JOURNAL_HERO_TAG,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: KeeoTheme.borderDecoration,
            height: MediaQuery.of(context).size.height,
            child: TextField(
              controller: widget._editingController,
              onSubmitted: (updatedEntry) {
                Navigator.pop(context, updatedEntry);
              },
              onTap: () {
                setState(() => widget._showKeyboardAttachable = true);
              },
              onChanged: (text) {
                widget._editedJournalEntry = text;
                if (text.endsWith(' ') || text.endsWith('\n')) {
                  print(text.split(RegExp('[\n\r ]+')));
                  setState(() => widget._wordCount =
                      text.split(RegExp('[\n\r ]+')).length - 1);
                }
              },
              focusNode: _checkKeyboardFocusNode(),
              textInputAction: TextInputAction.newline,
              maxLines: null,
            ),
          ),
        ),
      ),
      _keyboardAttachable(widget._showKeyboardAttachable)
    ]);
  }

  Widget _keyboardAttachable(bool isVisible) {
    return Visibility(
        visible: isVisible,
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
              child: Row(children: [
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
                Navigator.pop(context, widget._editedJournalEntry);
                  },
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceBetween,)),
        ));
  }

  FocusNode _checkKeyboardFocusNode() {
    FocusNode node = new FocusNode();
    void _listener() {
      setState(() {
        widget._showKeyboardAttachable = node.hasFocus;
      });
    }

    node.addListener(_listener);
    return node;
  }

  @override
  void initState() {
    super.initState();
    widget._editingController =
        TextEditingController(text: widget.journalEntry);
  }

  @override
  void dispose() {
    widget._editingController.dispose();
    super.dispose();
  }
}
