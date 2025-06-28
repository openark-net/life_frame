import 'package:get/get.dart';

import 'database_mixin.dart';
import 'stats_mixin.dart';
import 'crud_mixin.dart';
import 'pagination_mixin.dart';
import 'position_mixin.dart';

class DailyEntryController extends GetxController
    with DatabaseMixin, StatsMixin, CrudMixin, PaginationMixin, PositionMixin {
  @override
  void onInit() {
    super.onInit();
    initializeDatabase().then((_) => refreshStats());
  }
}
