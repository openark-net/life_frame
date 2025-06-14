import 'package:flutter/cupertino.dart';
import '../openark_theme.dart';
import '../widgets/support/support_card.dart';
import '../widgets/support/openark_logo.dart';
import '../widgets/support/support_title.dart';
import '../widgets/support/website_badge.dart';
import '../widgets/support/donation_buttons.dart';
import '../widgets/support/rainbow_background.dart';

class SupportDeveloperScreen extends StatefulWidget {
  const SupportDeveloperScreen({super.key});

  @override
  State<SupportDeveloperScreen> createState() => _SupportDeveloperScreenState();
}

class _SupportDeveloperScreenState extends State<SupportDeveloperScreen> {
  String selectedAmount = '1';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Support')),
      backgroundColor: OpenArkColors.background,
      child: RainbowBackground(
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
                    const SizedBox(height: 32),
                    const WebsiteBadge(),
                    const SizedBox(height: 24),
                    const SupportDescription(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              DonationButtons(
                onAmountSelected: (amount) {
                  setState(() {
                    selectedAmount = amount;
                  });
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
