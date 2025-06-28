import 'dart:async';

import 'package:life_frame/models/daily_entry.dart';
import 'package:life_frame/models/pagination_result.dart';
import 'database_mixin.dart';

mixin PaginationMixin on DatabaseMixin {
  Future<PaginationResult<DailyEntry>> list({
    int? cursor,
    int pageSize = 10,
  }) async {
    try {
      talker.debug('Fetching entries: cursor=$cursor, pageSize=$pageSize');

      final total = await getTotalCount();

      final whereClause = cursor != null ? 'WHERE timestamp < ?' : '';
      final args = <dynamic>[];
      if (cursor != null) args.add(cursor);
      args.add(pageSize);

      final rows = await db.rawQuery('''
        SELECT * FROM ${DatabaseMixin.tableName}
        $whereClause
        ORDER BY timestamp DESC
        LIMIT ?
      ''', args);

      final entries = rows.map(DailyEntry.fromMap).toList();

      final hasPreviousPage = cursor != null;
      final hasNextPage = entries.isNotEmpty
          ? await hasMoreEntries(entries.last.timestamp.millisecondsSinceEpoch)
          : false;

      final result = PaginationResult<DailyEntry>(
        results: entries,
        hasNextPage: hasNextPage,
        hasPreviousPage: hasPreviousPage,
        total: total,
      );

      talker.info('Loaded pagination result: ${result.toString()}');
      return result;
    } catch (e, st) {
      talker.handle(e, st, 'Error creating paginated daily entries list');
      return const PaginationResult<DailyEntry>(
        results: [],
        hasNextPage: false,
        hasPreviousPage: false,
        total: 0,
      );
    }
  }
}
