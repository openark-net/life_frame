import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InlineCodeblock extends StatelessWidget {
  final String text;
  final bool copyable;

  const InlineCodeblock({super.key, required this.text, this.copyable = true});

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Copied "$text" to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: copyable ? _copyToClipboard : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 14,
            color: CupertinoColors.systemBlue,
          ),
        ),
      ),
    );
  }
}
