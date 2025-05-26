import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

class DebugScreenHeader extends StatelessWidget {
  const DebugScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(() => Text(
      'Today: ${controller.currentDate}',
      style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
    ));
  }
}
