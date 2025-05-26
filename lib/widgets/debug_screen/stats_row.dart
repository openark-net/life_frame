import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../controllers/photo_journal_controller.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PhotoJournalController>();

    return Obx(() => Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${controller.totalPhotosCount}',
            label: 'Total Photos',
            backgroundColor: CupertinoColors.systemBlue.withOpacity(0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '${controller.getStreak()}',
            label: 'Day Streak',
            backgroundColor: CupertinoColors.systemGreen.withOpacity(0.1),
          ),
        ),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color backgroundColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
          ),
          Text(
            label,
            style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
          ),
        ],
      ),
    );
  }
}
