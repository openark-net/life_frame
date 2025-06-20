import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import '../../openark_theme.dart';
import '../../services/donation_service.dart';

enum DonationDialogState { confirm, loading, thankYou }

class DonationDialog extends StatefulWidget {
  final String donationAmount;
  final VoidCallback onClose;

  const DonationDialog({
    super.key,
    required this.donationAmount,
    required this.onClose,
  });

  @override
  State<DonationDialog> createState() => _DonationDialogState();
}

class _DonationDialogState extends State<DonationDialog> {
  DonationDialogState _state = DonationDialogState.confirm;
  final InAppPurchaseService _donationService =
      Get.find<InAppPurchaseService>();
  final Talker _talker = Get.find<Talker>();

  static const Map<String, String> _amountToProductId = {
    '1': InAppPurchaseService.donation1CAD,
    '5': InAppPurchaseService.donation5CAD,
    '10': InAppPurchaseService.donation10CAD,
    '50': InAppPurchaseService.donation50CAD,
  };

  @override
  void initState() {
    super.initState();
    _donationService.purchaseStatus.listen(_handlePurchaseStatusChange);
  }

  void _handlePurchaseStatusChange(DonationStatus status) {
    if (!mounted) return;

    switch (status) {
      case DonationStatus.loading:
        setState(() {
          _state = DonationDialogState.loading;
        });
        break;
      case DonationStatus.success:
        setState(() {
          _state = DonationDialogState.thankYou;
        });
        _scheduleAutoClose();
        break;
      case DonationStatus.error:
      case DonationStatus.cancelled:
        _handleError();
        break;
      case DonationStatus.idle:
        break;
    }
  }

  void _scheduleAutoClose() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  void _handleError() {
    _showErrorAlert();
  }

  void _showErrorAlert() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Payment Error'),
        content: Text(
          _donationService.errorMessage.value.isEmpty
              ? 'Something went wrong with your donation. Please try again.'
              : _donationService.errorMessage.value,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              _donationService.clearError();
              widget.onClose();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDonation() async {
    final productId = _amountToProductId[widget.donationAmount];
    if (productId == null) {
      _talker.error('Invalid donation amount: ${widget.donationAmount}');
      _handleError();
      return;
    }

    _talker.info('Confirming donation of \$${widget.donationAmount}');
    await _donationService.makeDonation(productId);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case DonationDialogState.confirm:
        return _buildConfirmContent();
      case DonationDialogState.loading:
        return _buildLoadingContent();
      case DonationDialogState.thankYou:
        return _buildThankYouContent();
    }
  }

  Widget _buildConfirmContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.heart_fill,
          color: OpenArkColors.primary,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Confirm Donation',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: OpenArkColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You are about to donate \$${widget.donationAmount} CAD to support Life Frame development.',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 16,
            color: OpenArkColors.foreground.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your support helps us continue improving the app!',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 14,
            color: OpenArkColors.foreground.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CupertinoActivityIndicator(
          radius: 24,
          color: OpenArkColors.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Processing Donation',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: OpenArkColors.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we process your \$${widget.donationAmount} donation...',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 14,
            color: OpenArkColors.foreground.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildThankYouContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          CupertinoIcons.checkmark_circle_fill,
          color: CupertinoColors.systemGreen,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          'Thank You!',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: OpenArkColors.foreground,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your \$${widget.donationAmount} donation has been processed successfully!',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 16,
            color: OpenArkColors.foreground.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Your support means the world to us and helps keep Life Frame growing. ❤️',
          style: TextStyle(
            fontFamily: dmSansFont,
            fontSize: 14,
            color: OpenArkColors.foreground.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    switch (_state) {
      case DonationDialogState.confirm:
        return [
          CupertinoDialogAction(
            onPressed: widget.onClose,
            child: Text(
              'Cancel',
              style: TextStyle(
                color: OpenArkColors.foreground.withOpacity(0.6),
              ),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: _confirmDonation,
            child: Text(
              'Donate \$${widget.donationAmount}',
              style: const TextStyle(
                color: OpenArkColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
      case DonationDialogState.loading:
        return [];
      case DonationDialogState.thankYou:
        return [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: widget.onClose,
            child: const Text(
              'Close',
              style: TextStyle(
                color: OpenArkColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ];
    }
  }
}
