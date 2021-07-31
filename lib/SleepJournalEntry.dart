import 'package:flutter/material.dart';

class SleepJournalEntryPage extends StatefulWidget {
  String journalEntry;

  SleepJournalEntryPage({required this.journalEntry});

  @override
  _SleepJournalEntryPageState createState() => _SleepJournalEntryPageState();
}

class _SleepJournalEntryPageState extends State<SleepJournalEntryPage> {
  bool _isEditingText = false;
  TextEditingController _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _editTextField(),
          ),
        ));
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
        maxLines: null,);
    if (_isEditingText)
      return Center(
        child: _journalEntryTextField,
      );
    else
      return InkWell(
        onTap: () {
          setState(() {
            _isEditingText = true;
            // _dreamJournalTextField.text = widget.journalEntry;
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
