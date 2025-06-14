import 'package:flutter/cupertino.dart';
import '../theme.dart';
import '../widgets/support/support_card.dart';
import '../widgets/support/openark_logo.dart';
import '../widgets/support/support_title.dart';
import '../widgets/support/website_badge.dart';
import '../widgets/support/donation_buttons.dart';

class SupportDeveloperScreen extends StatelessWidget {
  const SupportDeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Support'),
      ),
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SupportCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OpenArkLogo(),
                  const SizedBox(height: 16),
                  const WebsiteBadge(),
                  const SizedBox(height: 24),
                  const SupportDescription(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const DonationButtons(),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}