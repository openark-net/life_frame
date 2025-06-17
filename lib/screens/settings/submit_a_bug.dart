import 'package:flutter/cupertino.dart';
import '../../theme.dart';
import '../../widgets/background/AbstractBackground.dart';
import '../../widgets/common/content_card.dart';
import '../../widgets/submit_a_bug/bug_icon.dart';
import '../../widgets/submit_a_bug/bug_title.dart';
import '../../widgets/submit_a_bug/bug_description.dart';
import '../../widgets/submit_a_bug/bug_action_buttons.dart';

class SubmitABugScreen extends StatelessWidget {
  const SubmitABugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(middle: Text('Submit a Bug')),
      child: Stack(
        children: [
          const AbstractBackground(density: 0.6, seed: 11104),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ContentCard(
                    child: Column(
                      children: [
                        const BugIcon(),
                        const SizedBox(height: 24),
                        const BugTitle(),
                        const SizedBox(height: 20),
                        const BugDescription(),
                        const SizedBox(height: 32),
                        const BugActionButtons(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
