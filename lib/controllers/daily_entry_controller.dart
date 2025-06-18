// lib/controllers/daily_entry_controller.dart
import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';
import 'package:sqflite/sqflite.dart';

import 'package:life_frame/models/daily_entry.dart';
import 'package:life_frame/models/pagination_result.dart';

class DailyEntryController extends GetxController {
  static const _tableName = 'daily_entry';
  late final Database _db;
  final Talker _talker = Get.find<Talker>();

  final RxBool hasPhotoToday$ = false.obs;
  final RxInt streak$ = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final path = join(docsDir.path, 'life_frame.db');

      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              timestamp      INTEGER PRIMARY KEY,
              photoPath      TEXT    NOT NULL,
              location_name  TEXT    NOT NULL,
              lat            REAL    NOT NULL,
              lng            REAL    NOT NULL
            )
          ''');
          _talker.info('Created table $_tableName');
        },
      );

      _talker.debug('Database opened at $path');

      // once DB is ready, load initial stats:
      await _refreshStats();
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to open/init database');
    }
  }

  Future<void> _refreshStats() async {
    try {
      final today = await _computeHasPhotoToday();
      final run = await _computeStreak();

      hasPhotoToday$.value = today;
      streak$.value = run;

      _talker.info('Stats refreshed: hasPhotoToday=$today, streak=$run');
    } catch (e, st) {
      _talker.handle(e, st, 'Error refreshing stats');
    }
  }

  Future<bool> insertDailyEntry(DailyEntry entry) async {
    try {
      await _db.insert(
        _tableName,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _talker.info('Inserted entry for ${entry.timestamp.toIso8601String()}');

      await _refreshStats();
      return true;
    } catch (e, st) {
      _talker.handle(e, st, 'Error inserting daily entry');
      return false;
    }
  }

  Future<List<DailyEntry>> _getTodaysEntries() async {
    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final endOfDay = startOfDay + Duration(days: 1).inMilliseconds;

    final rows = await _db.query(
      _tableName,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'timestamp DESC',
    );

    return rows.map(DailyEntry.fromMap).toList();
  }

  Future<bool> _computeHasPhotoToday() async {
    final entries = await _getTodaysEntries();
    return entries.isNotEmpty;
  }

  Future<int> _computeStreak() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final includeTod = await _computeHasPhotoToday();
    DateTime cursor = includeTod
        ? todayStart
        : todayStart.subtract(Duration(days: 1));

    int streak = 0;
    while (true) {
      final startMs = cursor.millisecondsSinceEpoch;
      final endMs = startMs + Duration(days: 1).inMilliseconds;

      final count = Sqflite.firstIntValue(
        await _db.rawQuery(
          '''
        SELECT COUNT(*) FROM $_tableName
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

  Future<int> _getTotalCount() async {
    final result = await _db.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> _hasMoreEntries(int? afterTimestamp) async {
    if (afterTimestamp == null) return false;

    final result = await _db.rawQuery(
      'SELECT COUNT(*) FROM $_tableName WHERE timestamp < ?',
      [afterTimestamp],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<PaginationResult<DailyEntry>> list({
    int? cursor,
    int pageSize = 10,
  }) async {
    try {
      _talker.debug('Fetching entries: cursor=$cursor, pageSize=$pageSize');

      // Get total count
      final total = await _getTotalCount();

      // Build query
      final whereClause = cursor != null ? 'WHERE timestamp < ?' : '';
      final args = <dynamic>[];
      if (cursor != null) args.add(cursor);
      args.add(pageSize);

      final rows = await _db.rawQuery('''
        SELECT * FROM $_tableName
        $whereClause
        ORDER BY timestamp DESC
        LIMIT ?
      ''', args);

      final entries = rows.map(DailyEntry.fromMap).toList(growable: false);

      // Determine pagination flags
      final hasPreviousPage = cursor != null;
      final hasNextPage = entries.isNotEmpty
          ? await _hasMoreEntries(entries.last.timestamp.millisecondsSinceEpoch)
          : false;

      final result = PaginationResult<DailyEntry>(
        results: entries,
        hasNextPage: hasNextPage,
        hasPreviousPage: hasPreviousPage,
        total: total,
      );

      _talker.info('Loaded pagination result: ${result.toString()}');
      return result;
    } catch (e, st) {
      _talker.handle(e, st, 'Error creating paginated daily entries list');
      return const PaginationResult<DailyEntry>(
        results: [],
        hasNextPage: false,
        hasPreviousPage: false,
        total: 0,
      );
    }
  }

  Future<bool> deleteTodayEntry() async {
    try {
      final todaysEntries = await _getTodaysEntries();
      if (todaysEntries.isEmpty) {
        _talker.info('No entries for today, nothing to delete.');
        return false;
      }

      var deletedCount = 0;
      for (final entry in todaysEntries) {
        final ts = entry.timestamp.millisecondsSinceEpoch;
        final count = await _db.delete(
          _tableName,
          where: 'timestamp = ?',
          whereArgs: [ts],
        );
        deletedCount += count;
      }

      _talker.info(
        'Deleted $deletedCount today\'s DB entr${deletedCount == 1 ? 'y' : 'ies'}.',
      );
      await _refreshStats();
      return true;
    } catch (e, st) {
      _talker.handle(e, st, 'Error deleting today\'s photo entries');
      return false;
    }
  }
}
