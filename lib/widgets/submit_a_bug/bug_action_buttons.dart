import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:talker/talker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BugActionButtons extends StatelessWidget {
  const BugActionButtons({super.key});

  Future<void> _openGitHubIssues() async {
    final uri = Uri.parse('https://github.com/openark-net/life_frame/issues');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareLogs() async {
    try {
      final talker = Get.find<Talker>();
      final formattedLogs = talker.history
          .map((log) {
            final timestamp = log.time.toIso8601String();
            final level = log.key?.toUpperCase() ?? 'LOG';
            return '[$timestamp] [$level] ${log.message}';
          })
          .join('\n');

      final header =
          '=== Life Frame App Logs ===\n'
          'Generated: ${DateTime.now().toIso8601String()}\n'
          'Total Logs: ${talker.history.length}\n'
          '================================\n\n';

      final finalLogs = header + formattedLogs;

      await Share.share(finalLogs, subject: 'Life Frame App Logs');

      talker.info('User shared logs with ${talker.history.length} entries');
    } catch (e, st) {
      final talker = Get.find<Talker>();
      talker.handle(e, st, 'Failed to share logs');
      Get.snackbar(
        'Error',
        'Failed to share logs: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: _shareLogs,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.share,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Share logs',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            onPressed: _openGitHubIssues,
            color: CupertinoColors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/logo/github-mark-white.svg',
                  width: 18,
                  height: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Github Issues',
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
