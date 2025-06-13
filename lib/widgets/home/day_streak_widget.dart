import 'package:flutter/cupertino.dart';
import '../../theme.dart';

class DayStreakWidget extends StatelessWidget {
  final int streakCount;

  const DayStreakWidget({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryYellow.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: Icon(
              CupertinoIcons.flame_fill,
              size: 80,
              color: AppColors.primaryYellow.withOpacity(0.3),
            ),
          ),
          Column(
            children: [
              Text(
                '$streakCount',
                style: CupertinoTheme.of(context)
                    .textTheme
                    .navLargeTitleTextStyle
                    .copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                    ),
              ),
              Text(
                'Day Streak',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryYellow,
                  fontFamily: TITLE_FONT,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
