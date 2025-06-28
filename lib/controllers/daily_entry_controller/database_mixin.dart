import 'dart:async';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:talker/talker.dart';

mixin DatabaseMixin {
  static const tableName = 'daily_entry';
  late final Database db;
  final Talker talker = Get.find<Talker>();

  Future<void> initializeDatabase() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final path = join(docsDir.path, 'life_frame.db');

      db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName (
              timestamp      INTEGER PRIMARY KEY,
              photoPath      TEXT    NOT NULL,
              location_name  TEXT    NOT NULL,
              lat            REAL    NOT NULL,
              lng            REAL    NOT NULL
            )
          ''');
          talker.info('Created table $tableName');
        },
      );

      talker.debug('Database opened at $path');
    } catch (e, st) {
      talker.handle(e, st, 'Failed to open/init database');
    }
  }

  Future<int> getTotalCount() async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseMixin.tableName}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> hasMoreEntries(int? afterTimestamp) async {
    if (afterTimestamp == null) return false;

    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM ${DatabaseMixin.tableName} WHERE timestamp < ?',
      [afterTimestamp],
    );
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }
}
