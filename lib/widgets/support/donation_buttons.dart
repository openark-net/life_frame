import 'package:flutter/cupertino.dart';
import '../../openark_theme.dart';

class DonationButtons extends StatefulWidget {
  final Function(String) onAmountSelected;
  
  const DonationButtons({super.key, required this.onAmountSelected});

  @override
  State<DonationButtons> createState() => _DonationButtonsState();
}

class _DonationButtonsState extends State<DonationButtons> {
  String selectedAmount = '1';
  final List<String> amounts = ['1', '2', '5', '10'];

  @override
  void initState() {
    super.initState();
    // Notify parent of default selection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAmountSelected(selectedAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: amounts.map((amount) => _buildDonationButton(amount)).toList(),
          ),
        ),
        const SizedBox(height: 24),
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          color: OpenArkColors.primary,
          borderRadius: BorderRadius.circular(12),
          onPressed: () {
            // TODO: Implement actual donation functionality
          },
          child: Text(
            'Donate \$$selectedAmount',
            style: TextStyle(
              fontFamily: dmSansFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: OpenArkColors.primaryContrast,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationButton(String amount) {
    final bool isSelected = selectedAmount == amount;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount;
        });
        widget.onAmountSelected(amount);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? OpenArkColors.tertiary : OpenArkColors.background,
          border: Border.all(
            color: isSelected ? OpenArkColors.tertiary : OpenArkColors.foreground.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '\$$amount',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isSelected ? OpenArkColors.tertiaryContrast : OpenArkColors.foreground,
          ),
        ),
      ),
    );
  }
}
