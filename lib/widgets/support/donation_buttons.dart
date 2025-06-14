import 'package:flutter/cupertino.dart';
import '../../theme.dart';

class DonationButtons extends StatelessWidget {
  const DonationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDonationButton('1'),
          _buildDonationButton('2'),
          _buildDonationButton('5'),
        ],
      ),
    );
  }

  Widget _buildDonationButton(String amount) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      onPressed: () {
        // TODO: Implement donation functionality
      },
      child: Text(
        amount,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
      ),
    );
  }
}