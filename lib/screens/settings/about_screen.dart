import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../../openark_theme.dart';
import '../../widgets/about/support_card.dart';
import '../../widgets/about/openark_logo.dart';
import '../../widgets/about/support_title.dart';
import '../../widgets/about/website_badge.dart';
import '../../widgets/about/donation_buttons.dart';
import '../../widgets/about/donation_dialog.dart';
import '../../widgets/about/rainbow_background.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String selectedAmount = '1';

  void _showDonationDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => DonationDialog(
        donationAmount: selectedAmount,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talker = Get.find<Talker>();
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
                    const SizedBox(height: 24),
                    const WebsiteBadge(),
                    const SizedBox(height: 12),
                    const SupportDescription(),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              DonationButtons(
                onAmountSelected: (amount) {
                  setState(() {
                    talker.info("Selected donation amount: $amount");
                    selectedAmount = amount;
                  });
                },
                onDonatePressed: _showDonationDialog,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
