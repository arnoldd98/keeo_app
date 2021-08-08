import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

final String _createdTimestampKey = 'created_datetime';
final String _lastEditedTimestampKey = 'last_modified_datetime';
final String _journalTitleKey = 'journal_title';
final String _journalEntryKey = 'journal_entry';
final String _sleepMetricKey = 'sleep_metric';

// data wrapper class for user's sleep journal for the day
class SleepJournalEntry {
  DateTime? createdTimestamp = DateTime.now();
  DateTime? lastEditedTimestamp;
  late String title;
  late String entry;
  int? sleepMetric;

  SleepJournalEntry(
      {this.createdTimestamp,
        this.lastEditedTimestamp,
        this.title = '',
        this.entry = '',
        this.sleepMetric});

  SleepJournalEntry createUpdatedJournalEntry(
      {String? newTitle, String? newEntry}) {
    if (newTitle == null) newTitle = this.title;
    if (newEntry == null) newEntry = this.entry;
    return new SleepJournalEntry(
        createdTimestamp: this.createdTimestamp,
        title: newTitle,
        entry: newEntry,
        lastEditedTimestamp: DateTime.now());
  }

  SleepJournalEntry.fromMap(Map<String, dynamic> map) {
    createdTimestamp = DateTime.fromMillisecondsSinceEpoch(map[_createdTimestampKey]);
    lastEditedTimestamp =  DateTime.fromMillisecondsSinceEpoch(map[_lastEditedTimestampKey]);
    title = map[_journalTitleKey];
    entry = map[_journalEntryKey];
    sleepMetric =
    map[_sleepMetricKey] != null ? int.parse(map[_sleepMetricKey]) : -1;
  }

  bool checkCreatedToday() {
    var entryDay = DateTime.utc(this.createdTimestamp!.year,
        this.createdTimestamp!.month, this.createdTimestamp!.day);
    var now = DateTime.now();
    var today = DateTime.utc(now.year, now.month, now.day);

    return entryDay.compareTo(today) == 0;
  }

  bool checkSameCreatedDay(SleepJournalEntry entry) {
    var entryDay = DateTime.utc(this.createdTimestamp!.year,
        this.createdTimestamp!.month, this.createdTimestamp!.day);
    var entryDayToCompare = DateTime.utc(entry.createdTimestamp!.year,
        entry.createdTimestamp!.month, entry.createdTimestamp!.day);

    return entryDay.compareTo(entryDayToCompare) == 0;
  }

  @override
  String toString() {
    return '(Created: ${createdTimestamp.toString()}, '
        'Last edited: ${lastEditedTimestamp.toString()})\n'
        'Title: $title\n'
        'Entry: $entry}';
  }

  Map<String, dynamic> toMap() {
    return {
      _lastEditedTimestampKey: this.lastEditedTimestamp!.millisecondsSinceEpoch,
      _createdTimestampKey: this.createdTimestamp!.millisecondsSinceEpoch,
      _journalTitleKey: this.title,
      _journalEntryKey: this.entry,
      _sleepMetricKey: this.sleepMetric
    };
  }

  static bool checkIsNullEntry(SleepJournalEntry entry) {
    return entry.createdTimestamp == null;
  }
}

class SleepDBHelper {
  static final String _tableName = 'sleep_data';

  static Future<Database> _database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'sleepData.db'),
        onCreate: (db, version) async {
      await db.execute('CREATE TABLE $_tableName'
          '($_createdTimestampKey INTEGER PRIMARY KEY, '
          '$_lastEditedTimestampKey INTEGER, '
          '$_journalTitleKey TEXT, '
          '$_journalEntryKey TEXT, '
          '$_sleepMetricKey INTEGER)');
    }, version: 1);
  }

  static Future<void> insert(SleepJournalEntry entry) async {
    Map<String, dynamic> mapEntry = entry.toMap();
    final db = await SleepDBHelper._database();

    db.insert(_tableName, mapEntry,
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Inserting entry: ${entry.toString()}');
  }

  static Future<void> update(SleepJournalEntry entry) async {
    final db = await SleepDBHelper._database();

    db.update(_tableName, entry.toMap(), where: '$_createdTimestampKey = ?', whereArgs: [entry.createdTimestamp!.millisecondsSinceEpoch]);
    print('Updating entry: ${entry.toString()}');
  }

  static Future<List<SleepJournalEntry>> getData(
      {DateTime? start, DateTime? end}) async {
    final db = await SleepDBHelper._database();
    var res;
    if (start == null && end == null) {
      res = await db.rawQuery('SELECT * FROM $_tableName');
    } else {
      res = await db.rawQuery('SELECT * FROM $_tableName ' +
          'WHERE created_datetime BETWEEN $start AND $end');
    }
    List<SleepJournalEntry> sleepEntries = [];
    res.toList().forEach((mapEntry) {
      sleepEntries.add(SleepJournalEntry.fromMap(mapEntry));
    });
    return sleepEntries;
  }

  static Future<SleepJournalEntry> getTodaysData() async {
    final db = await SleepDBHelper._database();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tmr = today.add(Duration(days: 1));

    final todayEpoch = today.millisecondsSinceEpoch;
    final tmrEpoch = tmr.millisecondsSinceEpoch;

    var res = await db.rawQuery('SELECT * FROM $_tableName WHERE created_datetime BETWEEN $todayEpoch AND $tmrEpoch');
    if (res.toList().length == 0) {
      return SleepJournalEntry();
    }
    SleepJournalEntry todaysEntry = SleepJournalEntry.fromMap(res.toList()[0]);
    return todaysEntry;
  }

  static Future<void> delete(DateTime datetime) async {
    final db = await SleepDBHelper._database();
    await db.rawDelete('DELETE FROM user_moods WHERE datetime = $datetime');
  }

  static Future<void> clearDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    await sql.deleteDatabase(path.join(dbPath, 'sleepData.db'));
  }
}

class SleepDataPoint {
  int sleepMetric;
  DateTime date;

  SleepDataPoint(this.date, this.sleepMetric);
}