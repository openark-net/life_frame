import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:life_frame/models/daily_entry.dart';
import 'database_mixin.dart';
import 'stats_mixin.dart';

mixin CrudMixin on DatabaseMixin, StatsMixin {
  Future<bool> insertDailyEntry(DailyEntry entry) async {
    try {
      await db.insert(
        DatabaseMixin.tableName,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      talker.info('Inserted entry for ${entry.timestamp.toIso8601String()}');

      await refreshStats();
      incrementEntriesVersion();
      return true;
    } catch (e, st) {
      talker.handle(e, st, 'Error inserting daily entry');
      return false;
    }
  }

  Future<DailyEntry?> getImageByTimestamp(DateTime time) async {
    try {
      final timestamp = time.millisecondsSinceEpoch;
      final rows = await db.query(
        DatabaseMixin.tableName,
        where: 'timestamp = ?',
        whereArgs: [timestamp],
        limit: 1,
      );

      if (rows.isEmpty) {
        talker.debug('No entry found for timestamp: ${time.toIso8601String()}');
        return null;
      }

      final entry = DailyEntry.fromMap(rows.first);
      talker.debug('Found entry for timestamp: ${time.toIso8601String()}');
      return entry;
    } catch (e, st) {
      talker.handle(e, st, 'Error getting image by timestamp');
      return null;
    }
  }

  Future<bool> deleteEntryByTimestamp(DateTime timestamp) async {
    try {
      final timestampMs = timestamp.millisecondsSinceEpoch;
      final count = await db.delete(
        DatabaseMixin.tableName,
        where: 'timestamp = ?',
        whereArgs: [timestampMs],
      );

      if (count > 0) {
        talker.info('Deleted entry for ${timestamp.toIso8601String()}');
        await refreshStats();
        incrementEntriesVersion();
        return true;
      } else {
        talker.warning(
          'No entry found for timestamp: ${timestamp.toIso8601String()}',
        );
        return false;
      }
    } catch (e, st) {
      talker.handle(e, st, 'Error deleting entry by timestamp');
      return false;
    }
  }

  Future<bool> deleteTodayEntry() async {
    try {
      final todaysEntries = await getTodaysEntries();
      if (todaysEntries.isEmpty) {
        talker.info('No entries for today, nothing to delete.');
        return false;
      }

      var deletedCount = 0;
      for (final entry in todaysEntries) {
        final ts = entry.timestamp.millisecondsSinceEpoch;
        final count = await db.delete(
          DatabaseMixin.tableName,
          where: 'timestamp = ?',
          whereArgs: [ts],
        );
        deletedCount += count;
      }

      talker.info(
        'Deleted $deletedCount today\'s DB entr${deletedCount == 1 ? 'y' : 'ies'}.',
      );
      await refreshStats();
      return true;
    } catch (e, st) {
      talker.handle(e, st, 'Error deleting today\'s photo entries');
      return false;
    }
  }
}
