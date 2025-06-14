import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../openark_theme.dart';
import '../widgets/about/support_card.dart';
import '../widgets/about/openark_logo.dart';
import '../widgets/about/support_title.dart';
import '../widgets/about/website_badge.dart';
import '../widgets/about/donation_buttons.dart';
import '../widgets/about/rainbow_background.dart';

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
      navigationBar: const CupertinoNavigationBar(middle: Text('About')),
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
