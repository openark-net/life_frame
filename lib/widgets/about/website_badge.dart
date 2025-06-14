import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../openark_theme.dart';

class WebsiteBadge extends StatelessWidget {
  const WebsiteBadge({super.key});

  Future<void> _launchUrl(String url) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _launchUrl('https://openark.net/'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [OpenArkColors.primary, OpenArkColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: OpenArkColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.globe,
                  color: OpenArkColors.primaryContrast,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'openark.net',
                  style: TextStyle(
                    fontFamily: dmSansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: OpenArkColors.primaryContrast,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.arrow_up_right,
                  color: OpenArkColors.primaryContrast,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _launchUrl('https://github.com/openark-net/life_frame'),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: OpenArkColors.foreground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: OpenArkColors.foreground.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildGitHubIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildGitHubIcon() {
    return SvgPicture.asset(
      'assets/logo/github-mark-white.svg',
      width: 20,
      height: 20,
    );
  }
}
