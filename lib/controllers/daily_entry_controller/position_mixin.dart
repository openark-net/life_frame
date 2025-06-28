import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'package:life_frame/models/daily_entry.dart';
import 'database_mixin.dart';

mixin PositionMixin on DatabaseMixin {
  Future<int> getEntryPosition(DailyEntry entry) async {
    try {
      final timestamp = entry.timestamp.millisecondsSinceEpoch;

      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseMixin.tableName} WHERE timestamp > ?',
        [timestamp],
      );

      final position = Sqflite.firstIntValue(result) ?? 0;
      talker.debug('Entry position for ${entry.timestamp}: $position');
      return position;
    } catch (e, st) {
      talker.handle(e, st, 'Error getting entry position');
      return 0;
    }
  }

  Future<List<DailyEntry>> getEntriesAroundPosition(
    int position,
    int windowSize,
  ) async {
    try {
      final halfWindow = windowSize ~/ 2;
      final startPosition = (position - halfWindow)
          .clamp(0, double.infinity)
          .toInt();

      final rows = await db.rawQuery(
        '''
        SELECT * FROM ${DatabaseMixin.tableName}
        ORDER BY timestamp DESC
        LIMIT ? OFFSET ?
      ''',
        [windowSize, startPosition],
      );

      final entries = rows.map(DailyEntry.fromMap).toList();
      talker.debug(
        'Retrieved ${entries.length} entries around position $position',
      );
      return entries;
    } catch (e, st) {
      talker.handle(e, st, 'Error getting entries around position');
      return [];
    }
  }

  Future<List<DailyEntry>> getEntriesBeforePosition(
    int position,
    int count,
  ) async {
    try {
      final rows = await db.rawQuery(
        '''
        SELECT * FROM ${DatabaseMixin.tableName}
        ORDER BY timestamp DESC
        LIMIT ? OFFSET ?
      ''',
        [count, position + 1],
      );

      final entries = rows.map(DailyEntry.fromMap).toList();
      talker.debug(
        'Retrieved ${entries.length} entries before position $position',
      );
      return entries;
    } catch (e, st) {
      talker.handle(e, st, 'Error getting entries before position');
      return [];
    }
  }

  Future<List<DailyEntry>> getEntriesAfterPosition(
    int position,
    int count,
  ) async {
    try {
      final startPosition = (position - count)
          .clamp(0, double.infinity)
          .toInt();

      final rows = await db.rawQuery(
        '''
        SELECT * FROM ${DatabaseMixin.tableName}
        ORDER BY timestamp DESC
        LIMIT ? OFFSET ?
      ''',
        [count, startPosition],
      );

      final entries = rows.map(DailyEntry.fromMap).toList();
      talker.debug(
        'Retrieved ${entries.length} entries after position $position',
      );
      return entries;
    } catch (e, st) {
      talker.handle(e, st, 'Error getting entries after position');
      return [];
    }
  }
}
