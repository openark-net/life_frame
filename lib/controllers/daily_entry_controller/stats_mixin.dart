import 'dart:async';

import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';

import 'package:life_frame/models/daily_entry.dart';
import 'database_mixin.dart';

mixin StatsMixin on DatabaseMixin {
  final RxBool hasPhotoToday$ = false.obs;
  final RxInt streak$ = 0.obs;
  final RxInt entriesVersion$ = 0.obs;

  void incrementEntriesVersion() {
    entriesVersion$.value = entriesVersion$.value + 1;
  }

  Future<void> refreshStats() async {
    try {
      final today = await computeHasPhotoToday();
      final run = await computeStreak();

      hasPhotoToday$.value = today;
      streak$.value = run;

      talker.info('Stats refreshed: hasPhotoToday=$today, streak=$run');
    } catch (e, st) {
      talker.handle(e, st, 'Error refreshing stats');
    }
  }

  Future<List<DailyEntry>> getTodaysEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final endOfDay = startOfDay + Duration(days: 1).inMilliseconds;

    final rows = await db.query(
      DatabaseMixin.tableName,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );

    return rows.map(DailyEntry.fromMap).toList();
  }

  Future<bool> computeHasPhotoToday() async {
    final entries = await getTodaysEntries();
    return entries.isNotEmpty;
  }

  Future<int> computeStreak() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final includeTod = await computeHasPhotoToday();
    DateTime cursor = includeTod
        ? todayStart
        : todayStart.subtract(Duration(days: 1));

    int streak = 0;
    while (true) {
      final startMs = cursor.millisecondsSinceEpoch;
      final endMs = startMs + Duration(days: 1).inMilliseconds;

      final count = Sqflite.firstIntValue(
        await db.rawQuery(
          '''
        SELECT COUNT(*) FROM ${DatabaseMixin.tableName}
        WHERE timestamp >= ? AND timestamp < ?
      ''',
          [startMs, endMs],
        ),
      );

      if ((count ?? 0) > 0) {
        streak++;
        cursor = cursor.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
