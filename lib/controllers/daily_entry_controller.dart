import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:talker/talker.dart';
import 'package:sqflite/sqflite.dart';

import 'package:life_frame/models/daily_entry.dart';

class DailyEntryController extends GetxController {
  static const _tableName = 'daily_entry';
  late final Database _db;
  final Talker _talker = Get.find<Talker>();

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
              timestamp   INTEGER PRIMARY KEY,
              photoPath   TEXT    NOT NULL,
              location_name TEXT  NOT NULL,
              lat         REAL    NOT NULL,
              lng         REAL    NOT NULL
            )
          ''');
          _talker.info('Created table $_tableName');
        },
      );
      _talker.info('Database opened at $path');
    } catch (e, st) {
      _talker.handle(e, st, 'Failed to open/init database');
    }
  }

  /// 1) insertDailyEntry
  Future<bool> insertDailyEntry(DailyEntry entry) async {
    try {
      await _db.insert(
        _tableName,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _talker.info('Inserted entry for ${entry.timestamp.toIso8601String()}');
      return true;
    } catch (e, st) {
      _talker.handle(e, st, 'Error inserting daily entry');
      return false;
    }
  }

  /// 2) hasPhotoToday
  Future<bool> hasPhotoToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
      ).millisecondsSinceEpoch;
      final endOfDay = startOfDay + Duration(days: 1).inMilliseconds;

      final count = Sqflite.firstIntValue(
        await _db.rawQuery(
          '''
          SELECT COUNT(*) FROM $_tableName
          WHERE timestamp >= ? AND timestamp < ?
        ''',
          [startOfDay, endOfDay],
        ),
      );
      final result = (count ?? 0) > 0;
      _talker.info('hasPhotoToday => $result');
      return result;
    } catch (e, st) {
      _talker.handle(e, st, 'Error checking hasPhotoToday');
      return false;
    }
  }

  /// 3) getStreak
  ///
  /// Count consecutive days with an entry. If today is missing, starts from yesterday.
  Future<int> getStreak() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      // determine whether to include today in the streak
      final includeToday = await hasPhotoToday();
      DateTime cursorDay = includeToday
          ? todayStart
          : todayStart.subtract(Duration(days: 1));

      int streak = 0;
      while (true) {
        final startMs = cursorDay.millisecondsSinceEpoch;
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
          cursorDay = cursorDay.subtract(Duration(days: 1));
        } else {
          break;
        }
      }
      _talker.info('Current streak: $streak');
      return streak;
    } catch (e, st) {
      _talker.handle(e, st, 'Error computing streak');
      return 0;
    }
  }

  /// 4) list(cursor, pageSize)
  ///
  /// Returns the newest entries first. If [cursor] is given, returns entries
  /// with timestamp < cursor. Useful for infinite‐scroll pagination.
  Future<List<DailyEntry>> list({int? cursor, int pageSize = 10}) async {
    try {
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

      final entries = rows
          .map((r) => DailyEntry.fromMap(r))
          .toList(growable: false);
      _talker.info('Loaded ${entries.length} entries (cursor=$cursor)');
      return entries;
    } catch (e, st) {
      _talker.handle(e, st, 'Error listing daily entries');
      return [];
    }
  }
}
